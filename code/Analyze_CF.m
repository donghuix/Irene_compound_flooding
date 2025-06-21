clear;close all;clc;

load('../data/Max_Height_050.mat');
load('../data/mindist_to_ocean.mat');

figure;
k = 1;

thre  = 1000 : 1000 : 200 * 1000;
hdist = NaN(length(thre),1);
coordx = ncread('~/Developments/RDycore-tools/data/delaware/delaware_30m.exo','coordx');
coordy = ncread('~/Developments/RDycore-tools/data/delaware/delaware_30m.exo','coordy');
coordz = ncread('~/Developments/RDycore-tools/data/delaware/delaware_30m.exo','coordz');
connect = ncread('~/Developments/RDycore-tools/data/delaware/delaware_30m.exo','connect1');
xv = coordx(connect);
yv = coordy(connect);
zv = coordz(connect);
zc = nanmean(zv,1)';
dzdx = ((yv(3,:) - yv(1,:)).*(zv(2,:) - zv(1,:)) - (yv(2,:) - yv(1,:)).*(zv(3,:) - zv(1,:))) ./ ...
       ((yv(3,:) - yv(1,:)).*(xv(2,:) - xv(1,:)) - (yv(2,:) - yv(1,:)).*(xv(3,:) - xv(1,:)));
dzdy = (- (xv(3,:) - xv(1,:)).*(zv(2,:) - zv(1,:)) + (xv(2,:) - xv(1,:)).*(zv(3,:) - zv(1,:))) ./ ...
       ((yv(3,:) - yv(1,:)).*(xv(2,:) - xv(1,:)) - (yv(2,:) - yv(1,:)).*(xv(3,:) - xv(1,:)));
dz   = sqrt(dzdx.^2 + dzdy.^2);

for i = 1 : length(thre)
    if i == 1
        idx = find(mindist_to_ocean <= thre(i));
    else
        idx = find(mindist_to_ocean > thre(i-1) & mindist_to_ocean <= thre(i));
    end
    tmp = max_height(idx);
    tmp(tmp > 5) = NaN;
    hdist(i) = nanmean(tmp);
    fdist(i) = length(find(tmp>0.12))/length(tmp);
    tmp2 = zc(idx);
    zdist(i) = nanmean(tmp2);
    tmp3 = dz(idx);
    cdist(i) = nanmean(tmp3);
end
figure;
subplot(2,2,1);
plot(thre,hdist,'kx-','linewidth',1); hold on; grid on;
subplot(2,2,2);
plot(thre,fdist,'kx-','linewidth',1); hold on; grid on;
subplot(2,2,3);
plot(thre,zdist,'kx-','linewidth',1); hold on; grid on;
subplot(2,2,4);
plot(thre,cdist,'kx-','linewidth',1); hold on; grid on;
