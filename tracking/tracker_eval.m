% -------------------------------------------------------------------------------------------------------------------------
function [newTargetPosition, bestAngle] = tracker_eval(net_x, s_x, scoreId, z_features, x_crops, targetPosition, window, p)
%TRACKER_STEP哈哈
%   runs a forward pass of the search-region branch of the pre-trained Fully-Convolutional Siamese,
%   reusing the features of the exemplar z computed at the first frame.
%   Luca Bertinetto, Jack Valmadre, Joao F. Henriques, 2016
% -----------------------------------------------------------------
net_x.eval({p.id_feat_z, z_features, 'instance', x_crops});
responseMaps = reshape(net_x.vars(scoreId).value, [p.scoreSize p.scoreSize p.numAngle]);
responseMapsUP = gpuArray(single(zeros(p.scoreSize*p.responseUp, p.scoreSize*p.responseUp, p.numAngle)));
% Choose the scale whose response map has the highest peak
if p.numAngle>=1
    currentScaleID = ceil(p.numAngle/2);
    bestAngle = currentScaleID;
    bestPeak = -Inf;
    for s = 1:p.numAngle
        if p.responseUp > 1
            responseMaps_cpu=gather(responseMaps(:,:,s)); 
            responseMapsUP_cpu=imresize(responseMaps_cpu, p.responseUp);
            responseMapsUP(:,:,s)=gpuArray(responseMapsUP_cpu);
        else
            responseMapsUP(:,:,s) = responseMaps(:,:,s);
        end
        thisResponse = responseMapsUP(:,:,s);
        thisPeak = max(thisResponse(:));
        if thisPeak > bestPeak
            bestPeak = thisPeak;
            bestAngle = s;
        end
    end
    responseMap = responseMapsUP(:,:,bestAngle);
    bestAngle = p.angle_pool(bestAngle);
else
    responseMap = responseMapsUP;
    bestAngle = p.angle_pool(1);
end
responseMap = responseMap - min(responseMap(:));
responseMap = responseMap / sum(responseMap(:));
responseMap = (1-p.wInfluence)*responseMap + p.wInfluence*window;
[r_max, c_max] = find(responseMap == max(responseMap(:)), 1);
[r_max, c_max] = avoid_empty_position(r_max, c_max, p);
p_corr = [r_max, c_max];
cs = gpuArray(cos(deg2rad(p.init_angle + bestAngle)));
sn = gpuArray(sin(deg2rad(p.init_angle + bestAngle)));
zhuan = [cs sn; -sn, cs]';
zhuan_x = zhuan(:,1);
zhuan_y = zhuan(:,2);
% Convert to crop-relative coordinates to frame coordinates
% displacement from the center in instance final representation ...
disp_instanceFinal = p_corr - ceil(p.scoreSize*p.responseUp/2);
% ... in instance input ...
disp_instanceInput = disp_instanceFinal * p.totalStride / p.responseUp;
% ... in instance original crop (in frame coordinates)
disp_instanceFrame = disp_instanceInput * s_x / p.instanceSize;

disp_instanceFrame_x = disp_instanceFrame * zhuan_x;
disp_instanceFrame_y = disp_instanceFrame * zhuan_y;
% 
disp_instanceFrame_final = [disp_instanceFrame_x disp_instanceFrame_y];

% position within frame in frame coordinates
newTargetPosition = targetPosition + disp_instanceFrame_final;
end

function [r_max, c_max] = avoid_empty_position(r_max, c_max, params)
if isempty(r_max)
    r_max = ceil(params.scoreSize/2);
end
if isempty(c_max)
    c_max = ceil(params.scoreSize/2);
end
end
