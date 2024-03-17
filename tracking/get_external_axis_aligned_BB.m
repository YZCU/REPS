% -------------------------------------------------------------------------------------------------
function [cx, cy, w, h] = get_axis_aligned_BB(region)
%GETAXISALIGNEDBB computes axis-aligned bbox with same area as the rotated one (REGION)
% -------------------------------------------------------------------------------------------------
nv = numel(region);
assert(nv==8 || nv==4);

if nv==8 
    cx = mean(region(1:2:end));
    cy = mean(region(2:2:end));
    x1 = min(region(1:2:end));
    x2 = max(region(1:2:end));
    y1 = min(region(2:2:end));
    y2 = max(region(2:2:end));
    w = (x2 - x1) + 1;
    h = (y2 - y1) + 1;
else
    x = region(1);
    y = region(2);
    w = region(3);
    h = region(4);
    cx = x+w/2;
    cy = y+h/2;
end
