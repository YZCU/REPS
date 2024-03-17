function [imgs, pos, target_sz] = load_video_info(base_path, video)
	if base_path(end) ~= '/' && base_path(end) ~= '\',
		base_path(end+1) = '/';
	end
	video_path = [base_path video '\img\'];
    f = fopen([base_path video '\' 'groundtruth.txt']);
    try
        ground_truth = textscan(f, '%f,%f,%f,%f,%f,%f,%f,%f', 'ReturnOnError',false);
    catch  % #ok, try different format (no commas)
        frewind(f);
        ground_truth = textscan(f, '%f %f %f %f %f %f %f %f');
    end
    ground_truth = cat(2, ground_truth{:});  % 8²ÎÊýGT
	fclose(f);
    region = ground_truth(1, :);
    [cx, cy, w, h] = get_external_axis_aligned_BB(region);
    pos = [cy cx];
    target_sz = [h w];

	%load all jpg files in the folder
	img_files = dir([video_path '*.jpg']);
	assert(~isempty(img_files), 'No image files to load.')
	img_files = sort({img_files.name});

	%eliminate frame 0 if it exists, since frames should only start at 1
    try
        img_files(strcmp('00000.jpg', img_files)) = [];
    catch  % #ok, try different format (no commas)
        img_files(strcmp('000.jpg', img_files)) = [];
    end
    %
    img_files = strcat(video_path, img_files);
    % read all frames at once
%     imgs = cellstr(img_files);
    imgs = vl_imreadjpeg(img_files,'numThreads', 12);
    
end
