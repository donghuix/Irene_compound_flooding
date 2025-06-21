clear;close all;clc;

cmap = getPanoply_cMap('NEO_modis_lst');

addpath('/Users/xudo627/Developments/getPanoply_cMap/');
coordx = ncread('~/Developments/RDycore-tools/data/delaware/delaware_30m.exo','coordx'   );
coordy = ncread('~/Developments/RDycore-tools/data/delaware/delaware_30m.exo','coordy'   );
coordz = ncread('~/Developments/RDycore-tools/data/delaware/delaware_30m.exo','coordz'   );
connect = ncread('~/Developments/RDycore-tools/data/delaware/delaware_30m.exo','connect1');
xv = coordx(connect); xc = nanmean(xv,1)';
yv = coordy(connect); yc = nanmean(yv,1)';

surge    = load('../data/Max_Height_OnlyBC.mat'     );
runoff   = load('../data/Max_Height_AMC_75_noBC.mat');
compound = load('../data/Max_Height_Manning025.mat' );

xmin = 4.30*1e5;
xmax = 5.15*1e5;
ymin = 4.28*1e6;
ymax = 4.44*1e6;
in = find(yc >= ymin & yc <= ymax & xc <= xmax & xc >= xmin);

dd = compound.max_height - surge.max_height - runoff.max_height;
figure;
patch(xv(:,in),yv(:,in), dd(in),'linestyle','none'); hold on; colormap( blue2red(11) );
clim([-2 2]); colorbar;

figure;
patch(xv(:,in),yv(:,in), surge.max_height(in),'linestyle','none'); hold on; colormap( cmap );
clim([0 10]); colorbar;