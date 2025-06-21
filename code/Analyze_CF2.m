clear;close all;clc;

addpath('/Users/xudo627/Developments/getPanoply_cMap/');
coordx = ncread('~/Developments/RDycore-tools/data/delaware/delaware_30m.exo','coordx'   );
coordy = ncread('~/Developments/RDycore-tools/data/delaware/delaware_30m.exo','coordy'   );
coordz = ncread('~/Developments/RDycore-tools/data/delaware/delaware_30m.exo','coordz'   );
connect = ncread('~/Developments/RDycore-tools/data/delaware/delaware_30m.exo','connect1');
xv = coordx(connect); xc = nanmean(xv,1)';
yv = coordy(connect); yc = nanmean(yv,1)';
zv = coordz(connect); zc = nanmean(zv,1)';
area = polyarea(xv,yv)';

thre  = 1000 : 1000 : 200 * 1000;
baseline = load('../data/Max_Height_Manning025.mat');
nobc     = load('../data/Max_Height_AMC_75_noBC.mat');
hdiff = baseline.max_height - nobc.max_height;
slr = struct([]);
N   = 5;
for i = 1 : N
    load(['../data/Max_Height_SLR_' num2str(i) '.mat']);
    slr(i).hdist = NaN(length(thre),3);
    slr(i).hdiff = max_height - nobc.max_height;
end
clear max_height;

load('../data/mindist_to_ocean.mat');
load('../data/nlcd_mesh.mat');

zdist = NaN(length(thre),3);
hdist = NaN(length(thre),3);

for i = 1 : length(thre)
    if i == 1
        idx = find(mindist_to_ocean <= thre(i));
    else
        idx = find(mindist_to_ocean > thre(i-1) & mindist_to_ocean <= thre(i));
    end
    tmp = hdiff(idx);
    hdist(i,2) = nanmean(tmp); %prctile(tmp,50);

    for j = 1 : N
        tmp = slr(j).hdiff(idx);
        slr(j).hdist(i,1) = prctile(tmp,5 );
        slr(j).hdist(i,2) = nanmean(tmp); %prctile(tmp,50);
        slr(j).hdist(i,3) = prctile(tmp,95);
    end


    tmp2       = zc(idx);
    zdist(i,1) = prctile(tmp2,5 );
    zdist(i,2) = nanmean(tmp2); %prctile(tmp2,50);
    zdist(i,3) = prctile(tmp2,95);
    zdist(i,4) = nanstd(tmp2);
end

if 1
figure; set(gcf,'Position',[10 10 1600 600]);
S = shaperead('~/Developments/RDycore-tools/data/delaware/delaware.shp');       
ind = find(isnan(S.X));
xbnd = S.X(1:ind(1)-1)'; ybnd = S.Y(1:ind(1)-1)';

axs(1) = subplot(1,2,1);
xmin = 4.30*1e5;
xmax = 5.15*1e5;
ymin = 4.28*1e6;
ymax = 4.44*1e6;
cmap = getPanoply_cMap('NEO_modis_lst');
in = find(yc >= ymin & yc <= ymax & xc <= xmax & xc >= xmin);
patch(xv(:,in),yv(:,in),hdiff(in),'linestyle','none'); hold on;
set(gca,'XTick',[],'YTick',[]);
%ind = find(mindist_to_ocean <= 2e4 & hdiff > 0.01 & nlcd_mesh >= 21 & nlcd_mesh <= 24);
%plot(xc(ind),yc(ind),'g.'); hold on;
%set(gca,'XTick',[],'YTick',[]);
colormap(cmap); clim([0 2]); cb = colorbar;
cb.FontSize = 18;
xlim([xmin xmax]);
ylim([ymin ymax]);
plot(xbnd,ybnd,'k-','linewidth',1);

axs(2) = subplot(1,2,2);
yyaxis left;
colors = [ [224 162 166]; ...
           [204 128 143]; ...
           [180 96  123]; ...
           [151 72  106]; ...
           [121 51  87 ]; ] ./ 255;
plot(thre./1000,hdist(:,2), 'kx-', 'linewidth',3); hold on; grid on;
for i = 1 : 5
    plot(thre./1000,slr(i).hdist(:,2),'-','Color',colors(i,:),'linewidth',2); 
end
ylabel('\Delta h [m]','FontSize',20,'FontWeight','bold');
xlabel('Distance to ocean [km]','FontSize',20,'FontWeight','bold');

yyaxis right;
errorbar(thre./1000,zdist(:,2),zdist(:,4),'s-','Color',[0.5 0.5 0.5],'linewidth',1.5); hold on; grid on;
ylabel('Elevation [m]','FontSize',20,'FontWeight','bold');
xlim([0 10]);
set(gca,'FontSize',18);

leg = legend('Irene','SLR = 0.22m','SLR = 0.37m','SLR = 0.54m', ...
             'SLR = 0.70m','SLR = 0.90m','Topography','FontSize',18,'FontWeight','bold');
leg.Position(1) = 0.5;

axs(1).Position(3) = 0.2;
axs(2).Position(1) = axs(1).Position(1) + axs(1).Position(3) + 0.075;
axs(2).Position(3) = axs(2).Position(3) + 0.2;
add_title(axs(1),'(a). ',24,'out');
add_title(axs(2),'(b). ',24,'out');
exportgraphics(gcf,'Compounding.jpg','Resolution',400);
end

vals      = [11; ... %   'Open Water'
             12; ... %   'Perennial Ice/Snow'
             21; ... %   'Developed, Open Space'
             22; ... %   'Developed, Low Intensity'
             23; ... %   'Developed, Medium Intensity'
             24; ... %   'Developed, High Intensity'
             31; ... %   'Barren Land'
             41; ... %   'Deciduous Forest'
             42; ... %   'Evegreen Forest'
             43; ... %   'Mixed Forest'
             51; ... %   'Dwarf Scrub'
             52; ... %   'Shrub/Scrub'
             71; ... %   'Grassland/Herbaceous'
             72; ... %   'Sedge/Herbaceous'
             81; ... %   'Pasture/Hay'
             82; ... %   'Cultivated Crops'
             90; ... %   'Wood Wetlands'
             95];    %   'Emergent Herbaceous Wetlands'
names     = {'Open Water', 'Perennial Ice/Snow', 'Developed, Open Space','Developed, Low Intensity',   ...
             'Developed, Medium Intensity','Developed, High Intensity', 'Barren Land',   ...
             'Deciduous Forest', 'Evegreen Forest', 'Mixed Forest', 'Dwarf Scrub', 'Shrub/Scrub',       ...
             'Grassland/Herbaceous', 'Sedge/Herbaceous', 'Pasture/Hay', 'Cultivated Crops', 'Wood Wetlands', ...
             'Emergent Herbaceous Wetlands'};
purban    = NaN(N+1,1);
pwetland  = NaN(N+1,1);
pcrop     = NaN(N+1,1);
pcompound = NaN(N+1,1);

level = 0.05;
for i = 1 : N
    ind_compound         = find(mindist_to_ocean <= 1e4 & slr(i).hdiff > level);
    ind_compound_urban   = find( nlcd_mesh(ind_compound) >= 21 & nlcd_mesh(ind_compound) <= 24 );
    ind_compound_crop    = find( nlcd_mesh(ind_compound) == 82 );
    ind_compound_wetland = find( nlcd_mesh(ind_compound) >= 90 | nlcd_mesh(ind_compound) == 11 );
    pcompound(i) = sum(area(ind_compound)        )./1e6;
    purban(i)    = sum(area(ind_compound_urban)  )./1e6;
    pcrop(i)     = sum(area(ind_compound_crop)   )./1e6;
    pwetland(i)  = sum(area(ind_compound_wetland))./1e6;
end
ind_urban = find(nlcd_mesh >= 21 & nlcd_mesh <=24 );

ind_compound         = find( mindist_to_ocean <= 1e4 & hdiff > level);
ind_compound_urban   = find( nlcd_mesh(ind_compound) >= 21 & nlcd_mesh(ind_compound) <=24 );
ind_compound_crop    = find( nlcd_mesh(ind_compound) == 82 );
ind_compound_wetland = find( nlcd_mesh(ind_compound) >= 90 | nlcd_mesh(ind_compound) == 11 );
pcompound(N+1) = sum(area(ind_compound))./1e6;
purban(N+1)    = sum(area(ind_compound_urban))./1e6;
pcrop(N+1)     = sum(area(ind_compound_crop))./1e6;
pwetland(N+1)  = sum(area(ind_compound_wetland))./1e6;

figure; set(gcf,'Position',[10 10 1200 600]);
plot([0 0.22 0.34 0.54 0.7 0.9],[pcompound(6); pcompound(1:5)],'bo-','LineWidth',2,'MarkerSize',10); grid on; hold on;
plot([0 0.22 0.34 0.54 0.7 0.9],[pwetland(6);  pwetland(1:5) ],'s-','Color',[46,139,87 ]./255,'LineWidth',2,'MarkerSize',10); grid on;
plot([0 0.22 0.34 0.54 0.7 0.9],[purban(6);    purban(1:5)   ],'*-','Color',[70,130,180]./255,'LineWidth',2,'MarkerSize',10); grid on;
plot([0 0.22 0.34 0.54 0.7 0.9],[pcrop(6);     pcrop(1:5)    ],'x-','Color',[204,204,0]./255, 'LineWidth',2,'MarkerSize',10); grid on;
leg = legend('Total affected area','Affected wetland areas','Affected urban areas','Affected crop areas','FontSize',15,'FontWeight','bold');

ylabel('Area [km^{2}]','FontSize',18,'FontWeight','bold');
xticks([0 0.22 0.34 0.54 0.7 0.9]);
xticklabels({'Irene','SLR = 0.22m','SLR = 0.37m','SLR = 0.54m','SLR = 0.70m','SLR = 0.90m',});
set(gca,'FontSize',18);
leg.Position(1) = 0.15;
exportgraphics(gcf,'Wetland.jpg','Resolution',400);