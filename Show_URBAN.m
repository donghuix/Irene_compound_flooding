clear;close all;clc;

% S = m_shaperead('~/Developments/EGG/data/WBD/WBD_17_HU2_Shape/Shape/WBDHU8');
% 
% xbnd = S.ncst{1}(:,1);
% ybnd = S.ncst{1}(:,2);
% 
% figure;
% plot(xbnd,ybnd,'k-','LineWidth',2);
files = dir('./NLCD_WBD18/*.tif');

for i = 1
    fname = fullfile(files(i).folder,files(i).name);
    I = geotiffinfo(fname); 
    [x,y]=pixcenters(I);
    nlcd = imread(fname);
    nlcd = double(nlcd);
end
