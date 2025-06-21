clear;close all;clc;

addpath('/Users/xudo627/Developments/inpoly/');
addpath('/Users/xudo627/Developments/getPanoply_cMap/');

plot_inundation = 1;

cmap = getPanoply_cMap('NEO_modis_lst'); %NEO_modis_cld_wp

coordx = ncread('~/Developments/RDycore-tools/data/delaware/delaware_30m.exo', 'coordx'  );
coordy = ncread('~/Developments/RDycore-tools/data/delaware/delaware_30m.exo', 'coordy'  );
connect = ncread('~/Developments/RDycore-tools/data/delaware/delaware_30m.exo','connect1');
xv = coordx(connect);
yv = coordy(connect);
xc = nanmean(xv,1)';
yc = nanmean(yv,1)';

fname = '../data/DFO_3861_From_20110827_to_20110913/DFO_3861_From_20110827_to_20110913.tif';
proj = projcrs(26918); % NAD83 / UTM zone 18N
S = shaperead('~/Developments/RDycore-tools/data/delaware/delaware.shp');       
ind = find(isnan(S.X));
xbnd = S.X(1:ind(1)-1)'; ybnd = S.Y(1:ind(1)-1)';
[latbnd,lonbnd] = projinv(proj,xbnd,ybnd);
[latc, lonc]    = projinv(proj,xc,yc);
A = imread(fname);
flooded = A(:,:,1);
perm    = A(:,:,5);
flooded(perm == 1 & flooded == 0) = 2;
clear A perm;

I = geotiffinfo(fname); 
[x,y] = pixcenters(I);
[x,y] = meshgrid(x,y);

F = griddedInterpolant(fliplr(x'),fliplr(y'),fliplr(flooded'),'nearest');
flooded_mesh = F(lonc,latc);

if plot_inundation
load('../data/Max_Height_Manning025.mat');

%figure; set(gcf,'Position',[10 10 700 800]);
cmap2 = [ [255 255 255]; ... 
          [220 20  60 ]; ...
          [30  144 255] ]./255;
% patch(xv,yv,flooded_mesh,'linestyle','none'); hold on; colorbar;
% clim([-0.5 2.5]); cb = colorbar; colormap(cmap2);
% cb.Ticks = [0 1 2] ; %Create 8 ticks from zero to 1
% cb.TickLabels = {'No flood','Flooded','Permenant water'};
% cb.FontSize = 15;
% cb.FontWeight = 'bold';
% set(gca,'Color',[0.75 0.75 0.75]);
% plot(xbnd,ybnd,'k-','LineWidth',2);

cmap3 = [ [124 209 208]; ...
          [83  115 208]; ...
          [30  36  206]; ...
          [112 39  200]; ...
          [181 42  205] ]./255;
% tmph = max_height;
% tmph(max_height < 0.12) = 1;
% tmph(max_height >= 0.12 & max_height < 0.46) =
%zoomin(xv,yv,proj,flooded_mesh,false);
% Region 1
xbox1 = [ 4.95  5.15   5.15  4.95  4.95].*1e5;
ybox1 = [46.50 46.50  46.70 46.70 46.50].*1e5;
[latbox1,lonbox1] = projinv(proj,xbox1,ybox1);
% Region 2
xbox2 = [ 4.82  4.88   4.88  4.82  4.82].*1e5;
ybox2 = [44.16 44.16  44.22 44.22 44.16].*1e5;

xbox2 = [ 4.82  4.94   4.94  4.82  4.82].*1e5;
ybox2 = [44.16 44.16  44.28 44.28 44.16].*1e5;

[latbox2,lonbox2] = projinv(proj,xbox2,ybox2);
% Region 3
xbox3 = [ 4.52  4.72   4.72  4.52  4.52].*1e5;
ybox3 = [43.60 43.60  43.80 43.80 43.60].*1e5;
[latbox3,lonbox3] = projinv(proj,xbox3,ybox3);


in1  = inpoly2([mean(xv)' mean(yv)'],[xbox1' ybox1']);
xv1  = xv(:,in1);
yv1  = yv(:,in1);
f1   = flooded_mesh(in1);
h1   = max_height(in1);

in2  = inpoly2([mean(xv)' mean(yv)'],[xbox2' ybox2']);
xv2  = xv(:,in2);
yv2  = yv(:,in2);
f2   = flooded_mesh(in2);
h2   = max_height(in2);

in3  = inpoly2([mean(xv)' mean(yv)'],[xbox3' ybox3']);
xv3  = xv(:,in3);
yv3  = yv(:,in3);
f3   = flooded_mesh(in3);
h3   = max_height(in3);

cmap = [ [255 255 255]; ... 
         [220 20  60 ]; ...
         [30  144 255] ]./255;


figure; set(gcf,'Position',[10 10 1600 1600])
for i = 1 : 12
    axs(i) = subplot(3,4,i); hold on;
    axs(i).Position(2) = axs(i).Position(2) - 0.05;
end
for i = [3 4 7 8 11 12]
    xticklabels(axs(i),'');
    yticklabels(axs(i),'');
    axs(i).Position(3) = axs(i).Position(3) + 0.02;
    axs(i).Position(4) = axs(i).Position(4) + 0.06;
end
for i = [4 8 12]
    axs(i).Position(1) = axs(i).Position(1) - 0.02;
end
axs(1).Position(3) = axs(2).Position(1) + axs(2).Position(3) - axs(1).Position(1);
axs(1).Position(2) = axs(9).Position(2);
axs(1).Position(4) = axs(3).Position(2) + axs(3).Position(4) - axs(1).Position(2);
delete(axs([2 5 6 9 10]));


patch(axs(1),xv,yv,max_height,'linestyle','none'); hold on; 
plot(axs(1),xbnd,  ybnd,  'k-', 'LineWidth',1); hold on;
plot(axs(1),xbox1, ybox1, '--','Color',[138,43,226]./255,'LineWidth',3); 
plot(axs(1),xbox2, ybox2, '--','Color',[138,43,226]./255,'LineWidth',3); 
plot(axs(1),xbox3, ybox3, '--','Color',[138,43,226]./255,'LineWidth',3); 

cb1 = colorbar(axs(1),'west'); colormap(axs(1),getPanoply_cMap('NEO_modis_lst'));
clim(axs(1),[0 1]); xlim(axs(1),[min(xv(:)) max(xv(:))]); 
                    ylim(axs(1),[min(yv(:)) max(yv(:))]);
cb1.Position(1) = axs(1).Position(1) + axs(1).Position(3) + 0.01;
cb1.Position(2) = axs(1).Position(2);
cb1.Position(4) = axs(1).Position(4);
cb1.AxisLocation = 'out';
cb1.FontSize = 15;
set(axs(1),'FontSize',13);

patch(axs(3),xv1,yv1,h1,'LineStyle','none'); hold on;  colormap(axs(3),getPanoply_cMap('NEO_modis_lst'));
xlim(axs(3),[xbox1(1) xbox1(2)]);
ylim(axs(3),[ybox1(1) ybox1(3)]);
clim(axs(3),[0 1]);
set(axs(3),'Color',[0.75 0.75 0.75]);

patch(axs(4),xv1,yv1,f1,'LineStyle','none'); hold on;  colormap(axs(4),cmap);
xlim(axs(4),[xbox1(1) xbox1(2)]);
ylim(axs(4),[ybox1(1) ybox1(3)]);
clim(axs(4),[-0.5 2.5]);
set(axs(4),'Color',[0.75 0.75 0.75]);

patch(axs(7),xv2,yv2,h2,'LineStyle','none'); hold on;  colormap(axs(7),getPanoply_cMap('NEO_modis_lst'));
xlim(axs(7),[xbox2(1) xbox2(2)]);
ylim(axs(7),[ybox2(1) ybox2(3)]);
clim(axs(7),[0 1]);
set(axs(7),'Color',[0.75 0.75 0.75]);

patch(axs(8),xv2,yv2,f2,'LineStyle','none'); hold on;  colormap(axs(8),cmap);
xlim(axs(8),[xbox2(1) xbox2(2)]);
ylim(axs(8),[ybox2(1) ybox2(3)]);
clim(axs(8),[-0.5 2.5]);
set(axs(8),'Color',[0.75 0.75 0.75]);

patch(axs(11),xv3,yv3,h3,'LineStyle','none'); hold on; colormap(axs(11),getPanoply_cMap('NEO_modis_lst'));
xlim(axs(11),[xbox3(1) xbox3(2)]);
ylim(axs(11),[ybox3(1) ybox3(3)]);
clim(axs(11),[0 1]);
set(axs(11),'Color',[0.75 0.75 0.75]);

patch(axs(12),xv3,yv3,f3,'LineStyle','none'); hold on; cb3 = colorbar(axs(12),'west'); colormap(axs(12),cmap);
xlim(axs(12),[xbox3(1) xbox3(2)]);
ylim(axs(12),[ybox3(1) ybox3(3)]);
clim([-0.5 2.5]);
cb3.Ticks = [0 1 2] ; %Create 8 ticks from zero to 1
cb3.TickLabels = {'No flood','Flooded','Permenant \newline Water'};
cb3.FontSize = 15;
cb3.FontWeight = 'bold';
cb3.AxisLocation = 'out';
cb3.Position(1) = axs(12).Position(1) + axs(12).Position(3) + 0.01;
cb3.Position(2) = axs(12).Position(2);
cb3.Position(4) = axs(4).Position(2) + axs(4).Position(4) - cb3.Position(2);
set(axs(12),'Color',[0.75 0.75 0.75]);

add_title(axs(1), '(a)',30,'in');
add_title(axs(3), '(b)',30,'in');
add_title(axs(7), '(c)',30,'in');
add_title(axs(11),'(d)',30,'in');
add_title(axs(4), '(e)',30,'in');
add_title(axs(8), '(f)',30,'in');
add_title(axs(12),'(g)',30,'in');
exportgraphics(gcf,'Inundation.jpg','Resolution',400);
end

load('../data/usgs_with_sim.mat');
[lat,lon] = projinv(proj,[sites(:).x],[sites(:).y]);

flooded_usgs = NaN(length(sites),1);
for i = 1 : length(sites)
    disp(i);
    tmp = flooded_mesh(sites(i).idx);
    if any(tmp == 1)
        flooded_usgs(i) = 1;
    elseif any(tmp == 2)
        flooded_usgs(i) = 2;
    else
        flooded_usgs(i) = 0;
    end
end


ind1 = find(obs >= action & sim >= action);
ind2 = find(obs >= action & sim <  action);
ind3 = find(obs <  action & sim <  action);
ind4 = find(obs <  action & sim >= action);
% ind1 = find(obs >= flood & sim >= flood);
% ind2 = find(obs >= flood & sim <  flood);
% ind3 = find(obs <  flood & sim <  flood);
% ind4 = find(obs <  flood & sim >= flood);

(length(ind1) + length(ind3)) / (length(ind1) + length(ind2) + length(ind3) + length(ind4))
ind5 = find(~isnan(action) & flooded_usgs == 1);
ind6 = find(~isnan(action) & flooded_usgs == 2);
rivers = shaperead('/Users/xudo627/Developments/RDycore-tools/data/delaware/hydrorivers.shp');
figure; set(gcf,'Position',[10 10 700 800]);

for i = 1 : length(rivers)
    plot(rivers(i).X,rivers(i).Y,'b-','LineWidth',0.5); hold on;
end
h(1) = scatter(lon(ind1),lat(ind1),120,'o','filled','MarkerFaceColor','m','MarkerEdgeColor','m','LineWidth',1); hold on;
h(2) = scatter(lon(ind2),lat(ind2),120,'o','MarkerFaceColor','none','MarkerEdgeColor',[250,128,114]./255,'LineWidth',2.5);
h(3) = scatter(lon(ind3),lat(ind3),120,'^','filled','MarkerFaceColor','c','MarkerEdgeColor','c','LineWidth',1);
h(4) = scatter(lon(ind4),lat(ind4),120,'^','MarkerFaceColor','none','MarkerEdgeColor',[65,105,225]./255,'LineWidth',2.5);
plot(lonbnd,latbnd,'k-','LineWidth',2); xlim([-76.5 -74.35]); ylim([38.5 42.5]);
h(5) = plot(lon(ind5),lat(ind5),'k*','LineWidth',1.5);
h(6) = plot(lon(ind6),lat(ind6),'k+','LineWidth',1.5);

leg = legend(h, {['Obs > Action, Sim > Action \newline ('  num2str(length(ind1)) ' gauges)'] , ...
                 ['Obs > Action, Sim < Action \newline ('  num2str(length(ind2)) ' gauges)'] , ...
                 ['Obs < Action, Sim < Action \newline ('  num2str(length(ind3)) ' gauges)'] , ...
                 ['Obs < Action, Sim > Action \newline ('  num2str(length(ind4)) ' gauges)'] , ...
                 ['Satellite Flooded          \newline ('  num2str(length(ind5)) ' gauges)'] , ...
                 ['Sitellite Permenant Water  \newline ('  num2str(length(ind6)) ' gauges)']}, ...
                  'FontSize',15,'FontWeight','bold');
xlim([-76.8 -74.4]);
pos = get(gca,'Position');
leg.Position(1) = pos(1);
leg.Position(2) = pos(2) + pos(4) - leg.Position(4);
set(gca,'FontSize',15');
exportgraphics(gcf,'Gauge_Flooding.jpg','Resolution',400);

figure; set(gcf,'Position',[10 10 700 800]);
scatter(lon,lat,72,flooded_usgs,'filled','MarkerEdgeColor','k','LineWidth',1);  hold on;
clim([-0.5 1.5]); colormap(parula(2)); hold on; cb = colorbar('FontSize',15,'FontWeight','bold');
plot(lonbnd,latbnd,'k-','LineWidth',2); xlim([-76.5 -74.35]); ylim([38.5 42.5]);
cb.Ticks = [0 1] ; %Create 8 ticks from zero to 1
cb.TickLabels = {'No flood','flooded'};

figure; set(gcf,'Position',[10 10 700 800]);
scatter(lon,lat,72,[sites(:).dqmax],'filled','MarkerEdgeColor','k');  hold on;
colormap(cmap); hold on; colorbar('FontSize',15);
clim([0 8]);
plot(lonbnd,latbnd,'k-','LineWidth',2); xlim([-76.5 -74.35]); ylim([38.5 42.5]);

%title('Correlation Coefficient','FontSize',15,'FontWeight','bold');