function zoomin(xv,yv,proj,h,savefig)
    if nargin == 4
        savefig = false;
    end

    cmap = [ [255 255 255]; ... 
             [220 20  60 ]; ...
             [30  144 255] ]./255;

    xbox1 = [ 4.82  4.88   4.88  4.82  4.82].*1e5;
    ybox1 = [44.16 44.16  44.22 44.22 44.16].*1e5;
    [latbox1,lonbox1] = projinv(proj,xbox1,ybox1);
    % Region 2
    xbox2 = [ 4.52  4.72   4.72  4.52  4.52].*1e5;
    ybox2 = [43.60 43.60  43.80 43.80 43.60].*1e5;
    [latbox2,lonbox2] = projinv(proj,xbox2,ybox2);
    % Region 3
    xbox3 = [ 4.95  5.15   5.15  4.95  4.95].*1e5;
    ybox3 = [46.50 46.50  46.70 46.70 46.50].*1e5;
    [latbox3,lonbox3] = projinv(proj,xbox3,ybox3);

    in1  = inpoly2([mean(xv)' mean(yv)'],[xbox1' ybox1']);
    xv1  = xv(:,in1);
    yv1  = yv(:,in1);
    h1   = h(in1);

    in2  = inpoly2([mean(xv)' mean(yv)'],[xbox2' ybox2']);
    xv2  = xv(:,in2);
    yv2  = yv(:,in2);
    h2   = h(in2);

    in3  = inpoly2([mean(xv)' mean(yv)'],[xbox3' ybox3']);
    xv3  = xv(:,in3);
    yv3  = yv(:,in3);
    h3   = h(in3);

    figure; set(gcf,'Position',[10 10 1000 1000]);
    patch(xv1,yv1,h1,'LineStyle','none'); hold on; cb = colorbar; colormap(cmap);
    xlim([xbox1(1) xbox1(2)]);
    ylim([ybox1(1) ybox1(3)]);
    clim([-0.5 2.5]);
    cb.Ticks = [0 1 2] ; %Create 8 ticks from zero to 1
    cb.TickLabels = {'No flood','Flooded','Permenant water'};
    cb.FontSize = 15;
    cb.FontWeight = 'bold';
    set(gca,'Color',[0.75 0.75 0.75]);
    
    if savefig
        exportgraphics(gcf,'Region1.jpg','Resolution',400);
    end
    
    figure; set(gcf,'Position',[10 10 1000 1000]);
    patch(xv2,yv2,h2,'LineStyle','none'); hold on; cb = colorbar; colormap(cmap);
    xlim([xbox2(1) xbox2(2)]);
    ylim([ybox2(1) ybox2(3)]);
    clim([-0.5 2.5]);
    cb.Ticks = [0 1 2] ; %Create 8 ticks from zero to 1
    cb.TickLabels = {'No flood','Flooded','Permenant water'};
    cb.FontSize = 15;
    cb.FontWeight = 'bold';
    set(gca,'Color',[0.75 0.75 0.75]);

    if savefig
        exportgraphics(gcf,'Region2.jpg','Resolution',400);
    end

    figure; set(gcf,'Position',[10 10 1000 1000]);
    patch(xv3,yv3,h3,'LineStyle','none'); hold on; cb = colorbar; colormap(cmap);
    xlim([xbox3(1) xbox3(2)]);
    ylim([ybox3(1) ybox3(3)]);
    clim([-0.5 2.5]);
    cb.Ticks = [0 1 2] ; %Create 8 ticks from zero to 1
    cb.TickLabels = {'No flood','Flooded','Permenant water'};
    cb.FontSize = 15;
    cb.FontWeight = 'bold';
    set(gca,'Color',[0.75 0.75 0.75]);

    if savefig
        exportgraphics(gcf,'Region3.jpg','Resolution',400);
    end
end