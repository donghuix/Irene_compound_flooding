clear;close all;clc;

proj = projcrs(26918); % NAD83 / UTM zone 18N
rivers = shaperead('/Users/xudo627/Developments/RDycore-tools/data/delaware/hydrorivers.shp');
load('../data/usgs_with_sim_Manning_025.mat');

proj = projcrs(26918); % NAD83 / UTM zone 18N
S = shaperead('~/Developments/RDycore-tools/data/delaware/delaware.shp');                 
ind = find(isnan(S.X));
xbnd = S.X(1:ind(1)-1)'; ybnd = S.Y(1:ind(1)-1)';
[latbnd,lonbnd] = projinv(proj,xbnd,ybnd);

obs = NaN(length(sites),1);
sim = NaN(length(sites),1);
flood = NaN(length(sites),1);
major = NaN(length(sites),1);
action = NaN(length(sites),1);

addpath('/Users/xudo627/Developments/mylib/m');

nwps = readtable('/Users/xudo627/Developments/Evaluate_DFO_CONUS/nwps_all_gauges_report.csv');
k = 0;
for i = 1 : length(sites)
    ind = find(nwps.Var6 == str2num(sites(i).id));
    if ~isempty(ind)
        sites(i).action   = nwps.Var17(ind(1))*0.3048;
        sites(i).flood    = nwps.Var18(ind(1))*0.3048;
        sites(i).moderate = nwps.Var19(ind(1))*0.3048;
        sites(i).major    = nwps.Var20(ind(1))*0.3048;
        k = k + 1;
    end
end

coordx = ncread('~/Developments/RDycore-tools/data/delaware/delaware_30m.exo', 'coordx'  );
coordy = ncread('~/Developments/RDycore-tools/data/delaware/delaware_30m.exo', 'coordy'  );
coordz = ncread('~/Developments/RDycore-tools/data/delaware/delaware_30m.exo', 'coordz'  );
connect = ncread('~/Developments/RDycore-tools/data/delaware/delaware_30m.exo','connect1');
xv = coordx(connect);
yv = coordy(connect);
zv = coordz(connect);

t1 = datenum(2011,8,26,0,0,0);
t2 = datenum(2011,9,4,23,0,0);
t  = t1 : 6/24 : t2;

ngrid = 1000;
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
    if ~isempty(sites(i).action) && sites(i).action > 0
        action(i) = sites(i).action;
    end
    if ~isempty(sites(i).flood) && sites(i).flood > 0
        flood(i) = sites(i).flood;
    end
    if ~isempty(sites(i).major) && sites(i).major > 0
        major(i) = sites(i).major;
    end

    tmp    = max(sites(i).sim,[],1);
    tmp2   = nanmean(zv(:,sites(i).idx(1:ngrid)),1);
    tmpNSE = NaN(ngrid,1);
    tmpKGE = NaN(ngrid,1);
    tmpmax = NaN(ngrid,1);
    itime1 = [1:40];%[1:28]; % [1:40]
    itime2 = [2:41];%[2:29]; % [2:41]
    for j = 1 : ngrid
        [~,~,tmpNSE(j)] = estimate_evaluation_metric(hh(itime1),sites(i).sim(itime2,j));
        tmpKGE(j) = estimateKGE(hh(itime1),sites(i).sim(itime2,j));
        tmpmax(j) = abs(max(hh) - max(sites(i).sim(2:end,j)));
    end
    %sites(i).idxbest = find(tmpNSE == max(tmpNSE));
    sites(i).idxbest = find(tmpKGE == max(tmpKGE));
    %sites(i).idxbest = find(tmpmax == min(tmpmax));
    sites(i).idxbest = sites(i).idxbest(1);

    sim(i) = tmp(sites(i).idxbest);
    ele(i) = tmp2(sites(i).idxbest);
    [sites(i).R2,~,sites(i).NSE] = estimate_evaluation_metric(hh,sites(i).sim(2:end,sites(i).idxbest));
    sites(i).KGE = estimateKGE(hh,sites(i).sim(2:end,sites(i).idxbest));
    
end

save('../data/usgs_with_sim.mat','sites','action','flood','major','sim','obs');
length(find(obs >= flood & sim >= flood)) / length(find(obs >= flood))
length(find(obs <  flood & sim <  flood)) / length(find(obs < flood))

length(find(obs >= action & sim >= action)) / length(find(obs >= action))
length(find(obs <  action & sim <  action)) / length(find(obs < action))

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

xlabel('Gauge Maximum Height','FontSize',15,'FontWeight','bold');
ylabel('Simulated Maximum Height','FontSize',15,'FontWeight','bold');


figure;
semilogx([sites(:).area],[sites(:).R2],'bx'); hold on;

[~,~,R2] = LSE(obs,sim);
sqrt(R2);

[lat,lon] = projinv(proj,[sites(:).x],[sites(:).y]);

figure; set(gcf,'Position',[10 10 1200 800]);
axs(1) = subplot(2,2,1);
for i = 1 : length(rivers)
    plot(axs(1),rivers(i).X,rivers(i).Y,'b-','LineWidth',0.5); hold on;
end
scatter(axs(1),lon,lat,72,sqrt([sites(:).R2]),'filled','MarkerEdgeColor','k');  hold on;
clim(axs(1),[0 1]); colormap(axs(1),plasma(10)); hold on; colorbar('FontSize',15);
plot(axs(1),lonbnd,latbnd,'k-','LineWidth',2); xlim([-76.5 -74.35]); ylim([38.5 42.5]);

axs(2) = subplot(2,2,2);
histogram(sqrt([sites(:).R2])); grid on;
xlabel('\rho','FontSize',15,'FontWeight','bold');
ylabel('Counts','FontSize',12,'FontWeight','bold');

axs(3) = subplot(2,2,4);
plot(obs,sim,'bx','LineWidth',1); hold on; grid on;
plot([0 9],[0 9],'r-','LineWidth',2); 
xlabel('Observation','FontSize',12,'FontWeight','bold');
ylabel('Simulation','FontSize',12,'FontWeight','bold');

axs(1).Position(1) = 0.1;
axs(1).Position(2) = 0.1;
axs(1).Position(3) = 0.4;
axs(1).Position(4) = 0.8;
axs(2).Position(4) = axs(1).Position(2) + axs(1).Position(4) - axs(2).Position(2);
axs(2).Position(1) = axs(1).Position(1) + axs(1).Position(3) + 0.1;
axs(3).Position(4) = axs(1).Position(2) + axs(1).Position(4) - axs(2).Position(2);
axs(3).Position(1) = axs(1).Position(1) + axs(1).Position(3) + 0.1;
for i = 1 : 3
    set(axs(i),'FontSize',15);
end
add_title(axs(1),'(a). Correlation Coefficient',20,'out');
add_title(axs(2),'(b). ',20,'out');
add_title(axs(3),'(c). Maximum Height [m]',20,'out');

disp(['Median \rho is ' num2str(median(sqrt([sites(:).R2])))]);
disp(['Median NSE  is ' num2str(median([sites(:).NSE]))]     );
disp(['Median KGE  is ' num2str(median([sites(:).KGE]))]     );

[R2,RMSE,NSE,PBIAS,MSE,NSE1] = estimate_evaluation_metric(obs,sim);
(mean(sim) - mean(obs))/mean(obs)
disp(['RMSE is ' num2str(RMSE)]);
exportgraphics(gcf,'./Validation_height.jpg','Resolution',400);


figure; set(gcf,'Position',[10 10 700 800]);

for i = 1 : length(rivers)
    plot(rivers(i).X,rivers(i).Y,'b-','LineWidth',0.5); hold on;
end
scatter(lon,lat,72,[sites(:).KGE],'filled','MarkerEdgeColor','k');  hold on;
clim([0 1]); colormap(plasma(10)); hold on; colorbar('FontSize',15);
plot(lonbnd,latbnd,'k-','LineWidth',2); xlim([-76.5 -74.35]); ylim([38.5 42.5]);
ax = gca;
ax.Position(1) = 0.1;
ax.Position(3) = 0.8;
add_title(ax,'(a). Correlation Coefficient',15,'out');

ax1 = axes('Position',[0.15 0.7 0.28 0.20]);
histogram([sites(:).KGE]); grid on;
add_title(ax1,'(b). ',12,'in');
xlabel('\rho','FontSize',15,'FontWeight','bold');
ylabel('Counts','FontSize',12,'FontWeight','bold');

ax2 = axes('Position',[0.15 0.15 0.2 0.2]);
plot(obs,sim,'bx','LineWidth',1); hold on; grid on;
plot([0 9],[0 9],'r-','LineWidth',2); 
xlabel('Observation','FontSize',12,'FontWeight','bold');
ylabel('Simulation','FontSize',12,'FontWeight','bold');
add_title(ax2,'(c). Maximum Height [m]',12,'in');
