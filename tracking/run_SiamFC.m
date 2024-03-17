function results=run_SiamFC(seq, res_path, bSaveImage)
addpath('/home/ubuntu/visual_tracker_benchmark/trackers/SiamFC');
startup;
params.visualization = 0;
params.gpus = 1;
params.s_frames=otb_loadvideo(seq.path);
params.wsize = [seq. init_rect(1,4), seq.init_rect(1,3)];
params.init_pos = [seq.init_rect(1,2), seq.init_rect(1,1)] + floor(params.wsize/2);
fps=0;
[rect_position,fps]=otb_tracker(params);   
results.type = 'rect';
results.res = rect_position;
results.fps = fps;
display([' fps:' num2str(results.fps)]);

