function points = xywha_4corner_mapping(box)
aff = [];
T = parameters_to_projective_matrix('SIMILARITY',...
    [1, deg2rad(box(5)), box(2), box(1)]);
[aff,~]= getLKcorner(T, [box(3) box(4)]);
aff(:,5)=aff(:,1);
points = [aff(1,1),aff(2,1),aff(1,4),aff(2,4),....
    aff(1,3),aff(2,3),aff(1,2),aff(2,2),aff(1,1),aff(2,1)];
end