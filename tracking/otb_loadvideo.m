% -------------------------------------------------------------------------------------------------
function imgs= otb_loadvideo(base_path)
	video_path = [base_path '/'];
	%load all jpg files in the folder
	img_files = dir([video_path '*.jpg']);
	assert(~isempty(img_files), 'No image files to load.')
	img_files = sort({img_files.name});
     
	%eliminate frame 0 if it exists, since frames should only start at 1
	img_files(strcmp('00000000.jpg', img_files)) = [];
    img_files = strcat(video_path, img_files);
    imgs = vl_imreadjpeg(img_files,'numThreads', 12);
end

