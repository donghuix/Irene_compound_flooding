clear;close all;clc;

addpath('/Users/xudo627/Developments/mylib/m');

vals      = [11;    12;    21;    22;    23;    24;    31;    41;    42;    43;    ...
             51;    52;    71;    72;    81;    82;    90;    95];
% https://ascelibrary.org/doi/10.1061/9780784481400.034
manning   = [0.038; 0.038; 0.040; 0.090; 0.120; 0.160; 0.027; 0.150; 0.120; 0.140; ...
             0.038; 0.115; 0.038; 0.038; 0.038; 0.035; 0.098; 0.068];
names     = {'Open Water', 'Perennial Ice/Snow', 'Developed, Open Space','Developed, Low Intensity',   ...
             'Developed, Medium Intensity','Developed, High Intensity', 'Barren Land',   ...
             'Deciduous Forest', 'Evegreen Forest', 'Mixed Forest', 'Dwarf Scrub', 'Shrub/Scrub',       ...
             'Grassland/Herbaceous', 'Sedge/Herbaceous', 'Pasture/Hay', 'Cultivated Crops', 'Wood Wetlands', ...
             'Emergent Herbaceous Wetlands'};



if exist('../data/nlcd_mesh.mat','file')
    load('../data/nlcd_mesh.mat');
else
    I = geotiffinfo('../data/delaware_nlcd_proj.tif');
    [x,y] = pixcenters(I);
    [x,y] = meshgrid(x,y);
    nlcd  = imread('../data/delaware_nlcd_proj.tif');
    nlcd  = double(nlcd);
    nlcd(nlcd == 0) = NaN;
    
    F = griddedInterpolant(fliplr(x'),fliplr(y'),fliplr(nlcd'),'nearest');
    
    nlcd_mesh = F(xc,yc);
    
    save('../data/nlcd_mesh.mat','nlcd_mesh');
end

% figure;
% patch(xv,yv,nlcd_mesh,'linestyle','none'); colorbar;


irm = [1 2 7 11 12 13 14 17 18];
vals(irm)     = [];
manning(irm)  = [];
names(irm)    = [];

if exist('nlcd_analysis.mat','file') && 0
    load('nlcd_analysis.mat');
else
    proj = projcrs(26918); % NAD83 / UTM zone 18N
    coordx  = ncread('../inputdata/delaware_30m.exo','coordx');
    coordy  = ncread('../inputdata/delaware_30m.exo','coordy');
    coordz  = ncread('../inputdata/delaware_30m.exo','coordz');
    connect = ncread('../inputdata/delaware_30m.exo','connect1');
    xv      = coordx(connect);
    yv      = coordy(connect);
    zv      = coordz(connect);
    dzdx = ((yv(3,:) - yv(1,:)).*(zv(2,:) - zv(1,:)) - (yv(2,:) - yv(1,:)).*(zv(3,:) - zv(1,:))) ./ ...
           ((yv(3,:) - yv(1,:)).*(xv(2,:) - xv(1,:)) - (yv(2,:) - yv(1,:)).*(xv(3,:) - xv(1,:)));
    dzdy = (- (xv(3,:) - xv(1,:)).*(zv(2,:) - zv(1,:)) + (xv(2,:) - xv(1,:)).*(zv(3,:) - zv(1,:))) ./ ...
           ((yv(3,:) - yv(1,:)).*(xv(2,:) - xv(1,:)) - (yv(2,:) - yv(1,:)).*(xv(3,:) - xv(1,:)));
    xc      = nanmean(xv,1)';
    yc      = nanmean(yv,1)';
    zc      = nanmean(zv,1)';
    [yc,xc] = projinv(proj,xc,yc);
    
    elmlonc = ncread('../data/domain_mid_atlantic_c240907.nc','xc') - 360;
    elmlatc = ncread('../data/domain_mid_atlantic_c240907.nc','yc'); 

    irene = load('../data/Max_Height_Manning025.mat');
    wet   = load('../data/Max_Height_AMC_100.mat');
    dry   = load('../data/Max_Height_AMC_0.mat');
    urban = load('../data/Max_Height_urban.mat');
    rural = load('../data/Max_Height_rural.mat');

    load('../elm/outputs/AMC_75_runoff.mat','qrunoff','qdrai');
    qrunoff = nansum(qrunoff,3);
    qdrai   = nansum(qdrai,3);
    qrunoff(qrunoff > 1000 | qrunoff < 0) = NaN;
    qdrai(  qdrai > 1000   | qdrai   < 0) = NaN;
    F = griddedInterpolant(elmlonc,elmlatc,qrunoff,'nearest');
    runoff_mesh = F(xc,yc);
    irene.qrunoff = runoff_mesh;
    F = griddedInterpolant(elmlonc,elmlatc,qdrai,'nearest');
    runoff_mesh = F(xc,yc);
    irene.qdrai = runoff_mesh;
    
    load('../elm/outputs/AMC_75_runoff.mat','qrunoff','qdrai');
    qrunoff = nansum(qrunoff,3);
    qdrai   = nansum(qdrai,3);
    qrunoff(qrunoff > 1000 | qrunoff < 0) = NaN;
    qdrai(  qdrai > 1000   | qdrai   < 0) = NaN;
    load('../data/pct_urban.mat');
    qrunoff(pct_urban < 90) = 0;
    F = griddedInterpolant(elmlonc,elmlatc,qrunoff,'nearest');
    runoff_mesh = F(xc,yc);
    urban.qrunoff = runoff_mesh;
    F = griddedInterpolant(elmlonc,elmlatc,qdrai,'nearest');
    runoff_mesh = F(xc,yc);
    urban.qdrai = runoff_mesh;

    load('../elm/outputs/AMC_75_runoff.mat','qrunoff','qdrai');
    qrunoff = nansum(qrunoff,3);
    qdrai   = nansum(qdrai,3);
    qrunoff(qrunoff > 1000 | qrunoff < 0) = NaN;
    qdrai(  qdrai > 1000   | qdrai   < 0) = NaN;
    load('../data/pct_urban.mat');
    qrunoff(pct_urban >= 90) = 0;
    F = griddedInterpolant(elmlonc,elmlatc,qrunoff,'nearest');
    runoff_mesh = F(xc,yc);
    rural.qrunoff = runoff_mesh;
    F = griddedInterpolant(elmlonc,elmlatc,qdrai,'nearest');
    runoff_mesh = F(xc,yc);
    rural.qdrai = runoff_mesh;

    load('../elm/outputs/AMC_100_runoff.mat','qrunoff','qdrai');
    qrunoff = nansum(qrunoff,3);
    qdrai   = nansum(qdrai,3);
    qrunoff(qrunoff > 1000 | qrunoff < 0) = NaN;
    qdrai(  qdrai > 1000   | qdrai   < 0) = NaN;
    F = griddedInterpolant(elmlonc,elmlatc,qrunoff,'nearest');
    runoff_mesh = F(xc,yc);
    wet.qrunoff = runoff_mesh;
    F = griddedInterpolant(elmlonc,elmlatc,qdrai,'nearest');
    runoff_mesh = F(xc,yc);
    wet.qdrai = runoff_mesh;
    
    load('../elm/outputs/AMC_0_runoff.mat','qrunoff','qdrai');
    qrunoff = nansum(qrunoff,3);
    qdrai   = nansum(qdrai,3);
    qrunoff(qrunoff > 1000 | qrunoff < 0) = NaN;
    qdrai(  qdrai > 1000   | qdrai   < 0) = NaN;
    F = griddedInterpolant(elmlonc,elmlatc,qrunoff,'nearest');
    runoff_mesh = F(xc,yc);
    dry.qrunoff = runoff_mesh; clear runoff_mesh qrunoff;
    F = griddedInterpolant(elmlonc,elmlatc,qdrai,'nearest');
    runoff_mesh = F(xc,yc);
    dry.qdrai = runoff_mesh;
    
    
    nlcd_height = NaN(length(vals),5);
    nlcd_flood  = NaN(length(vals),5);
    nlcd_ele    = NaN(length(vals),2);
    nlcd_slope  = NaN(length(vals),1);
    nlcd_perc   = NaN(length(vals),3);
    nlcd_runoff = NaN(length(vals),5);
    nlcd_qdrai  = NaN(length(vals),3);
    
    for i = 1 : length(vals)
        disp(i);
        ind = find(nlcd_mesh == vals(i));
        nlcd_runoff(i,1) = nanmean(irene.qrunoff(ind));
        nlcd_runoff(i,2) = nanmean(wet.qrunoff(ind)  );
        nlcd_runoff(i,3) = nanmean(dry.qrunoff(ind)  );
        nlcd_runoff(i,4) = nanmean(urban.qrunoff(ind)  );
        nlcd_runoff(i,5) = nanmean(rural.qrunoff(ind)  );

        nlcd_qdrai(i,1) = nanmean(irene.qdrai(ind));
        nlcd_qdrai(i,2) = nanmean(wet.qdrai(ind)  );
        nlcd_qdrai(i,3) = nanmean(dry.qdrai(ind)  );
    
        nlcd_height(i,1) = nanmean(irene.max_height(ind));
        nlcd_height(i,2) = nanmean(wet.max_height(ind)  );
        nlcd_height(i,3) = nanmean(dry.max_height(ind)  );
        nlcd_height(i,4) = nanmean(urban.max_height(ind));
        nlcd_height(i,5) = nanmean(rural.max_height(ind));

        nlcd_flood(i,1) = length(find(irene.max_height(ind) >= 0.12))/length(irene.max_height(ind));
        nlcd_flood(i,2) = length(find(wet.max_height(ind)   >= 0.12))/length(wet.max_height(ind));
        nlcd_flood(i,3) = length(find(dry.max_height(ind)   >= 0.12))/length(dry.max_height(ind));
        nlcd_flood(i,4) = length(find(urban.max_height(ind) >= 0.12))/length(urban.max_height(ind));
        nlcd_flood(i,5) = length(find(rural.max_height(ind) >= 0.12))/length(rural.max_height(ind));
    
        nlcd_ele(i,1)    = nanmean(zc(ind));
        nlcd_ele(i,2)    = nanstd(zc(ind));
        nlcd_slope(i)    = nanmean(sqrt(dzdx(ind).^2 + dzdy(ind).^2));
        nlcd_perc(i,1)   = length(ind)/length(nlcd_mesh).*100;
    
    %     tmp = h1(ind);
    %     nlcd_perc(i,2)   = length(find(tmp > 0.12)) / length(tmp) * 100;
    end
    save('nlcd_analysis.mat','nlcd_ele','nlcd_perc','nlcd_slope','nlcd_height','nlcd_qdrai','nlcd_runoff','nlcd_flood');
end

figure; set(gcf,'Position',[10 10 1200 500]);
barh(1:length(vals),nlcd_perc(:,1)); hold on; grid on;
yticklabels(names);
set(gca,'FontSize',18,'FontWeight','bold');
title('NLCD percentage in Delaware','FontSize',18,'FontWeight','bold');

figure; set(gcf,'Position',[10 10 1200 500]);
barh(1:length(vals),manning); hold on; grid on;
yticklabels(names);
set(gca,'FontSize',18,'FontWeight','bold');
title('Manning coefficient','FontSize',18,'FontWeight','bold');


figure;
barh(1:length(vals),nlcd_qdrai(:,2).*3600,1);hold on; grid on;
barh(1:length(vals),nlcd_qdrai(:,1).*3600,0.6);
barh(1:length(vals),nlcd_qdrai(:,3).*3600,0.2); %hold on; grid on;
yticklabels('');
%set(gca,'XScale','log');
set(gca,'FontSize',18,'FontWeight','bold');
title('Average subsurface runoff','FontSize',18,'FontWeight','bold');

figure;
barh(1:length(vals),(nlcd_runoff(:,2) - nlcd_qdrai(:,2)).*3600,1);hold on; grid on;
barh(1:length(vals),(nlcd_runoff(:,1) - nlcd_qdrai(:,1)).*3600,0.6);
barh(1:length(vals),(nlcd_runoff(:,3) - nlcd_qdrai(:,3)).*3600,0.2); %hold on; grid on;
yticklabels('');
%set(gca,'XScale','log');
set(gca,'FontSize',18,'FontWeight','bold');
title('Average surface runoff','FontSize',18,'FontWeight','bold');

colors = [51  0   174; ...
          151 83  175; ...
          221 181 152] ./255;
figure; set(gcf,'Position',[10 10 1200 600]);
axs(1) = subplot(1,3,1);
b(1) = barh(1:length(vals),nlcd_flood(:,2),0.9);hold on; grid on;
b(2) = barh(1:length(vals),nlcd_flood(:,1),0.6);
b(3) = barh(1:length(vals),nlcd_flood(:,3),0.2); %hold on; grid on;
% b(4) = barh(1:length(vals),nlcd_flood(:,4),0.1,'r'); %hold on; grid on;
% b(5) = barh(1:length(vals),nlcd_flood(:,5),0.05,'b'); %hold on; grid on;
ylim([0.25 9.75]);
leg = legend(b([2 1 3]),{'Irene','Wet','Dry'},'FontSize',18,'FontWeight','bold');
for i = 1 : 3
    b(i).FaceColor  = colors(i,:);
    b(i).FaceAlpha  = 0.75;
    b(i).EdgeColor  = 'k';
    b(i).LineWidth  = 2;
end
yticklabels(names);
%set(gca,'XScale','log');
set(gca,'FontSize',18,'FontWeight','bold');

axs(2) = subplot(1,3,2);
b(1) = barh(1:length(vals),nlcd_runoff(:,2).*3600,0.9);hold on; grid on;
b(2) = barh(1:length(vals),nlcd_runoff(:,1).*3600,0.6);
b(3) = barh(1:length(vals),nlcd_runoff(:,3).*3600,0.2);
% b(4) = barh(1:length(vals),nlcd_runoff(:,4).*3600,0.1,'r');
% b(5) = barh(1:length(vals),nlcd_runoff(:,5).*3600,0.05,'b');
ylim([0.25 9.75]);
for i = 1 : 3
    b(i).FaceColor  = colors(i,:);
    b(i).FaceAlpha  = 0.75;
    b(i).EdgeColor  = 'k';
    b(i).LineWidth  = 2;
end
yticklabels('');
set(gca,'FontSize',18,'FontWeight','bold');

axs(3) = subplot(1,3,3);
b(1) = barh(1:length(vals),nlcd_ele(:,1),0.9); hold on; grid on;
ylim([0.25 9.75]);
yticklabels('');
b(1).FaceColor  = 'k';
b(1).FaceAlpha  = 0.25;
b(1).EdgeColor  = 'k';
b(1).LineWidth  = 2;
set(gca,'FontSize',18,'FontWeight','bold');

%set(gca,'XScale','log');

axs(1).Position(1) = 0.25;
axs(1).Position(3) = 0.2;
axs(2).Position(1) = axs(1).Position(1) + axs(1).Position(3) +0.03;
axs(2).Position(3) = 0.2;
axs(3).Position(1) = axs(2).Position(1) + axs(2).Position(3) + 0.03;
axs(3).Position(3) = 0.2;

add_title(axs(1),'(a). Inundaiton fraction [-]',18,'out');
add_title(axs(2),'(b). Total runoff [mm]',18,'out');
add_title(axs(3),'(c). Surface slope [-]',18,'out');

figure; set(gcf,'Position',[10 10 1200 600]);
axs(1) = subplot(1,3,1);
b(1) = barh(1:length(vals),nlcd_height(:,2),0.9);hold on; grid on;
b(2) = barh(1:length(vals),nlcd_height(:,1),0.6);
b(3) = barh(1:length(vals),nlcd_height(:,3),0.2); %hold on; grid on;
% b(4) = barh(1:length(vals),nlcd_flood(:,4),0.1,'r'); %hold on; grid on;
% b(5) = barh(1:length(vals),nlcd_flood(:,5),0.05,'b'); %hold on; grid on;
ylim([0.25 9.75]);
leg = legend(b([2 1 3]),{'Irene','Wet','Dry'},'FontSize',18,'FontWeight','bold');
for i = 1 : 3
    b(i).FaceColor  = colors(i,:);
    b(i).FaceAlpha  = 0.75;
    b(i).EdgeColor  = 'k';
    b(i).LineWidth  = 2;
end
yticklabels(names);
%set(gca,'XScale','log');
set(gca,'FontSize',18,'FontWeight','bold');

axs(2) = subplot(1,3,2);
b(1) = barh(1:length(vals),nlcd_runoff(:,2).*3600,0.9);hold on; grid on;
b(2) = barh(1:length(vals),nlcd_runoff(:,1).*3600,0.6);
b(3) = barh(1:length(vals),nlcd_runoff(:,3).*3600,0.2);
% b(4) = barh(1:length(vals),nlcd_runoff(:,4).*3600,0.1,'r');
% b(5) = barh(1:length(vals),nlcd_runoff(:,5).*3600,0.05,'b');
ylim([0.25 9.75]);
for i = 1 : 3
    b(i).FaceColor  = colors(i,:);
    b(i).FaceAlpha  = 0.75;
    b(i).EdgeColor  = 'k';
    b(i).LineWidth  = 2;
end
yticklabels('');
set(gca,'FontSize',18,'FontWeight','bold');

axs(3) = subplot(1,3,3);
b(1) = barh(1:length(vals),nlcd_slope,0.9); hold on; grid on;
ylim([0.25 9.75]);
yticklabels('');
b(1).FaceColor  = 'k';
b(1).FaceAlpha  = 0.25;
b(1).EdgeColor  = 'k';
b(1).LineWidth  = 2;
set(gca,'FontSize',18,'FontWeight','bold');

%set(gca,'XScale','log');

axs(1).Position(1) = 0.25;
axs(1).Position(3) = 0.2;
axs(2).Position(1) = axs(1).Position(1) + axs(1).Position(3) +0.03;
axs(2).Position(3) = 0.2;
axs(3).Position(1) = axs(2).Position(1) + axs(2).Position(3) + 0.03;
axs(3).Position(3) = 0.2;

add_title(axs(1),'(a). Inundation depth [m]',18,'out');
add_title(axs(2),'(b). Total runoff [mm]',18,'out');
add_title(axs(3),'(c). Surface slope [-]',18,'out');

exportgraphics(gcf,'./Figure_NLCD.jpg','Resolution',400);
