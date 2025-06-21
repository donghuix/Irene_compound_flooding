clear;close all;clc;

elmlonc = ncread('../data/domain_mid_atlantic_c240907.nc','xc') - 360;
elmlatc = ncread('../data/domain_mid_atlantic_c240907.nc','yc'); 

 proj = projcrs(26918); % NAD83 / UTM zone 18N
coordx  = ncread('../inputdata/delaware_30m.exo','coordx');
coordy  = ncread('../inputdata/delaware_30m.exo','coordy');
coordz  = ncread('../inputdata/delaware_30m.exo','coordz');
connect = ncread('../inputdata/delaware_30m.exo','connect1');
xv      = coordx(connect);
yv      = coordy(connect);
zv      = coordz(connect);

xc      = nanmean(xv,1)';
yc      = nanmean(yv,1)';
xmin = 4.30*1e5;
xmax = 5.15*1e5;
ymin = 4.28*1e6;
ymax = 4.44*1e6;
in = find(yc >= ymin & yc <= ymax & xc <= xmax & xc >= xmin);

color = [ [206 68  101]; ...
          [73  16  108]; ...
          [243 209 78 ] ]./255;
% color = [ [217 159 252]; ...
%           [177 255 202]; ...
%           [171 177 252] ]./255;
color = [ [214 82  38 ]; ...
          [93  165 234]; ...
          [236 190 83 ] 
          [219 28  83]]./255;
zc      = nanmean(zv,1)';
[yc,xc] = projinv(proj,xc,yc);

urban = load('../data/Max_Height_urban.mat');
rural = load('../data/Max_Height_rural.mat');
irene = load('../data/Max_Height_Manning025.mat');

load('../data/pct_urban.mat');
F = griddedInterpolant(elmlonc,elmlatc,pct_urban,'nearest');
pct_mesh = F(xc,yc);

iurban = find(pct_mesh > 90);
irural = find(pct_mesh < 10);

thre = [0.12; 0.46; 1.00; 1.70];

fracs = NaN(5,2);
for i = 1 : 5
    if i == 1
        fracs(i,1) = length(find(urban.max_height(iurban) < 0.12)) / length(urban.max_height(iurban));
        fracs(i,2) = length(find(rural.max_height(iurban) < 0.12)) / length(rural.max_height(iurban));
    elseif i == 5
        fracs(i,1) = length(find(urban.max_height(iurban) > 1.7)) / length(urban.max_height(iurban));
        fracs(i,2) = length(find(rural.max_height(iurban) > 1.7)) / length(rural.max_height(iurban));
    else
        fracs(i,1) = length(find(urban.max_height(iurban) >= thre(i-1) & urban.max_height(iurban) < thre(i))) / length(urban.max_height(iurban));
        fracs(i,2) = length(find(rural.max_height(iurban) >= thre(i-1) & rural.max_height(iurban) < thre(i))) / length(rural.max_height(iurban));
    end
end

figure; set(gcf,'Position',[10 10 1000 500]);
load('../data/buildings/building.mat');


axs(1) = subplot(1,2,1);
plot([1 10 10 1 1],[0.9 0.9 1 1 0.9],'k-','LineWidth',2); hold on; grid on;
plot([1 0.1],[1 0.6],'k--','LineWidth',1); 
plot([10 9], [1 0.6],'k--','LineWidth',1); 
[h(1),stats1] = cdfplot(urban.max_height(iurban)); 
[h(2),stats2] = cdfplot(rural.max_height(iurban)); 
%[h(3),stats3] = cdfplot(irene.max_height(iurban));
h(1).Color = color(1,:); h(1).LineWidth = 3; 
h(2).Color = color(2,:); h(2).LineWidth = 3; h(2).LineStyle = "--";
%h(3).Color = 'k'       ; h(3).LineWidth = 3; h(3).LineStyle = ":";

xticks([0.001; 0.01; 0.1; 1; 10]);
xticklabels({'0.001','0.01','0.1','1','10'});
set(gca,'FontSize',15);

xlim([0.001 10]); set(gca,'XScale','log','FontSize',15);
xlabel('Inundation depth [m]','FontSize',18,'FontWeight','bold');
ylabel('Cumulative Probability','FontSize',18,'FontWeight','bold');

plot(0.12,1-length(find(rural.max_height(iurban) >= 0.12))/length(rural.max_height(iurban)),...
     'bx','LineWidth',3,'MarkerSize',8);
plot(0.12,1-length(find(urban.max_height(iurban) >= 0.12))/length(urban.max_height(iurban)),...
     'rx','LineWidth',3,'MarkerSize',8);
% plot(0.12,1-length(find(irene.max_height(iurban) >= 0.12))/length(irene.max_height(iurban)),...
%      'rx','LineWidth',2,'MarkerSize',8);

legend(h,{'Urban runoff','Rural runoff'},'FontSize',18,'FontWeight','bold', ...
       'Location','northwest');


length(find(rural.max_height(iurban) >= 0.01 & rural.max_height(iurban) <= 0.05 )) / length(rural.max_height(iurban))
length(find(urban.max_height(iurban) >= 0.01 & urban.max_height(iurban) <= 0.05 )) / length(urban.max_height(iurban))

length(find(rural.max_height(iurban) >= 0.12 )) / length(rural.max_height(iurban))
length(find(urban.max_height(iurban) >= 0.12 )) / length(urban.max_height(iurban))

axs(2) = subplot(1,2,2);
sz = 3;
h(1) = plot(lon(im3),lat(im3),'o','MarkerFaceColor',color(1,:),'MarkerEdgeColor','none','MarkerSize',sz); hold on;
h(4) = plot(lon(im1),lat(im1),'o','MarkerFaceColor','m',       'MarkerEdgeColor','none','MarkerSize',sz); 
h(3) = plot(lon(im2),lat(im2),'o','MarkerFaceColor',color(3,:),'MarkerEdgeColor','none','MarkerSize',sz); 
h(2) = plot(lon(im4),lat(im4),'o','MarkerFaceColor',color(2,:),'MarkerEdgeColor','none','MarkerSize',sz); 
plot(xbnd,ybnd,'k-','LineWidth',1);
xlim([min(xbnd) max(xbnd)]);
ylim([min(ybnd) max(ybnd)]);
set(gca,'XTick',[],'YTick',[]);


axs(1).Position(1) = 0.05;
axs(1).Position(3) = 0.5;
axs(2).Position(1) = axs(1).Position(1) + axs(1).Position(3) + 0.025;
axs(2).Position(3) = 0.3;

ax1 = axes('Position',[0.300 0.2 0.245 0.4]);
[h(1),stats1] = cdfplot(urban.max_height(iurban)); hold on; grid on;
[h(2),stats2] = cdfplot(rural.max_height(iurban)); 
h(1).Color = color(1,:); h(1).LineWidth = 3; 
h(2).Color = color(2,:); h(2).LineWidth = 3; h(2).LineStyle = "--";
xlim([1 7]);
set(gca,'FontSize',15);
xlabel('','FontSize',18,'FontWeight','bold');
ylabel('','FontSize',18,'FontWeight','bold');
title('');
ax1.LineWidth=2;

ax2 = axes('Position',[0.590 0.7 0.1 0.2]);
data = [length(im3); length(im4); length(im2); length(im1)];
p = pie(data);
for k = 1:2:length(p)  % Pie chart has text and patches; skip text
    p(k).FaceColor = color((k+1)/2, :);
    if k == length(p) - 1
        p(k).FaceColor = 'm';
    end
    p(k).LineWidth = 1.5;
end


leg = legend(p(1:2:8),{'Urban Runoff','Rural Runoff', ...
                'Urban or Rural Runoff','Urban and Rural Runoff'}, ...
               'FontSize',12,'FontWeight','bold', 'Location','northwest','NumColumns',2);
leg.Position(1) = axs(2).Position(1);
leg.Position(2) = axs(2).Position(2) - leg.Position(3);
leg.Position(2) = axs(2).Position(2) - leg.Position(4);
leg.Position(3) = axs(2).Position(3);

title(axs(1),'');
add_title(axs(1),'(a). Contribution of urban flooding',20,'out');
add_title(axs(2),'(b). Flooded buildings',20,'out');
exportgraphics(gcf,'Urban_FLooding.jpg','Resolution',400);


