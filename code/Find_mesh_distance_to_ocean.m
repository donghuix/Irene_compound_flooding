clear;close all;clc;

mesh_file = '~/Developments/RDycore-tools/data/delaware/delaware_30m.exo';

info = ncinfo(mesh_file);
elem_ss1 = ncread(mesh_file,'elem_ss1');
coordx = ncread(mesh_file ,'coordx');
coordy = ncread(mesh_file ,'coordy');
coordz = ncread(mesh_file ,'coordz');
connect = ncread(mesh_file ,'connect1');
xv = coordx(connect);
yv = coordy(connect);
xc = nanmean(xv,1)';
yc = nanmean(yv,1)';

for i = 1 : 1927
    disp(i);
    tic; 
    if i == 1927
    dist = pdist2([xc yc],[xc(elem_ss1((i-1)*10+1:end)) yc(elem_ss1((i-1)*10+1:end))]); 
    else
    dist = pdist2([xc yc],[xc(elem_ss1((i-1)*10+1:i*10)) yc(elem_ss1((i-1)*10+1:i*10))]); 
    end
    dist = min(dist,[],2);
    toc;
    tic
    if i == 1
        mindist_to_ocean = dist;
    else
        mindist_to_ocean(mindist_to_ocean > dist) = dist(mindist_to_ocean > dist);
    end
    toc;
end
save('mindist_to_ocean.mat','mindist_to_ocean','-v7.3');
