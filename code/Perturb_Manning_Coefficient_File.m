clear;close all;clc;

% Update the Manning coefficient in river.

addpath('/Users/xudo627/Developments/petsc/share/petsc/matlab/');
addpath('/Users/xudo627/Developments/inpoly/');

mesh      = 'delaware_30m';
mesh_file = ['../inputdata/' mesh '.exo'];
proj      = projcrs(26918); % NAD83 / UTM zone 18N
fric_file = ['../inputdata/' mesh '_manning.int32.bin'];

coordx    = ncread(mesh_file,'coordx');
coordy    = ncread(mesh_file,'coordy');
connect   = ncread(mesh_file,'connect1');
xv        = coordx(connect); xc = nanmean(xv)';
yv        = coordy(connect); yc = nanmean(yv)';

chN       = [0.01; 0.02; 0.03; 0.04; 0.05];
names     = {'CH001','CH002','CH003','CH004','CH005'};
data      = struct([]);
N         = PetscBinaryRead(fric_file);
for i = 1 : length(chN)
    data(i).N = N;
end

rivers    = shaperead('/Users/xudo627/Developments/RDycore-tools/data/delaware/hydrorivers.shp');

widths = [1000,500,100,50,50];
for iriv = 4 %: 6
    sm = [];
    for i = 1 : length(rivers)
        if rivers(i).ORD_FLOW == iriv
            [xr,yr] = projfwd(proj,rivers(i).Y',rivers(i).X');
            sm = [sm; [xr yr]];
        end
    end
    tic;

    polyout = polybuffer(sm,'lines',widths(iriv - 3)./2);
    t=toc;
    fprintf('Buffer time = %.1f seconds \n', t);
    
    tic;
    inan = find(isnan(polyout.Vertices(:,1)));
    inall = false(length(xc),1);
    for i = 1 : length(inan) + 1
        if i == 1
            in = inpoly2([xc yc],[polyout.Vertices(1:inan(i),:)]);
        elseif i == length(inan) + 1
            in = inpoly2([xc yc],[polyout.Vertices(inan(i-1)+1:end,:)]);
        else
            in = inpoly2([xc yc],[polyout.Vertices(inan(i-1)+1:inan(i)-1,:)]);
        end
        inall(in) = true;
    end
    t = toc;
    fprintf('Inpoly time = %.1f seconds \n', t);
    
    tic;
    polyrms = holes(polyout);
    for i = 1 : length(polyrms)
        inholes = inpoly2([xc yc],[polyrms(i).Vertices]); 
        inall(inholes) = false;
    end
    t= toc;
    fprintf('Remove holes time = %.1f seconds \n', t);
    
    for j = 1 : 5
        data(j).N(inall) = chN(j);
    end
    figure;
    plot(xc(inall),yc(inall),'k.');
end
% for i = 1 : 5
%     PetscBinaryWrite(['../inputdata/' mesh '_manning.' names{i} '.int32.bin'],data(i).N,'indices','int32');
% end


figure;
patch(xv,yv,N,'LineStyle','none'); colorbar; hold on;
for i = 1 : length(rivers)
    if rivers(i).ORD_FLOW == 5
        [xr,yr] = projfwd(proj,rivers(i).Y',rivers(i).X');
        plot(xr,yr,'r-','LineWidth',1);
    end
end

