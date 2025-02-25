clear;close all;clc;

proj = projcrs(26918); % NAD83 / UTM zone 18N
rivers = shaperead('/Users/xudo627/Developments/RDycore-tools/data/delaware/hydrorivers.shp');
load('../data/usgs_with_sim.mat');

proj = projcrs(26918); % NAD83 / UTM zone 18N
S = shaperead('~/Developments/RDycore-tools/data/delaware/delaware.shp');                 
ind = find(isnan(S.X));
xbnd = S.X(1:ind(1)-1)'; ybnd = S.Y(1:ind(1)-1)';
[latbnd,lonbnd] = projinv(proj,xbnd,ybnd);

obs = NaN(length(sites),1);
sim = NaN(length(sites),1);

addpath('/Users/xudo627/Developments/mylib/m');

coordx = ncread('~/Developments/RDycore-tools/data/delaware/delaware_30m.exo','coordx');
coordy = ncread('~/Developments/RDycore-tools/data/delaware/delaware_30m.exo','coordy');
coordz = ncread('~/Developments/RDycore-tools/data/delaware/delaware_30m.exo','coordz');
connect = ncread('~/Developments/RDycore-tools/data/delaware/delaware_30m.exo','connect1');
xv = coordx(connect);
yv = coordy(connect);
zv = coordz(connect);

t1 = datenum(2011,8,26,0,0,0);
t2 = datenum(2011,9,4,23,0,0);
t  = t1 : 6/24 : t2;

ngrid = 5000;
[yrs,mos,das,hrs] = datevec(t);
for i = 1 : length(sites)
    

    dn     = sites(i).dn;
    dq     = sites(i).dq;
    hh     = NaN(length(t),1);
    [yr1,mo1,da1,hr1] = datevec(dn);
    for j = 1 : length(t)
        ind = find(yr1 == yrs(j) & mo1 == mos(j) & da1 == das(j) & hr1 == hrs(j));
        if ~isempty(ind)
            hh(j) = nanmean(dq(ind(end)));
        end
    end
    sites(i).hh = hh;
    obs(i) = max(hh);
    tmp    = max(sites(i).sim,[],1);
    error  = abs(tmp(1:ngrid) - obs(i));
    ind    = find(error == min(error));
    sites(i).idxbest = ind(1);
    
    tmpNSE = NaN(ngrid,1);
    for j = 1 : ngrid
        [~,~,tmpNSE(j)] = estimate_evaluation_metric(hh,sites(i).sim(2:end,j));
    end
    sites(i).idxbest = find(tmpNSE == max(tmpNSE));
    sites(i).idxbest = sites(i).idxbest(1);

    sim(i) = tmp(sites(i).idxbest);

    [sites(i).R2,~,sites(i).NSE] = estimate_evaluation_metric(hh,sites(i).sim(2:end,sites(i).idxbest));
    
    
end

figure;
scatter([sites(:).x],[sites(:).y],36,sim - obs,'filled'); colormap(flipud(blue2red(11)));
colorbar;
clim([-2 2]);

error = abs(sim - obs);
ind   = find(error == max(error));

ind = 88;
tmpxv = xv(:,sites(ind).idx(1:ngrid));
tmpyv = yv(:,sites(ind).idx(1:ngrid));
tmpxc = nanmean(xv(:,sites(ind).idx(1:ngrid)),1);
tmpyc = nanmean(yv(:,sites(ind).idx(1:ngrid)),1);
tmpzc = nanmean(zv(:,sites(ind).idx(1:ngrid)),1);
figure;
subplot(1,2,1);
patch(tmpxv,tmpyv,tmpzc,'linestyle','none'); colorbar; hold on; grid on;
plot(tmpxc(sites(ind).idxbest),tmpyc(sites(ind).idxbest),'rx','LineWidth',2);
plot(sites(ind).x,sites(ind).y,'gd','LineWidth',2);
subplot(1,2,2);
plot(sites(ind).hh,'k-','LineWidth',2); hold on
plot(sites(ind).sim(2:end,sites(ind).idxbest),'b-','LineWidth',2);


error = (sim - obs)./obs .* 100;

figure;
plot(obs,sim,'bx'); hold on; grid on;
xlabel('Gauge Maximum Height','FontSize',15,'FontWeight','bold');
ylabel('Simulated Maximum Height','FontSize',15,'FontWeight','bold');
plot([0 9],[0 9],'r-','LineWidth',2); 
set(gca,'ColorScale','log');

figure;
semilogx([sites(:).area],[sites(:).R2],'bx'); hold on;

[~,~,R2] = LSE(obs,sim);
sqrt(R2);

[lat,lon] = projinv(proj,[sites(:).x],[sites(:).y]);
figure; set(gcf,'Position',[10 10 700 800]);
scatter(lon,lat,72,sqrt([sites(:).R2]),'filled','MarkerEdgeColor','k'); 
clim([0 1]); colormap(jet(10)); hold on; colorbar('FontSize',15);
plot(lonbnd,latbnd,'k-','LineWidth',2); xlim([-76.5 -74.35]); ylim([38.5 42.5]);
title('Correlation Coefficient','FontSize',15,'FontWeight','bold');

exportgraphics(gcf,'./validation.jpg','Resolution',400);

