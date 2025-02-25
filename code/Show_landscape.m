clear;close all;clc;

vals      = [11;    12;    21;    22;    23;    24;    31;    41;    42;    43;    ...
             51;    52;    71;    72;    81;    82;    90;    95];
% https://ascelibrary.org/doi/10.1061/9780784481400.034
manning   = [0.038; 0.038; 0.040; 0.090; 0.120; 0.160; 0.027; 0.150; 0.120; 0.140; ...
             0.038; 0.115; 0.038; 0.038; 0.038; 0.035; 0.098; 0.068];
names     = {'Open Water', 'Perennial Ice/Snow', 'Developed, Open Space','Developed, Low Intensity',   ...
             'Developed, Medium Intensity','Developed, High Intensity', 'Barren Land',   ...
             'Deciduous Forest', 'Evegreen Forest', 'Mixed Forest', 'Dwarf Scrub', 'Shrub/Scrub',       ...
             'Grassland/Herbaceous', 'Sedge/Herbaceous', 'Pasture/Hay', 'Cultivated Crops', 'Wood Wetlands', ...
             'Emergent Herbaceous Wetlands'};

proj = projcrs(26918); % NAD83 / UTM zone 18N

if exist('../data/nlcd_mesh.mat','file')
    load('../data/nlcd_mesh.mat');
else
    I = geotiffinfo('../data/delaware_nlcd_proj.tif');
    [x,y] = pixcenters(I);
    [x,y] = meshgrid(x,y);
    nlcd  = imread('../data/delaware_nlcd_proj.tif');
    nlcd  = double(nlcd);
    nlcd(nlcd == 0) = NaN;
    
    F = griddedInterpolant(fliplr(x'),fliplr(y'),fliplr(nlcd'),'nearest');
    coordx  = ncread('../inputdata/delaware_30m.exo','coordx');
    coordy  = ncread('../inputdata/delaware_30m.exo','coordy');
    coordz  = ncread('../inputdata/delaware_30m.exo','coordz');
    connect = ncread('../inputdata/delaware_30m.exo','connect1');
    xv      = coordx(connect);
    yv      = coordy(connect);
    zv      = coordz(connect);
    xc      = nanmean(xv,1)';
    yc      = nanmean(yv,1)';
    zc      = nanmean(zv,1)';
    [yc,xc] = projinv(proj,xc,yc);
    
    nlcd_mesh = F(xc,yc);
    
    save('../data/nlcd_mesh.mat','nlcd_mesh');
end

% figure;
% patch(xv,yv,nlcd_mesh,'linestyle','none'); colorbar;
irm = [1 2 7 11 12 13 14 17 18];
vals(irm)     = [];
manning(irm)  = [];
names(irm)    = [];

load('/Users/xudo627/Projects/Irene/ELM1k/AMC_50.mat');
qrunoff = nansum(qrunoff,3);
qrunoff(qrunoff > 1000 | qrunoff < 0) = NaN;
elmlonc = ncread('/Users/xudo627/Projects/Irene/ELM1k/domain_mid_atlantic_c240907.nc','xc');
elmlatc = ncread('/Users/xudo627/Projects/Irene/ELM1k/domain_mid_atlantic_c240907.nc','yc');

% [lat,lon] = projinv(proj,xc,yc);
% 
F = griddedInterpolant(elmlonc,elmlatc,qrunoff,'nearest');
runoff_mesh = F(xc,yc);


h1 = h5read('../outputs/Manning_025/Delaware_30m.OceanDirichletBC-2160000.h5','/2160000 5.400000E+05 sec/0');
h2 = h5read('../outputs/AMC_50/Delaware_30m.OceanDirichletBC-2160000.h5','/2160000 5.400000E+05 sec/0');
h = h2 - h1;
nlcd_height = NaN(length(vals),2);
nlcd_ele    = NaN(length(vals),2);
nlcd_perc   = NaN(length(vals),2);
nlcd_runoff = NaN(length(vals),2);

for i = 1 : length(vals)
    disp(i);
    ind = find(nlcd_mesh == vals(i));
    nlcd_runoff(i,1) = nanmean(runoff_mesh(ind));
    nlcd_height(i,1) = nanmean(h1(ind));
    nlcd_height(i,2) = nanmean(h2(ind));
    nlcd_ele(i,1)    = nanmean(zc(ind));
    nlcd_ele(i,2)    = nanstd(zc(ind));
    nlcd_perc(i,1)   = length(ind)/length(nlcd_mesh).*100;

    tmp = h1(ind);
    nlcd_perc(i,2)   = length(find(tmp > 0.12)) / length(tmp) * 100;
end

figure; set(gcf,'Position',[10 10 1200 500]);
axs(1) = subplot(1,3,1);
barh(1:length(vals),nlcd_perc(:,1)); hold on; grid on;
yticklabels(names);
set(gca,'FontSize',18,'FontWeight','bold');
title('NLCD percentage in Delaware','FontSize',18,'FontWeight','bold');


axs(2) = subplot(1,3,2);
barh(1:length(vals),nlcd_height(:,2),0.5);hold on; grid on;
barh(1:length(vals),nlcd_height(:,1)); %hold on; grid on;
yticklabels('');
set(gca,'XScale','log');
set(gca,'FontSize',18,'FontWeight','bold');
title('Average inundation depth [m]','FontSize',18,'FontWeight','bold');

axs(3) = subplot(1,3,3);
%barh(1:length(vals),nlcd_ele(:,2)./nlcd_ele(:,1)); hold on; grid on;
barh(1:length(vals),nlcd_perc(:,2)); hold on; grid on;
yticklabels('');
set(gca,'FontSize',18,'FontWeight','bold');
title('Percentage with depth > ankle height','FontSize',18,'FontWeight','bold');
set(gca,'XScale','log');

axs(1).Position(1) = 0.25;
axs(1).Position(3) = 0.2;
axs(2).Position(1) = axs(1).Position(1) + axs(1).Position(3) +0.03;
axs(2).Position(3) = 0.2;
axs(3).Position(1) = axs(2).Position(1) + axs(2).Position(3) + 0.03;

figure;
for i = 2 : 5
    ind = find(nlcd_mesh == vals(i));
    tmp = zc(ind);
    [f,xi] = ksdensity(tmp);
    plot(xi,f,'-','LineWidth',2); hold on;
end
legend(names([2 3 4 5]));

figure;
barh(1:length(vals),nlcd_runoff(:,1)); hold on; grid on;
yticklabels('');
set(gca,'FontSize',18,'FontWeight','bold');
title('Runoff [m]','FontSize',18,'FontWeight','bold');

figure; set(gcf,'Position',[10 10 1200 500]);
axs(1) = subplot(1,3,1);
barh(1:length(vals),nlcd_height(:,1)); hold on; grid on;
yticklabels(names);
%set(gca,'XScale','log');
set(gca,'FontSize',18,'FontWeight','bold');
title('Average inundation depth [m]','FontSize',18,'FontWeight','bold');

axs(2) = subplot(1,3,2);
barh(1:length(vals),nlcd_runoff(:,1).*3600); hold on; grid on;
yticklabels('');
set(gca,'FontSize',18,'FontWeight','bold');
title('Runoff [mm]','FontSize',18,'FontWeight','bold');

axs(3) = subplot(1,3,3);
barh(1:length(vals),nlcd_ele(:,1)); hold on; grid on;
yticklabels('');
%set(gca,'XScale','log');
set(gca,'FontSize',18,'FontWeight','bold');
title('Average elevation [m]','FontSize',18,'FontWeight','bold');

%set(gca,'XScale','log');

axs(1).Position(1) = 0.25;
axs(1).Position(3) = 0.2;
axs(2).Position(1) = axs(1).Position(1) + axs(1).Position(3) +0.03;
axs(2).Position(3) = 0.2;
axs(3).Position(1) = axs(2).Position(1) + axs(2).Position(3) + 0.03;

exportgraphics(gcf,['./Figure_NLCD.jpg'],'Resolution',400);

figure;
plot(nlcd_ele([1 2 3 4],1), nlcd_height([1 2 3 4],1),'bx','LineWidth',2); hold on; grid on;
