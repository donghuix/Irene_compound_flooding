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