clear;close all;clc;

proj = projcrs(26918); % NAD83 / UTM zone 18N
S = shaperead('~/Developments/RDycore-tools/data/delaware/delaware.shp');       
ind = find(isnan(S.X));
xbnd = S.X(1:ind(1)-1)'; ybnd = S.Y(1:ind(1)-1)';

[latbnd,lonbnd] = projinv(proj,xbnd,ybnd);

load('usapolygon.mat');
figure; set(gcf,'Position',[10 10 1000 400]);
axs(1) = subplot(1,5,[1 2 3]);
geoplot(uslat,uslon,'k-','LineWidth',1); hold on;
geoplot(latbnd,lonbnd,'r-','LineWidth',2);
geobasemap 'landcover';

axs(2) = subplot(1,5,[4 5]);
coordx = ncread('~/Developments/RDycore-tools/data/delaware/delaware_30m.exo','coordx'   );
coordy = ncread('~/Developments/RDycore-tools/data/delaware/delaware_30m.exo','coordy'   );
coordz = ncread('~/Developments/RDycore-tools/data/delaware/delaware_30m.exo','coordz'   );
connect = ncread('~/Developments/RDycore-tools/data/delaware/delaware_30m.exo','connect1');
xv = coordx(connect); xc = nanmean(xv,1)';
yv = coordy(connect); yc = nanmean(yv,1)';
zv = coordz(connect); zc = nanmean(zv,1)';
patch(xv,yv,zc,'linestyle','none'); hold on; grid on;
cmap = getPanoply_cMap('GIST_earth');
colormap(cmap); colorbar; set(gca,'ColorScale','log');

plot(xbnd,ybnd,'k-','LineWidth',2); 
xlim([min(xbnd) max(xbnd)]);
ylim([min(ybnd) max(ybnd)]);