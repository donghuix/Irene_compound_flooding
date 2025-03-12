clear;close all;clc;

if exist('../data/SLR.mat','file')
    load('../data/SLR.mat');
else
    SLR = struct([]);
    
    lon = ncread('~/OneDrive - PNNL/_MANUSCRIPT/Land-Ocean Coupling/EF/Revision/ar6_gauge.nc','lon');
    lat = ncread('~/OneDrive - PNNL/_MANUSCRIPT/Land-Ocean Coupling/EF/Revision/ar6_gauge.nc','lat');
    sea_level_change = ncread('~/OneDrive - PNNL/_MANUSCRIPT/Land-Ocean Coupling/EF/Revision/ar6_gauge.nc','sea_level_change');
    sea_level_change = nanmean(sea_level_change,3)./1000; % [mm] --> [m]
    
    proj = projcrs(26918); % NAD83 / UTM zone 18N
    S = shaperead('~/Developments/RDycore-tools/data/delaware/delaware.shp');                 
    ind = find(isnan(S.X));
    xbnd = S.X(1:ind(1)-1)'; ybnd = S.Y(1:ind(1)-1)';
    [latbnd,lonbnd] = projinv(proj,xbnd,ybnd);
    
    dist = pdist2([lon lat],[lonbnd latbnd]);
    dist = min(dist,[],2);
    [~,ind] = sort(dist);
    ind = ind(1:4);
    
    
    figure;
    plot(lon(ind),lat(ind),'rx','LineWidth',2); hold on;
    plot(lonbnd,latbnd,'k-','LineWidth',2);
    
    sea_level_change = sea_level_change(ind,:);
    figure;
    for i = 1 : 4
        plot(2015: 10 : 2095,sea_level_change(i,:),'LineWidth',1); hold on; grid on;
        SLR(i).lon = lon(ind(i));
        SLR(i).lat = lat(ind(i));
        SLR(i).slr = sea_level_change(i,:);
        SLR(i).t   = 2015 : 10 : 2095;
    end
    
    save('../data/SLR.mat','SLR');
end

% Read temperature projection
models = {'GFDL-ESM4','IPSL-CM6A-LR','MPI-ESM1-2-HR','MRI-ESM2-0','UKESM1-0-LL'};
fdir   = '/global/cfs/projectdirs/m3780/donghui/lnd-rof-2way-fut/';
foc = NaN(4,9,length(models));
for i = 1 : length(models)
    if i == 5
    fctl = [fdir models{i} '/historical/tas/' lower(models{i}) '_r1i1p1f2_w5e5_historical_tas_global_daily_2011_2014.nc'];
    else
    fctl = [fdir models{i} '/historical/tas/' lower(models{i}) '_r1i1p1f1_w5e5_historical_tas_global_daily_2011_2014.nc'];
    end
    lon  = ncread(fctl,'lon');
    lat  = ncread(fctl,'lat');
    [lon,lat] = meshgrid(lon,lat);
    lon = lon'; lat = lat';
    disp('Mesh size');
    disp(size(lon));

    idx = NaN(4,1);
    for j = 1 : 4
        dist = (lon - SLR(j).lon).^2 + (lat - SLR(j).lat).^2;
        idx(j) = find(dist == min(dist(:)));
        disp(idx(j));
    end
    
    disp('Data size');
    ctl  = nanmean(ncread(fctl,'tas'),3);
    disp(size(ctl));
    
    files = dir([fdir models{i} '/ssp585/tas/*.nc']);
    for j = 1 : length(files)
        fname = fullfile(files(j).folder,files(j).name);
        disp(fname);
        fut   = nanmean(ncread(fname,'tas'),3);
        foc(:,j,i) = fut(idx) - ctl(idx);
    end
end
for j = 1 : 4
    SLR(j).dTa = foc(j,:,:);
end
save('../data/SLR.mat','SLR');



