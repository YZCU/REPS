function  box_out = xywha_4corner(box)
cx  = box(:,1);
cy  = box(:,2);
hl   = box(:,3) / 2;
hw   = box(:,4) / 2;
theta = box(:,5);
cot = cosd(theta(1));
sit = sind(theta(1));
lc = hl(1) * cot;
ls = hl(1) * sit;
wc = hw(1) * cot;
ws = hw(1) * sit;
vx = cx(1) + [-lc + ws; lc + ws ; lc - ws ; -lc - ws ; -lc + ws];
vy = cy(1) + [-ls - wc; ls - wc ; ls + wc ; -ls + wc ; -ls - wc];
box_out = [vx, vy];
end