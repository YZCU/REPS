clear,close all;
base_path = 'data_path\'; % data_path 
if ispc(), base_path = strrep(base_path, '\', '/'); end
if base_path(end) ~= '/',  base_path(end+1) = '/'; end
contents = dir(base_path);
names = { };
for k = 1:numel(contents)
    name =  contents(k).name;
    if isdir([base_path name]) && ~strcmp(name, '.') && ~strcmp(name, '..')
        names{end+1} = name; 
    end
end
if isempty(names), video_path = []; return; end
choice = listdlg('ListString',names, 'Name','Choose video', 'SelectionMode','multiple');
if isempty(choice), return;  end
seq_num=length(choice);
startup;
params_fc.gpus = 1;
params = readParams('params.txt');
for s = 1:seq_num  
    params_fc.video = names{choice(s)}; 
    [affs,fps] = tracker(params_fc, params); % Main tracking
    results = {};
    results{1,1}.type = '4corner';
    results{1,1}.res = affs;
    results{1,1}.fps = fps;
    results{1,1}.annoBegin = 1;
    results{1,1}.len = size(affs,1);
    results{1,1}.startFrame = 1;
    save(['.\results\' names{choice(s)} '_' 'REPS' '.mat'], 'results'); 
    close all
end


