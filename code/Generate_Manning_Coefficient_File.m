clear;close all;clc;
addpath('/Users/xudo627/Developments/petsc/share/petsc/matlab/');

mesh      = 'delaware_vrm';
mesh_file = ['../inputdata/' mesh '.exo'];
proj      = projcrs(26918); % NAD83 / UTM zone 18N
fric_file = ['../inputdata/' mesh '_manning.int32.bin'];

coordx    = ncread(mesh_file,'coordx');
coordy    = ncread(mesh_file,'coordy');
connect   = ncread(mesh_file,'connect1');
xv        = coordx(connect);
yv        = coordy(connect);

if exist(fric_file,'file')
    nc = PetscBinaryRead(fric_file);
else
    I = geotiffinfo('../data/delaware_nlcd_proj.tif');
    [x,y] = pixcenters(I);
    [x,y] = meshgrid(x,y);
    nlcd  = imread('../data/delaware_nlcd_proj.tif');
    nlcd  = double(nlcd);
    nlcd(nlcd == 0) = NaN;
    vals    = [11;12;21;22;23;24;31;41;42;43;51;52;71;72;81;82;90;95];
    manning = [0.038; 0.038; 0.040; 0.090; 0.120; 0.160; 0.027; 0.150; 0.120; 0.140; ...
                   0.038; 0.115; 0.038; 0.038; 0.038; 0.035; 0.098; 0.068];
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