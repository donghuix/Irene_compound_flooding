clear;close all;clc;

xc = ncread('../data/domain_mid_atlantic_c240907.nc','xc')-360;
yc = ncread('../data/domain_mid_atlantic_c240907.nc','yc');
xv = ncread('../data/domain_mid_atlantic_c240907.nc','xv')-360;
yv = ncread('../data/domain_mid_atlantic_c240907.nc','yv');
pct_urban = ncread('../data/surface_dataset_mid_atlantic_c240907_default.nc','PCT_URBAN');
pct_urban = nansum(pct_urban,3);
save('../data/pct_urban.mat','pct_urban');

figure;
imagesc(pct_urban); colorbar;

proj    = projcrs(26918);
[xc,yc] = projfwd(proj,yc,xc);

coordx  = ncread('/Users/xudo627/Developments/RDycore-tools/data/delaware/delaware.exo','coordx');
coordy  = ncread('/Users/xudo627/Developments/RDycore-tools/data/delaware/delaware.exo','coordy');
S       = shaperead('/Users/xudo627/Developments/RDycore-tools/data/delaware/delaware.shp');
ind     = find(isnan(S.X));
xbnd    = S.X(1:ind(1)-1)'; ybnd = S.Y(1:ind(1)-1)';
in      = inpoly2([xc(:) yc(:)],[xbnd ybnd]);
figure;
plot(coordx,coordy,'k.'); hold on; grid on;
plot(xc(in),yc(in),'r.'); 
plot(xbnd,ybnd,'g-','LineWidth',2);


t1 = datenum(2011,8,26,0,0,0);
t2 = datenum(2011,9,6,23,0,0);
t  = t1 : 1/24 : t2;
[yrs,mos,das,hrs] = datevec(t);

if 1

for i = 75 %0 : 25 : 100
    load(['../elm/outputs/AMC_' num2str(i) '.mat']);
    fdir = ['../elm/runoff/runoff_AMC_' num2str(i)];
    if ~exist(fdir,'dir')
        mkdir(fdir);
        
    end

    if i == 75 && ~exist(['../elm/runoff/runoff_AMC_' num2str(i) '_urban'],'dir')
       mkdir(['../elm/runoff/runoff_AMC_' num2str(i) '_urban']);
    end

    if i == 75 && ~exist(['../elm/runoff/runoff_AMC_' num2str(i) '_rural'],'dir')
       mkdir(['../elm/runoff/runoff_AMC_' num2str(i) '_rural']);
    end

    qrunoff = qrunoff(:,:,2:end)./1000; % [mm/s] -> [m/s]
    nt = size(qrunoff,3);
    assert(nt == 11*24);
    for j = 1 : nt
        disp(['j = ' num2str(j)]);
        tmp = qrunoff(:,:,j);
        tmp = tmp(in);
        tmp(tmp < 0) = 0;
        tmp(isnan(tmp)) = nanmean(tmp);

        tmp2 = [length(tmp); 1; tmp];

        yrtag = num2str(yrs(j));
        motag = ['0' num2str(mos(j))];
        if das(j) < 10
            datag = ['0' num2str(das(j))];
        else
            datag = num2str(das(j));
        end
        if hrs(j) < 10
            hrtag = ['0' num2str(hrs(j))];
        else
            hrtag = num2str(hrs(j));
        end

        if any(isnan(tmp))
            disp(['j = ' num2str(j)]);
        end

        fout = ['./' fdir '/' yrtag '-' motag '-' datag ':' hrtag '-00.int32.bin'];

        PetscBinaryWrite(fout,tmp2,'indices','int32');
        
        if i == 75 
            tmp = qrunoff(:,:,j);
            tmp(pct_urban < 90) = 0;
            tmp = tmp(in);
            tmp(tmp < 0) = 0;
            tmp(isnan(tmp)) = nanmean(tmp);
    
            tmp2 = [length(tmp); 1; tmp];
            fout = ['../elm/runoff/runoff_AMC_' num2str(i) '_urban/' yrtag '-' motag '-' datag ':' hrtag '-00.int32.bin'];
    
            PetscBinaryWrite(fout,tmp2,'indices','int32');

            tmp = qrunoff(:,:,j);
            tmp(pct_urban >= 90) = 0;
            tmp = tmp(in);
            tmp(tmp < 0) = 0;
            tmp(isnan(tmp)) = nanmean(tmp);
    
            tmp2 = [length(tmp); 1; tmp];
            fout = ['../elm/runoff/runoff_AMC_' num2str(i) '_rural/' yrtag '-' motag '-' datag ':' hrtag '-00.int32.bin'];
    
            PetscBinaryWrite(fout,tmp2,'indices','int32');

        end

    end
    coords= [xc(in)'; yc(in)'];
    array = [sum(in); 2; coords(:)];
    fout = ['./' fdir '/forcing_x_y.int32.bin'];
    PetscBinaryWrite(fout,array,'indices','int32');

end
end