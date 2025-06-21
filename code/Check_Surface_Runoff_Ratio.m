clear;close all;clc;

xc = ncread('../data/domain_mid_atlantic_c240907.nc','xc');
yc = ncread('../data/domain_mid_atlantic_c240907.nc','yc');

proj = projcrs(26918); % NAD83 / UTM zone 18N
S = shaperead('~/Developments/RDycore-tools/data/delaware/delaware.shp');       
ind = find(isnan(S.X));
xbnd = S.X(1:ind(1)-1)'; ybnd = S.Y(1:ind(1)-1)';
[latbnd,lonbnd] = projinv(proj,xbnd,ybnd);
lonbnd = lonbnd + 360;

for i = [0 75] %: 25 : 100
    disp(i);
    load(['../elm/outputs/AMC_' num2str(i) '_runoff.mat']);
    %rain    = rain % [mm/day]
    infl    = infl    .* 86400;
    qrunoff = qrunoff .* 3600; 
    qdrai   = qdrai   .* 3600; 
    qover   = qrunoff - qdrai;
    
    figure;
    for j = 1 : 8
        subplot(4,2,j);
        imagesc([xc(1,1) xc(end,end)],[yc(1,1) yc(end,end)],qover(:,:,j)'./qrunoff(:,:,j)'); hold on;
        plot(lonbnd,latbnd,'r-','LineWidth',2); colorbar; colormap(jet(10));
        set(gca,'YDir','normal');
        xlim([min(lonbnd) max(lonbnd)]);
        ylim([min(latbnd) max(latbnd)]);
    end
    sgtitle(['ratio AMC ' num2str(i)]);

    figure;
    for j = 1 : 8
        subplot(4,2,j);
        imagesc([xc(1,1) xc(end,end)],[yc(1,1) yc(end,end)],surf(:,:,j)'); hold on;
        plot(lonbnd,latbnd,'r-','LineWidth',2); colorbar; colormap(jet(10));
        set(gca,'YDir','normal');
        xlim([min(lonbnd) max(lonbnd)]);
        ylim([min(latbnd) max(latbnd)]);
    end
    sgtitle(['surf AMC ' num2str(i)]);

    figure;
    for j = 1 : 8
        subplot(4,2,j);
        imagesc([xc(1,1) xc(end,end)],[yc(1,1) yc(end,end)],nanmean(rain(:,:,(j-1).*24+1:j*24),3)'); hold on;
        plot(lonbnd,latbnd,'r-','LineWidth',2); colorbar; colormap(jet(10)); clim([0 200]);
        set(gca,'YDir','normal');
        xlim([min(lonbnd) max(lonbnd)]);
        ylim([min(latbnd) max(latbnd)]);
    end
    sgtitle(['rain AMC ' num2str(i)]);

    figure;
    for j = 1 : 8
        subplot(4,2,j);
        imagesc([xc(1,1) xc(end,end)],[yc(1,1) yc(end,end)],qrunoff(:,:,j)'); hold on;
        plot(lonbnd,latbnd,'r-','LineWidth',2); colorbar; colormap(jet(10)); clim([0 200]);
        set(gca,'YDir','normal');
        xlim([min(lonbnd) max(lonbnd)]);
        ylim([min(latbnd) max(latbnd)]);
    end
    sgtitle(['runoff AMC ' num2str(i)]);

    figure;
    for j = 1 : 8
        subplot(4,2,j);
        imagesc([xc(1,1) xc(end,end)],[yc(1,1) yc(end,end)],infl(:,:,j)'); hold on;
        plot(lonbnd,latbnd,'r-','LineWidth',2); colorbar; colormap(jet(10));
        set(gca,'YDir','normal'); clim([0 200]);
        xlim([min(lonbnd) max(lonbnd)]);
        ylim([min(latbnd) max(latbnd)]);
    end
    sgtitle(['infl AMC ' num2str(i)]);
end