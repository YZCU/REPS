function box = gaosi_fuse(box_fc,box_ch)
wucha1 = get_Var(box_fc([3 4 5]));
wucha2 = get_Var(box_ch([3 4 5]));
mu1 = box_fc([1 2]);
mu2 = box_ch([1 2]);
K = wucha1*(wucha1 + wucha2)^(-1);
wucha3 = wucha1 - K * wucha1;
mu3 = mu1 + (mu2 - mu1) * K'; 
function wucha= get_Var(wh_angle)
w = wh_angle(1);
h = wh_angle(2);
angle = wh_angle(3);
R = [cosd(angle) -sind(angle);
     sind(angle) cosd(angle)];
A = [w^2/4 0; 
    0 h^2/4];
wucha = R*A*R'; 
end
function wh_angle = get_wh_angle(wucha)
[mm,nn] = eig(wucha);
angle = atand(mm(2,1)/mm(1,1));
nn = diag(nn);
w_h = 2 * sqrt(nn);
wh_angle = [w_h' angle];
end
wh_angle = get_wh_angle(wucha3); 
wh = wh_angle([1 2]);
if wh(1)>=wh(2)
    wh(1)=wh(1)*1.33;
    wh(2)=wh(2)*1.12;
else
    wh(1)=wh(1)*1.12;
    wh(2)=wh(2)*1.33;
end
box = [mu3 wh wh_angle(1,3)];
end
