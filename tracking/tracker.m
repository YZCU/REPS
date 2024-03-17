function [fuse_box_corner,fps] = tracker(varargin)
p.init_angle = 0;
p.angle_pool = [-2,0,2];
p.numAngle = size(p.angle_pool,2);
p.chengfa = 1; 
p.limit_size = 70;
p.limit_pos = 30;
p.responseUp = 3;
p.windowing = 'cosine';
p.wInfluence = 0.176;
p.net = 'model.mat'; 
p.video = varargin{1, 1}.video;
p.gpus = 1;
%% Params from the network architecture, have to be consistent with the training
p.exemplarSize = 127;  % input z size
p.instanceSize = 255;  % input x size (search region)
p.totalStride = 8;
p.scoreSize = 17;
p.contextAmount = 0.5; % context amount for the exemplar
%% SiamFC prefix and ids
p.prefix_z = 'a_'; % used to identify the layers of the exemplar
p.prefix_x = 'b_'; % used to identify the layers of the instance
p.prefix_join = 'xcorr';
p.prefix_adj = 'adjust';
p.id_feat_z = 'a_feat';
p.id_score = 'score';
% Overwrite default parameters with varargin
p = vl_argparse(p, varargin{1});
% Get environment-specific default paths.
p = env_paths_tracking(p);
% Load ImageNet Video statistics  ?
if exist(p.stats_path,'file')
    stats = load(p.stats_path);
else
    warning('No stats found at %s', p.stats_path);
    stats = [];
end
% Load two copies of the pre-trained network
net_z = load_pretrained([p.net_base_path p.net], p.gpus);
net_x = load_pretrained([p.net_base_path p.net], []);
[imgFiles, targetPosition, targetSize] = load_video_info(p.seq_base_path, p.video);
nImgs = numel(imgFiles);
startFrame = 1;
% Divide the net
% exemplar branch z (used only once per video) computes features for the target
remove_layers_from_prefix(net_z, p.prefix_x);
remove_layers_from_prefix(net_z, p.prefix_join);
remove_layers_from_prefix(net_z, p.prefix_adj);
% instance branch computes features for search region x and cross-correlates with z features
remove_layers_from_prefix(net_x, p.prefix_z);
zFeatId = net_z.getVarIndex(p.id_feat_z); 
scoreId = net_x.getVarIndex(p.id_score);
% get the first frame of the video
im = gpuArray(single(imgFiles{startFrame}));
% if grayscale repeat one channel to match filters size
if(size(im, 3)==1)
    im = repmat(im, [1 1 3]);
end
% Init visualization
videoPlayer = [];
if p.visualization && isToolboxAvailable('Computer Vision System Toolbox')
    videoPlayer = vision.VideoPlayer('Position', [100 100 [size(im,2), size(im,1)]+30]);
end
% get avg for padding
avgChans = gather([mean(mean(im(:,:,1))) mean(mean(im(:,:,2))) mean(mean(im(:,:,3)))]);
wc_z = targetSize(2) + p.contextAmount*sum(targetSize);
hc_z = targetSize(1) + p.contextAmount*sum(targetSize);
s_z = sqrt(wc_z*hc_z);
scale_z = p.exemplarSize / s_z;
% initialize the exemplar
[z_crop, ~] = get_subwindow_tracking(im, targetPosition, [p.exemplarSize p.exemplarSize], [round(s_z) round(s_z)], avgChans);
d_search = (p.instanceSize - p.exemplarSize)/2;
pad = d_search/scale_z;
s_x = s_z + 2 * pad;
switch p.windowing
    case 'cosine'
        window = single(hann(p.scoreSize*p.responseUp) * hann(p.scoreSize*p.responseUp)');
    case 'uniform'
        window = single(ones(p.scoreSize*p.responseUp, p.scoreSize*p.responseUp));
end
window = window / sum(window(:));
net_z.eval({'exemplar', z_crop});
z_features = net_z.vars(zFeatId).value;
z_features = repmat(z_features, [1 1 1 p.numAngle]);
siamfc_bboxes = zeros(nImgs, 4);
p_ch = varargin{2};
p_ch.init_pos = targetPosition;
p_ch.target_sz = round(targetSize);
[p_ch, bg_area, fg_area, area_resize_factor] = initializeAllAreas(im, p_ch);
pre_thr = 0.8; 
k = 4;
fc_box_corner = zeros(nImgs, 10);
ch_box_corner = zeros(nImgs, 10);
fuse_box_corner = zeros(nImgs, 10);
tim = zeros(nImgs,1);
tim1 = zeros(nImgs,1);
time = 0;
ff = tic;
for i = startFrame:nImgs
    if i > startFrame
        foo = tic;
        im = gpuArray(single(imgFiles{i}));
        tim1 (i)=toc(foo);
        if(size(im, 3)==1)
            im = repmat(im, [1 1 3]);
        end
        x_crops = make_scale_pyramid(im, fuse_targetPosition, s_x, p.instanceSize, avgChans, stats, p);
        [newTargetPosition, bestAngle] = tracker_eval(net_x, round(s_x), scoreId, z_features, x_crops, fuse_targetPosition, window, p);
        targetPosition = gather(newTargetPosition);
        p.init_angle = p.init_angle + bestAngle;
        pwp_search_area = round(p_ch.norm_pwp_search_area / area_resize_factor);
        I1 = uint8(gather(im(:,:,:)));
        patch_padded = getSubwindow(I1, targetPosition, p_ch.norm_bg_area, pwp_search_area); 
        [likelihood_map] = getColourMap(patch_padded, bg_hist, fg_hist, p_ch.n_bins, p_ch.grayscale_sequence);
        likelihood_map(isnan(likelihood_map)) = 0;
        knn_test = likelihood_map(:);
        c = predict(mdl,knn_test); 
        s1 = reshape(c ,p_ch.norm_bg_area); 
        BW1 = gpuArray(s1);
        BW3 = imclose(BW1, strel('disk',3));
        BW3 = imfill(BW3, 'holes');
        imLabel = bwlabel(BW3);
        stats = regionprops(imLabel,'Area');
        area = cat(1,stats.Area);
        index = find(area == max(area));
        BW4 = ismember(imLabel,index);
        BW5 = gather(BW4);
        box_ch1 = imOrientedBox(BW5);
        if p.chengfa
            if i == 2
                last_box_ch1 = box_ch1;
            else 
                ssz_bool = abs(box_ch1([3 4]) - last_box_ch1([3 4])) > p.limit_size;
                if ssz_bool(1) > 0
                    box_ch1(3) = last_box_ch1(3);
                end
                if ssz_bool(2) > 0
                    box_ch1(4) = last_box_ch1(4);
                end
                ppos_bool = abs(box_ch1([1 2]) - last_box_ch1([1 2])) > p.limit_pos;
                if sum(ppos_bool(:)) > 0 
                    box_ch1([2 1]) = size(BW5)./2;
                end
                last_box_ch1 = box_ch1;
            end
        end
        box_ch = [box_ch1([2,1]),box_ch1([3,4,5])];
        center =  p_ch.norm_bg_area / 2;
        pos = (box_ch([1 2]) - center) / area_resize_factor +  targetPosition;
        wh = box_ch([3 4])/area_resize_factor;
        ch_box = [pos wh box_ch(5) + 90];
        fc_box = [targetPosition targetSize p.init_angle];
        if ch_box(3)*ch_box(4)<10
            ch_box=fc_box;
        end
        if isreal(ch_box(1)) && isreal(ch_box(2))
        else
            ch_box=fc_box;
        end
        fuse_box = gaosi_fuse(fc_box,ch_box);
        time_fuse = tic;
        fuse_box_mask_center = (fuse_box([1 2]) - targetPosition) * area_resize_factor + center;
        fuse_box_mask_center = fuse_box_mask_center([2 1]);
        fuse_box_mask_xywha = [fuse_box_mask_center fuse_box([3 4])*area_resize_factor fuse_box(5)-90];
        fc_mask_center = (fc_box([1 2]) - targetPosition) * area_resize_factor + center;
        fc_mask_center = fc_mask_center([2 1]);
        fc_mask_xywha = [fc_mask_center fc_box([3 4])*area_resize_factor fc_box(5)-90];
        ch_box_corner1 = xywha_4corner([ch_box([2,1]),ch_box([4,3]),ch_box(5)]); 
        ch_box_corner(i,:) = reshape(ch_box_corner1',1,10);
        fc_box_corner2 = xywha_4corner([fc_box([2,1]),fc_box([4,3]),fc_box(5)]);
        fc_box_corner(i,:) = reshape(fc_box_corner2',1,10);
        tim(i) = toc(time_fuse);
        fuse_box_corner3 = xywha_4corner([fuse_box([2,1]),fuse_box([4,3]),fuse_box(5)]);
        fuse_box_corner(i,:) = reshape(fuse_box_corner3',1,10);
        fuse_targetPosition = fuse_box([1 2]);
    end
    if i == 1
        f1_tic = tic;
        I1 = uint8(gather(im(:,:,:)));
        patch_padded = getSubwindow(I1, targetPosition, p_ch.norm_bg_area, bg_area);
        new_pwp_model = true;
        [bg_hist, fg_hist] = updateHistModel(new_pwp_model, patch_padded, bg_area, fg_area, p_ch.target_sz, p_ch.norm_bg_area, p_ch.n_bins, p_ch.grayscale_sequence);
        new_pwp_model = false;
        fuse_targetPosition = targetPosition;
        [likelihood_map] = getColourMap(patch_padded, bg_hist, fg_hist, p_ch.n_bins, p_ch.grayscale_sequence);
        likelihood_map(isnan(likelihood_map)) = 0;
        knn_bw = im2bw(likelihood_map,pre_thr);
        knn_training = likelihood_map(:);
        knn_label = knn_bw(:);
        mdl = fitcknn(knn_training, knn_label,'NumNeighbors',k);
        f1_time = toc(f1_tic);
    else
        I1 = uint8(gather(im(:,:,:)));
        patch_padded = getSubwindow(I1, fuse_targetPosition, p_ch.norm_bg_area, bg_area);
        [bg_hist, fg_hist] = updateHistModel(new_pwp_model, patch_padded, bg_area, fg_area, p_ch.target_sz, p_ch.norm_bg_area, p_ch.n_bins, p_ch.grayscale_sequence, bg_hist, fg_hist, p_ch.learning_rate_pwp);
    end
    if i == 1
        f_tic = tic;
        four_corner = xywha_4corner([targetPosition([2,1]), targetSize([2,1]), p.init_angle]);
        points_first = reshape(four_corner',1,10);
        ch_box_corner(i,:) = points_first;
        fc_box_corner(i,:) = points_first;
        fuse_box_corner(i,:) = points_first;
        f_time = toc(f_tic);
    end
    disp(i)
end
    tim_sum = toc(ff);
    time = tim_sum - f_time - f1_time - sum(tim(:)) - sum(tim1(:));
    fps = nImgs/time;
end