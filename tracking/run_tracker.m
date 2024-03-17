function run_tracker(video, visualization)
video_name{1}='example';
startup;
params.video = video_name{1};
params.visualization = 1;
params.gpus = 1;
tracker(params);

end