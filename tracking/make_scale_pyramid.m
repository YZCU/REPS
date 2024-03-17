% -----------------------------------------------------------------------------------------------------
function pyramid = make_scale_pyramid(im, targetPosition, in_side_scaled, out_side, avgChans, stats, p)
%MAKE_SCALE_PYRAMID
%   computes a pyramid of re-scaled copies of the target (centered on TARGETPOSITION)
%   and resizes them to OUT_SIDE. If crops exceed image boundaries they are padded with AVGCHANS.
%
%   Luca Bertinetto, Jack Valmadre, Joao F. Henriques, 2016
% -----------------------------------------------------------------------------------------------------
    in_side_scaled = round(in_side_scaled);
    pyramid = gpuArray(zeros(out_side, out_side, 3, p.numAngle, 'single'));
    for a = 1:p.numAngle
        ang = p.init_angle + p.angle_pool(a);
        im_rot1 = get_pixels(im, targetPosition, in_side_scaled, deg2rad(ang));
        im_rot2 = single(im_rot1);
        im_patch = imresize(im_rot2, out_side/in_side_scaled); 
        pyramid(:,:,:,a) = get_rot_subwindow_tracking(im_patch, (1+out_side*[1 1])/2, [out_side out_side], out_side*[1 1], avgChans);
    end
end