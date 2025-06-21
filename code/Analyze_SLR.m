clear;close all;clc;

if exist('../data/SLR.mat','file')
    load('../data/SLR.mat');
    proj = projcrs(26918); % NAD83 / UTM zone 18N
    S = shaperead('~/Developments/RDycore-tools/data/delaware/delaware.shp');                 
    ind = find(isnan(S.X));
    xbnd = S.X(1:ind(1)-1)'; ybnd = S.Y(1:ind(1)-1)';
    [latbnd,lonbnd] = projinv(proj,xbnd,ybnd);

else
    SLR = struct([]);
    
    lon = ncread('~/OneDrive - PNNL/_MANUSCRIPT/Land-Ocean Coupling/EF/Revision/ar6_gauge.nc','lon');
    lat = ncread('~/OneDrive - PNNL/_MANUSCRIPT/Land-Ocean Coupling/EF/Revision/ar6_gauge.nc','lat');
    sea_level_change = ncread('~/OneDrive - PNNL/_MANUSCRIPT/Land-Ocean Coupling/EF/Revision/ar6_gauge.nc','sea_level_change');
    sea_level_change = nanmean(sea_level_change,3)./1000; % [mm] --> [m]
    
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
end

figure;
plot(nanmean(SLR(1).dTa,3),SLR(1).slr,'bx','LineWidth',2); hold on; grid on;
plot(nanmean(SLR(2).dTa,3),SLR(2).slr,'ro','LineWidth',2);
plot(nanmean(SLR(3).dTa,3),SLR(3).slr,'m+','LineWidth',2);
plot(nanmean(SLR(4).dTa,3),SLR(4).slr,'k*','LineWidth',2);
set(gca,'FontSize',15);
ylabel('SLR [m]','FontSize',20,'FontWeight','bold');
xlabel('Temperature increase','FontSize',20,'FontWeight','bold');

for i = 1 : 4
    dTa(:,i) = nanmean(SLR(i).dTa,3);
    slr(:,i) = nanmean(SLR(i).slr,3);
end

for i = 1 : 5
    s(i,1) = interp1(nanmean(dTa,2),nanmean(slr,2),i);
end


% addpath('/Users/xudo627/Developments/petsc/share/petsc/matlab/');
% coord = PetscBinaryRead('../boundary/baseline/boundary_x_y.int32.bin');
% for i = 1 : 5
%     copyfile('../boundary/baseline/boundary_x_y.int32.bin',['../boundary/slr' num2str(i)]);
% end
% coord = reshape(coord(3:end),[coord(1),2]);
% x     = coord(:,1);
% y     = coord(:,2);
% figure;
% plot(x,y,'k.'); hold on;
% plot(xbnd,ybnd,'r-','LineWidth',2);
% 
% files = dir('../boundary/baseline/2011*.bin');
% for i = 1 : length(files)
%     fname = fullfile(files(i).folder,files(i).name);
%     data  = PetscBinaryRead(fname);
%     numc  = data(1);
%     data  = reshape(data(3:end),[3 data(1)]);
%     if i == 1
%         h = NaN(size(data,2),length(files));
%         h(:,1) = data(1,:);
%     else
%         h(:,i) = data(1,:);
%     end
%     for j = 1 : 5
%         tmp = data;
%         tmp(1,:) = tmp(1,:) + s(j);
%         PetscBinaryWrite(['../boundary/slr' num2str(j) '/' files(i).name],[numc; 3; tmp(:)],'indices','int32');
%     end
% 
% end
% 
% figure;
% scatter(x,y,36,max(h,[],2),'filled'); colormap(jet); colorbar;clim([0 1]);
% 
% coordx = ncread('~/Developments/RDycore-tools/data/delaware/delaware_30m.exo','coordx');
% coordy = ncread('~/Developments/RDycore-tools/data/delaware/delaware_30m.exo','coordy');
% connect = ncread('~/Developments/RDycore-tools/data/delaware/delaware_30m.exo','connect1');
% xv = coordx(connect); xc = nanmean(xv,1)';
% yv = coordy(connect); yc = nanmean(yv,1)';
% 
% figure;
% plot([SLR(:).lon],[SLR(:).lat],'rx','LineWidth',4); hold on; grid on;
% plot(lonbnd,latbnd,'k-','LineWidth',1);

