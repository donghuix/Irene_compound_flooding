clear;close all;clc;

pop = double(imread('../data/Delaware_Population.tif'));
pop(pop < 0) = NaN;

I = geotiffinfo('../data/Delaware_Population.tif'); 
[x,y]=pixcenters(I);
[lon,lat] = meshgrid(x,y);

proj = projcrs(26918); % NAD83 / UTM zone 18N
% [x,y] = projinv(proj,lon,lat);


coordx = ncread('~/Developments/RDycore-tools/data/delaware/delaware_30m.exo', 'coordx'  );
coordy = ncread('~/Developments/RDycore-tools/data/delaware/delaware_30m.exo', 'coordy'  );
coordz = ncread('~/Developments/RDycore-tools/data/delaware/delaware_30m.exo', 'coordz'  );
connect = ncread('~/Developments/RDycore-tools/data/delaware/delaware_30m.exo','connect1');
xv = coordx(connect);
yv = coordy(connect);
xc      = nanmean(xv,1)';
yc      = nanmean(yv,1)';
[yc,xc] = projinv(proj,xc,yc);

Vq = interp2(fliplr(lon'),fliplr(lat'),fliplr(pop'./1e6),xc,yc);