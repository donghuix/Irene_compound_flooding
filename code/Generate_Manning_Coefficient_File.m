clear;close all;clc;
addpath('/Users/xudo627/Developments/petsc/share/petsc/matlab/');

analyze_nlcd = true;

mesh      = 'delaware_vrm';
mesh_file = ['../inputdata/' mesh '.exo'];
proj      = projcrs(26918); % NAD83 / UTM zone 18N
fric_file = ['../inputdata/' mesh '_manning.int32.bin'];

coordx    = ncread(mesh_file,'coordx');
coordy    = ncread(mesh_file,'coordy');
connect   = ncread(mesh_file,'connect1');
xv        = coordx(connect);
yv        = coordy(connect);

vals      = [11;    12;    21;    22;    23;    24;    31;    41;    42;    43;    ...
             51;    52;    71;    72;    81;    82;    90;    95];
% https://ascelibrary.org/doi/10.1061/9780784481400.034
manning   = [0.038; 0.038; 0.040; 0.090; 0.120; 0.160; 0.027; 0.150; 0.120; 0.140; ...
             0.038; 0.115; 0.038; 0.038; 0.038; 0.035; 0.098; 0.068];
names     = {'Open Water', 'Snow', 'Developed, Open Space','Developed, Low Intensity',   ...
             'Developed, Medium Intensity','Developed, High Intensity', 'Barren Land',   ...
             'Deciduous Forest', 'Evegreen Forest', 'Mixed Forest', 'Shrub/Scrub',       ...
             'Grassland/Herbaceous', 'Pasture/Hay', 'Cultivated Crops', 'Wood Wetlands', ...
             'Emergent Herbaceous Wetlands'};
if analyze_nlcd
    I = geotiffinfo('../data/delaware_nlcd_proj.tif');
    [x,y] = pixcenters(I);
    [x,y] = meshgrid(x,y);
    nlcd  = imread('../data/delaware_nlcd_proj.tif');
    nlcd  = double(nlcd);
    nlcd(nlcd == 0) = NaN;

    F = griddedInterpolant(fliplr(x'),fliplr(y'),fliplr(nlcd'),'nearest');
    coordx  = ncread('../inputdata/delaware_30m.exo','coordx');
    coordy  = ncread('../inputdata/delaware_30m.exo','coordy');
    connect = ncread('../inputdata/delaware_30m.exo','connect1');
    xv      = coordx(connect);
    yv      = coordy(connect);
    xc      = nanmean(xc,1)';
    yc      = nanmean(yc,1)';
    [yc,xc] = projinv(proj,xc,yc);
    
    nlcd_mesh = F(xc,yc);

    figure;
    patch(xv,yv,nlcd_mesh,'linestyle','none'); colorbar;
    
    vals([2 11 14])  = [];
    names([2]) = [];

    ns = NaN(length(vals),1);
    for i = 1 : length(vals)
        disp(i);
        ind = find(nlcd_mesh == vals(i));
        ns(i) = length(ind);
    end
    figure;
    barh(ns./length(xc).*100); hold on; grid on;
    yticklabels(names);
    set(gca,'FontSize',18,'FontWeight','bold');

end

if exist(fric_file,'file')
    nc = PetscBinaryRead(fric_file);
else
    I = geotiffinfo('../data/delaware_nlcd_proj.tif');
    [x,y] = pixcenters(I);
    [x,y] = meshgrid(x,y);
    nlcd  = imread('../data/delaware_nlcd_proj.tif');
    nlcd  = double(nlcd);
    nlcd(nlcd == 0) = NaN;
   
    for i = 1 : length(vals)
        nlcd(nlcd == vals(i)) = manning(i);
    end
    
    xc = mean(xv)';
    yc = mean(yv)';
    
    [yc,xc] = projinv(proj,xc,yc);
    
    F = griddedInterpolant(fliplr(x'),fliplr(y'),fliplr(nlcd'));
    nc = F(xc,yc);
    
    figure;
    imagesc([x(1) x(end)],[y(1) y(end)],nlcd); hold on;
    title('NLCD','FontSize',18,'FontWeight','bold');
    set(gca,'YDir','normal');
    
    ind = find(isnan(nc));
    if ~isnan(ind)
        error('There are NaNs in the manning file!');
    end
    PetscBinaryWrite(fric_file,nc,'indices','int32');
end

figure;
patch(xv,yv,nc,'LineStyle','none');
title('RDycore manning file','FontSize',18,'FontWeight','bold');