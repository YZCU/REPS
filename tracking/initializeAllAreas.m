function [params, bg_area, fg_area, area_resize_factor] = initializeAllAreas(im, params)
    bg_area = round(params.target_sz * params.padding);
    fg_area = round(params.target_sz * params.inner_padding) ; 
	% saturate to image size
	if(bg_area(2)>size(im,2)), bg_area(2)=size(im,2)-1; end
	if(bg_area(1)>size(im,1)), bg_area(1)=size(im,1)-1; end
	% make sure the differences are a multiple of 2 (makes things easier later in color histograms)
	bg_area = bg_area - mod(bg_area - params.target_sz, 2);
	fg_area = fg_area + mod(bg_area - fg_area, 2);
	area_resize_factor = sqrt(params.fixed_area/prod(bg_area));
	params.norm_bg_area = round(bg_area * area_resize_factor);
 	norm_target_sz_w = 0.75*params.norm_bg_area(2) - 0.25*params.norm_bg_area(1);
 	norm_target_sz_h = 0.75*params.norm_bg_area(1) - 0.25*params.norm_bg_area(2);
    params.norm_target_sz = round([norm_target_sz_h norm_target_sz_w]);
	% distance (on one side) between target and bg area
	norm_pad = floor((params.norm_bg_area - params.norm_target_sz) / 2);
	radius = min(norm_pad);
	params.norm_delta_area = (2*radius+1) * [1, 1];
	% Rectangle in which the integral images are computed.
	% Grid of rectangles ( each of size norm_target_sz) has size norm_delta_area.
	params.norm_pwp_search_area = params.norm_target_sz + params.norm_delta_area - 1;
end
