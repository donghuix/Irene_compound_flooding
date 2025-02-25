clear;close all;clc;

addpath('/Users/xudo627/Developments/getPanoply_cMap/');
addpath('/Users/xudo627/Developments/mylib/USGS-download/');

cmap = getPanoply_cMap('NEO_mopitt_co');

name = 'delaware';
proj = projcrs(26918); % NAD83 / UTM zone 18N
rivers = shaperead('/Users/xudo627/Developments/RDycore-tools/data/delaware/hydrorivers.shp');
coordx = ncread('~/Developments/RDycore-tools/data/delaware/delaware_30m.exo','coordx');
coordy = ncread('~/Developments/RDycore-tools/data/delaware/delaware_30m.exo','coordy');
connect = ncread('~/Developments/RDycore-tools/data/delaware/delaware_30m.exo','connect1');
xv = coordx(connect);
yv = coordy(connect);
xc = nanmean(xv)';
yc = nanmean(yv)';

load('../data/domain.mat');
[latbnd,lonbnd] = projinv(proj,xbnd,ybnd);

if exist('../data/usgs.mat','file')
    load('../data/usgs.mat');
else
    fileID = fopen('../data/usgs/site_information');
    C = textscan(fileID,'%s %s %s %s %s','HeaderLines',26,'Delimiter','\t');
    fclose(fileID);
    fileID = fopen('../data/usgs/site_discharge');
    C2 = textscan(fileID,'%s %s %s %s %f %s','HeaderLines',1082,'Delimiter','\t');
    fclose(fileID);
    
    k = 1;
    for i = 1 : length(C2{1,3})
        disp(i);
        if ~isempty(C2{1,3}{i}) && strcmp(C2{1,3}{i}(1:3),'201')
            dn(k,1) = datenum(C2{1,3}{i},'yyyy-mm-dd HH:MM');
            dq(k,1) = C2{1,5}(i);
            ss{k,1} = C2{1,2}{i};
            k = k + 1;
        end
    end
    
    k = 1;
    sites = struct([]);
    for i = 1 : length(C{1})
        disp(i);
        lon = str2num(C{1,3}{i});
        lat = str2num(C{1,2}{i});

        ind = find(strcmp(ss,C{1,1}{i}));
    
        if inpoly2([lon lat],[lonbnd latbnd]) && ~isempty(ind)
            if k == 90
                x = 516329;
                y = 4453800;
            else
                [x,y] = projfwd(proj,lat,lon);
            end
        
            dist  = (xc - x).^2 + (yc - y).^2;
            [B,I] = sort(dist,'ascend');
            idx   = I(1:5000);

            sites(k).id  = C{1,1}{i};
            sites(k).lon = lon;
            sites(k).lat = lat;
            sites(k).x   = x;
            sites(k).y   = y;
            sites(k).idx = idx;
            [DA,outfilename] = retrieve_drainage_area(sites(k).id);
            sites(k).area    = DA;
            sites(k).dn = dn(ind);
            sites(k).dq = dq(ind).*0.3048;
            sites(k).dqmax = max(dq(ind)).*0.3048;
            k = k + 1;
        end
    end
    save('../data/usgs.mat','sites');
end

figure; set(gcf,'Position',[10 10 800 1200]);
plot(lonbnd,latbnd,'k-','LineWidth',2); hold on; grid on;
xlim([min(lonbnd) max(lonbnd)]);
ylim([min(latbnd) max(latbnd)]);
scatter([sites(:).lon],[sites(:).lat],72,[sites(:).dqmax],'filled', ...
        'MarkerEdgeColor','k','LineWidth',1); cb = colorbar;
colormap(cmap);
cb.FontSize = 12;
ylabel(cb,'Maximum Water Lelvel','FontSize',15,'FontWeight','bold');
for i = 1 : length(rivers)
    plot(rivers(i).X,rivers(i).Y,'b-','LineWidth',1); 
end




