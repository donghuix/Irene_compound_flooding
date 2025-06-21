clear;close all;clc;

clear;close all;clc;

addpath('/Users/xudo627/Developments/inpoly/');
addpath('/Users/xudo627/Developments/getPanoply_cMap/');
cmap = getPanoply_cMap('NEO_modis_cld_rd');

if exist('accumulated_runoff.mat','file') && 0
    load('accumulated_runoff.mat');
else
    coordx  = ncread('../inputdata/delaware_30m.exo','coordx');
    coordy  = ncread('../inputdata/delaware_30m.exo','coordy');
    connect = ncread('../inputdata/delaware_30m.exo','connect1');
    xv      = coordx(connect);
    yv      = coordy(connect);
    area    = polyarea(xv,yv); area = area';
    xc   = ncread('../data/domain_mid_atlantic_c240907.nc','xc');
    yc   = ncread('../data/domain_mid_atlantic_c240907.nc','yc');
    xmesh      = nanmean(xv,1)';
    ymesh      = nanmean(yv,1)';
    load('../data/nlcd_mesh.mat');
    nlcd       = unique(nlcd_mesh);
    
    proj = projcrs(26918); % NAD83 / UTM zone 18N
    S = shaperead('~/Developments/RDycore-tools/data/delaware/delaware.shp'); 
    %S = shaperead('~/Developments/EGG/data/WBD/WBD_02_HU2_Shape/Shape/WBDHU4.shp');
    ind = find(isnan(S.X));
    xbnd = S.X(1:ind(1)-1)'; ybnd = S.Y(1:ind(1)-1)';
    [ latbnd , lonbnd ] = projinv( proj , xbnd , ybnd );
    [ ymesh  , xmesh  ] = projinv( proj , xmesh, ymesh);
    lonbnd = lonbnd + 360;
    xmesh  = xmesh  + 360;
    in  = inpoly2([xc(:)  yc(:)], [lonbnd latbnd]);
    
    acc_qrun   = zeros(11,5);
    ave_qrun   = zeros(11,5);
    ave_qover  = zeros(11,5);
    acc_urban  = zeros(11,5);
    acc_qover  = zeros(11,5);
    ave_soil   = zeros(11,5);
    ave_surf   = zeros(11,5);
    nlcd_qrun  = zeros(length(nlcd),11,5);
    nlcd_qover = zeros(length(nlcd),11,5);
    k = 1;
    for i = 0 : 25 : 100
        disp(i);
        load(['../elm/outputs/AMC_' num2str(i) '_runoff.mat']);
        qrunoff = qrunoff .* 3600; 
        qdrai   = qdrai   .* 3600; 
        qover   = qrunoff - qdrai;
        qover   = qover; 
        
        for j = 1 : 11
            tmp = nansum(qrunoff(:,:,j),3);
            tmp(tmp > 1e5) = NaN;
            F = griddedInterpolant(xc,yc,tmp,'nearest');
            qrun_mesh = F(xmesh,ymesh);

            if j == 1
                acc_qrun(j,k)  = nanmean(tmp(in));
            else
                acc_qrun(j,k)  = acc_qrun(j-1,k) + nanmean(tmp(in));
            end
            ave_qrun(j,k) = nanmean(tmp(in));

            for jj = 1 : length(nlcd)
                idx = find(nlcd_mesh == nlcd(jj));
                nlcd_qrun(jj,j,k) = nansum(qrun_mesh(idx)./1000 .* area(idx)); % m^3
            end
    
            tmp = nansum(qover(:,:,j),3);
            tmp(tmp > 1e5) = NaN;
            F = griddedInterpolant(xc,yc,tmp,'nearest');
            qover_mesh = F(xmesh,ymesh);

            if j == 1
                acc_qover(j,k) = nanmean(tmp(in));
            else
                acc_qover(j,k) = acc_qover(j-1,k) + nanmean(tmp(in));
            end
            ave_qover(j,k) = nanmean(tmp(in));
            for jj = 1 : length(nlcd)
                idx = find(nlcd_mesh == nlcd(jj));
                nlcd_qover(jj,j,k) = nansum(qover_mesh(idx)./1000 .* area(idx)); % m^3
            end
            
            tmp = nansum(soil(:,:,j),3);
            ave_soil(j,k) = nanmean(tmp(in));

            tmp = nansum(surf(:,:,j),3);
            ave_surf(j,k) = nanmean(tmp(in));

        end
        k = k + 1;
    end
    save('accumulated_runoff.mat','acc_qrun','acc_qover','nlcd_qrun', ...
                                  'nlcd_qover','ave_soil','ave_surf', ...
                                  'ave_qrun',  'ave_qover'); 
end
acc_qrun = fliplr(acc_qrun);
acc_qover = fliplr(acc_qover);

colors = [51 0 174; ...
          104 78 187; ...
          144 107 141; ...
          191 145 113; ...
          221 181 152] ./255;
figure; set(gcf,'Position',[10 10 900 300]);
for i = 1 : 5
    plot(acc_qrun(:,i),'-','Color',colors(i,:),'LineWidth',2); hold on; grid on;
end

pos = get(gca,'Position');

leg = legend('AMC 100%','AMC 75%','AMC 50%','AMC 25%','AMC 0%','FontSize',12,...
             'FontWeight','bold','Orientation','horizontal');
leg.Position(2) = pos(2) + 0.05;
ylim([0 250]);
% ax1 = axes('Position',[0.2 0.625 0.15 0.25]);
% b = barh(acc_qover(3,:)./acc_qrun(3,:), 'facecolor', 'flat'); grid on;
% yticklabels({}); xticks([0.5 1]);
% xlabel('Surface runoff ratio [-]','FontSize',12,'FontWeight','bold');
% ylabel('Before peak','FontSize',12,'FontWeight','bold');
% ylim([0.25 5.5]);
% b.CData = colors;
% 
% ax2 = axes('Position',[0.6 0.625 0.15 0.25]);
% b = barh((acc_qover(11,:)-acc_qover(3,:))./(acc_qrun(11,:)-acc_qrun(3,:)), 'facecolor', 'flat'); grid on;
% yticklabels({}); xticks([0.5 1]);
% ylabel('After peak','FontSize',12,'FontWeight','bold');
% ylim([0.25 5.5]); xlim([0 1]);
% b.CData = colors;

figure; set(gcf,'Position',[10 10 900 300]);
for i = 1 : 5
    plot(acc_qover(:,i)./acc_qrun(:,i),'-','Color',colors(i,:),'LineWidth',2); hold on; grid on;
end

figure; set(gcf,'Position',[10 10 900 300]);
for i = 1 : 5
    plot(acc_qover(:,i),'-','Color',colors(i,:),'LineWidth',2); hold on; grid on;
end

figure; set(gcf,'Position',[10 10 900 300]);
for i = 1 : 5
    plot(acc_qrun(:,i) - acc_qover(:,i),'-','Color',colors(i,:),'LineWidth',2); hold on; grid on;
end
