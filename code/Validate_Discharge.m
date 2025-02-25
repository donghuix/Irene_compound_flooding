clear;close all;clc;

addpath('/Users/xudo627/Developments/inpoly/');
addpath('/Users/xudo627/Developments/getPanoply_cMap/');
addpath('/Users/xudo627/Developments/mylib/m/');
addpath('/Users/xudo627/Developments/mylib/USGS-download/');

files = dir('hires-ensemble6/*.txt');

% tests = {'qsim_Manning_010','qsim_Manning_025','qsim_Manning_050', ...
%          'qsim_Manning_075','qsim_Manning_100_noBC', 'USGS'};

t0 = datenum(2011,8,26,0,0,0);
t0 = t0 - 5/24;
dt = 3600;
t  = t0 + [dt : dt : 864000] ./3600 ./24;

data = retrieve_daily_streamflow('01463500','2011-08-24','2011-09-05',false,'Discharge');
figure; set(gcf,'Position',[10 10 900 300]);

for i = [3 6]
    if i <= 5
        fname = fullfile(files(i).folder,files(i).name);
        names{i} = files(i).name(1:end-4);
        tmp = load(fname);
        plot(t,tmp,'b-','LineWidth',3); hold on; grid on;
    else
        plot(data.dn,data.dq,'k-','LineWidth',3); 
        names{i} = 'USGS';
    end
end

xlim([t(1) t(end)]);
ylim([0 4150])
datetick('x','mmmdd','keeplimits');
legend({'RDycore','Observation'},'FontSize',18,'FontWeight','bold','Interpreter','none');
set(gca,'FontSize',15)
ylabel('Discharge [m^{3}/s]','FontSize',18,'FontWeight','bold');

exportgraphics(gcf,'discharge1.jpg','Resolution',400);


figure; set(gcf,'Position',[10 10 900 300]);
for i = [3 1 2 6]
    if i <= 5
        fname = fullfile(files(i).folder,files(i).name);
        names{i} = files(i).name(1:end-4);
        tmp = load(fname);
        if i == 1
            plot(t,tmp,'g:','LineWidth',3); hold on; grid on;
        elseif i == 2
            plot(t,tmp,'r--','LineWidth',3); hold on; grid on;
        else
            plot(t,tmp,'b-','LineWidth',3); hold on; grid on;
        end
    else
        plot(data.dn,data.dq,'k-','LineWidth',3); 
        names{i} = 'USGS';
    end
end

xlim([t(1) t(end)]);
ylim([0 4150])
datetick('x','mmmdd','keeplimits');
legend({'RDycore','Dry IC','Wet IC','Observation'},'FontSize',18,'FontWeight','bold','Interpreter','none');
set(gca,'FontSize',15)
ylabel('Discharge [m^{3}/s]','FontSize',18,'FontWeight','bold');

exportgraphics(gcf,'discharge2.jpg','Resolution',400);
