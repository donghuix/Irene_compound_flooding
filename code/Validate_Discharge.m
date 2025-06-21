clear;close all;clc;

addpath('/Users/xudo627/Developments/inpoly/');
addpath('/Users/xudo627/Developments/getPanoply_cMap/');
addpath('/Users/xudo627/Developments/mylib/m/');
addpath('/Users/xudo627/Developments/mylib/USGS-download/');

files = dir('hires-ensemble8/*.txt');

% tests = {'qsim_Manning_010','qsim_Manning_025','qsim_Manning_050', ...
%          'qsim_Manning_075','qsim_Manning_100_noBC', 'USGS'};

t0 = datenum(2011,8,26,0,0,0);
t0 = t0 - 5/24;
dt = 3600;
t  = t0 + [dt : dt : 864000-259200] ./3600 ./24;

data = retrieve_daily_streamflow('01463500','2011-08-25','2011-09-01',false,'Discharge');
figure; set(gcf,'Position',[10 10 1400 800]);
axs(1) = subplot(2,2,1);
[yr,mo,da,hr,mi] = datevec(data.dn);
hr = reshape(hr,[4, length(data.dn)/4]);
da = reshape(da,[4, length(data.dn)/4]);
dq = nanmean(reshape(data.dq,[4, length(data.dn)/4]),1);
dq = dq(20:end-5);
names  = {'N_{nlcd}','N_{nlcd} \times 0.75','N_{nlcd} \times 0.50', ...
         'N_{nlcd} \times 0.25','N_{nlcd} \times 0.10','Observation'};
names2 = {'AMC_100','Irene','AMC_50','AMC_25','AMC_0','Observation'};
colors = distinguishable_colors(6); colors(4,:) = [];
colors2 = [108 141 249 ; ...
          108 93  235 ; ...
          190 37  122 ; ...
          224 95  18  ; ...
          235 174 46  ] ./ 255;
colors2 = flipud(colors2);
colors = [187 47 51; ...
          83 148 183; ...
          124 203 180; ...
          151 83 175; ...
          236 177 95] ./ 255;
for i = 1 : 5
    fname = fullfile(files(6-i).folder,files(6-i).name);
    tmp = load(fname);
    tmp = tmp(1:end-72);
    plot(t,tmp,'-','Color',colors(i,:),'LineWidth',3); hold on; grid on;
    [R2(i),RMSE(i),NSE(i)] = estimate_evaluation_metric(dq(:),tmp(:));
    strs = ['R^{2} = ' num2str(round(R2(i),2)) ', NSE = ' num2str(round(NSE(i),2))];
    tt    = add_title(gca,strs,15,'in');
    tt.Color = colors(i,:);
    tt.Position(2) = tt.Position(2) - (i-1)*0.03;
end
plot(t,dq,'k--','LineWidth',3); 

xlim([t(1) t(end)]);
ylim([0 5350]);
datetick('x','mmmdd','keeplimits');
legend(names,'FontSize',13,'FontWeight','bold','Interpreter','tex','NumColumns', 1);
set(gca,'FontSize',15)
ylabel('[m^{3}/s]','FontSize',18,'FontWeight','bold');

axs(2) = subplot(2,2,2);
colors = [51  0   174; ...
          151 83  175; ...
          144 107 141; ...
          191 145 113; ...
          221 181 152] ./255;

files = dir('hires-ensemble6/*.txt');
files = files([1 3 4 5 2]);

k = 1;
for i = [1 2 5]
    fname = fullfile(files(6-i).folder,files(6-i).name);
    tmp = load(fname);
    tmp = tmp(1:end-72);
    plot(t,tmp,'-','Color',colors(i,:),'LineWidth',3); hold on; grid on;
    [R2(i),RMSE(i),NSE(i)] = estimate_evaluation_metric(dq(:),tmp(:));
    strs = ['Peak = ' num2str(round(max(tmp))) ' [m^{3}/s]'];
    tt    = add_title(gca,strs,15,'in');
    tt.Color = colors(i,:);
    tt.Position(2) = tt.Position(2) - (k-1)*0.03;
    k = k + 1;
end
plot(t,dq,'k--','LineWidth',3); 
xlim([t(1) t(end)]);
datetick('x','mmmdd','keeplimits');
legend('Wet SM','Irene','Dry SM','Observation','FontSize',13,'FontWeight','bold','Interpreter','tex','NumColumns', 1);
set(gca,'FontSize',15)
ylabel('[m^{3}/s]','FontSize',18,'FontWeight','bold');


axs(3) = subplot(2,2,3);
t = t0 : t0 + 7;

load('accumulated_runoff.mat');
acc_qrun = fliplr(acc_qrun);
ave_soil = fliplr(ave_soil);
ave_surf = fliplr(ave_surf);
acc_qover = fliplr(acc_qover);
ave_qrun  = fliplr(ave_qrun);
ave_qover = fliplr(ave_qover);
load('../data/nlcd_mesh.mat');
nlcd       = unique(nlcd_mesh);
a = reshape(sum(nlcd_qrun,1),[11 5]);
b = reshape(sum(nlcd_qrun([2 3 4 5],:,:),1),[11 5]);
for i = [1 2 5]
    plot(t,acc_qrun(1:8,i),'-','Color',colors(i,:),'LineWidth',2); hold on; grid on;
end
datetick('x','mmmdd','keeplimits');
set(gca,'FontSize',15);
xlim([t(1) t(end)]);
ylabel('[mm]','FontSize',18,'FontWeight','bold');
axs(4) = subplot(2,2,4);
for i = [1 2 5]
    plot(t,ave_soil(1:8,i),'-','Color',colors(i,:),'LineWidth',2); hold on; grid on;
end
datetick('x','mmmdd','keeplimits');
set(gca,'FontSize',15);
xlim([t(1) t(end)]);
ylabel('[-]','FontSize',18,'FontWeight','bold');

leg = legend('Wet SM','Irene','Dry SM','FontSize',12,...
             'FontWeight','bold','Orientation','horizontal');

axs(1).Position(3) = axs(1).Position(3)+0.05;
add_title(axs(1), '(a). Sensitivity of Discharge to Manning Coefficient',18,'out');
axs(2).Position(3) = axs(2).Position(3)+0.05;
add_title(axs(2), '(b). Sensitivity of Discharge to Anticidnet Mositure Condition',18,'out');
axs(3).Position(3) = axs(3).Position(3)+0.05;
axs(3).Position(2) = axs(3).Position(2)+0.05;
add_title(axs(3), '(c). Accumulated Runoff',18,'out');
axs(4).Position(3) = axs(4).Position(3)+0.05;
axs(4).Position(2) = axs(4).Position(2)+0.05;
add_title(axs(4), '(d). Average Soil Moisture',18,'out');
pos = get(axs(4),'Position');
leg.Position(2) = pos(2) + 0.005;

exportgraphics(gcf,'Calibration_streamflow.jpg','Resolution',400);

figure; set(gcf,'Position',[10 10 1400 500]);
axs(1) = subplot(1,2,1);
for i = [1 2 5]
    plot(t,ave_qover(1:8,i),'-','Color',colors(i,:),'LineWidth',2); hold on; grid on;
end
datetick('x','mmmdd','keeplimits');
set(gca,'FontSize',15);
ylim([0 60]);
ylabel('[mm/day]','FontSize',18,'FontWeight','bold');
add_title(gca,'(a). Surface Runoff',20,'out');
leg = legend('Wet SM','Irene','Dry SM','FontSize',15,...
             'FontWeight','bold','Orientation','horizontal');
axs(2) = subplot(1,2,2);
for i = [1 2 5]
    plot(t,ave_qrun(1:8,i) - ave_qover(1:8,i),'-','Color',colors(i,:),'LineWidth',2); hold on; grid on;
end
datetick('x','mmmdd','keeplimits');
set(gca,'FontSize',15);
ylim([0 60]);
axs(2).Position(1) = axs(2).Position(1) - 0.05;
add_title(gca,'(b). Subsurface Runoff',20,'out');
exportgraphics(gcf,'Runoff_seperation.jpg','Resolution',400);
% ax1 = axes('Position',[0.16 0.22 0.15 0.10]);
% b = barh(acc_qover(3,:)./acc_qrun(3,:), 'facecolor', 'flat'); grid on;
% yticklabels({}); xticks([0.5 1]);
% xlabel('Surface runoff ratio [-]','FontSize',12,'FontWeight','bold');
% ylabel('Before peak','FontSize',12,'FontWeight','bold');
% ylim([0.25 5.5]);
% b.CData = colors;
% 
% ax2 = axes('Position',[0.45 0.22 0.075 0.1]);
% b = barh((acc_qover(11,:)-acc_qover(3,:))./(acc_qrun(11,:)-acc_qrun(3,:)), 'facecolor', 'flat'); grid on;
% yticklabels({}); xticks([0.25 0.5]);
% ylabel('After peak','FontSize',12,'FontWeight','bold');
% ylim([0.25 5.5]); xlim([0 0.5]);
% b.CData = colors;


%exportgraphics(gcf,'Calibration_streamflow.jpg','Resolution',400);


% figure; set(gcf,'Position',[10 10 900 300]);
% for i = [3 1 2 6]
%     if i <= 5
%         fname = fullfile(files(i).folder,files(i).name);
%         names{i} = files(i).name(1:end-4);
%         tmp = load(fname);
%         if i == 1
%             plot(t,tmp,'g:','LineWidth',3); hold on; grid on;
%         elseif i == 2
%             plot(t,tmp,'r--','LineWidth',3); hold on; grid on;
%         else
%             plot(t,tmp,'b-','LineWidth',3); hold on; grid on;
%         end
%     else
%         plot(data.dn,data.dq,'k-','LineWidth',3); 
%         names{i} = 'USGS';
%     end
% end
% 
% xlim([t(1) t(end)]);
% ylim([0 4150])
% datetick('x','mmmdd','keeplimits');
% legend({'RDycore','Dry IC','Wet IC','Observation'},'FontSize',18,'FontWeight','bold','Interpreter','none');
% set(gca,'FontSize',15)
% ylabel('Discharge [m^{3}/s]','FontSize',18,'FontWeight','bold');
% 
% exportgraphics(gcf,'discharge2.jpg','Resolution',400);
