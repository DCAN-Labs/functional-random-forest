function PlotFDACurves(FDAcellfile,colormapfile,ylimrange,outsuffix)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
load(FDAcellfile,'commcellmat','timepts','timecellmat','datacellmat','accmat','velmat');
if exist('colormapdata','var')
    colormapdata = struct2array(load(colormapfile));
else
    colormapdata = [1,0,0,1,0.700000000000000,0.700000000000000;0,0,1,0.700000000000000,0.700000000000000,1;1,0.700000000000000,0,1,0.700000000000000,0.500000000000000;1,0,1,1,0.700000000000000,1;0.500000000000000,0.500000000000000,0,0.500000000000000,0.500000000000000,0.200000000000000];
end
h = figure(1)
if size(commcellmat{1},1) > 1
    plot(timepts,mean(commcellmat{1}),'Color',colormapdata(1,1:3),'LineWidth',3)
else
    plot(timepts,commcellmat{1},'Color',colormapdata(1,1:3),'LineWidth',3)
end
hold
for j = 2:length(commcellmat)
    if size(commcellmat{j},1) > 1
        plot(timepts,mean(commcellmat{j}),'Color',colormapdata(j,1:3),'LineWidth',3)
    else
        plot(timepts,commcellmat{j},'Color',colormapdata(j,1:3),'LineWidth',3)
    end
end
if exist('ylimrange','var')
    ylim([ylimrange(1) ylimrange(2)])
end
title('Central tendency trajectory data plots for all groups','FontSize',20,'FontWeight','Bold','FontName','Arial')
xlabel('time','FontSize',16,'FontWeight','Bold','FontName','Arial')
ylabel('metric','FontSize',16,'FontWeight','Bold','FontName','Arial')
if exist('outsuffix','var')
    saveas(h,strcat(outsuffix,'_data_',num2str(1),'.tif'));
end
for j = 1:length(commcellmat)
    h = figure(j+1)
    plot(timepts,mean(commcellmat{j}),'Color',colormapdata(j,1:3),'LineWidth',3)
    title(strcat('Individual data plots for group #',num2str(j)),'FontSize',20,'FontWeight','Bold','FontName','Arial')
    xlabel('time','FontSize',16,'FontWeight','Bold','FontName','Arial')
    ylabel('metric','FontSize',16,'FontWeight','Bold','FontName','Arial')
    hold
    for i = 1:size(datacellmat{j},1)
        scatter(timecellmat{j}(i,:),datacellmat{j}(i,:),'MarkerEdgeColor',colormapdata(j,4:6))
    end
    for i = 1:size(commcellmat{j},1)
         plot(timepts,commcellmat{j}(i,:),'Color',colormapdata(j,4:6))
    end
    plot(timepts,mean(commcellmat{j}),'Color',colormapdata(j,1:3),'LineWidth',3)
    if exist('ylimrange','var')
        ylim([ylimrange(1) ylimrange(2)])
    end
    if exist('outsuffix','var')
        saveas(h,strcat(outsuffix,'_data_community_',num2str(j),'.tif'));
    end
end
close all
h = figure(1)
if size(velmat{1},1) > 1
    plot(timepts,mean(velmat{1}),'Color',colormapdata(1,1:3),'LineWidth',3)
else
    plot(timepts,velmat{1},'Color',colormapdata(1,1:3),'LineWidth',3)
end
hold
for j = 2:length(velmat)
    if size(velmat{j},1) > 1
        plot(timepts,mean(velmat{j}),'Color',colormapdata(j,1:3),'LineWidth',3)
    else
        plot(timepts,velmat{j},'Color',colormapdata(j,1:3),'LineWidth',3)
    end
end
title('Central tendency velocity plots for all groups','FontSize',20,'FontWeight','Bold','FontName','Arial')
xlabel('time','FontSize',16,'FontWeight','Bold','FontName','Arial')
ylabel('metric','FontSize',16,'FontWeight','Bold','FontName','Arial')
if exist('outsuffix','var')
    saveas(h,strcat(outsuffix,'_velocity_',num2str(1),'.tif'));
end
for j = 1:length(velmat)
    h = figure(j+1)
    plot(timepts,mean(velmat{j}),'Color',colormapdata(j,1:3),'LineWidth',3)
    title(strcat('Individual velocity plots for group #',num2str(j)),'FontSize',20,'FontWeight','Bold','FontName','Arial')
    xlabel('time','FontSize',16,'FontWeight','Bold','FontName','Arial')
    ylabel('metric','FontSize',16,'FontWeight','Bold','FontName','Arial')
    hold
    for i = 1:size(velmat{j},1)
         plot(timepts,velmat{j}(i,:),'Color',colormapdata(j,4:6))
    end
    plot(timepts,mean(velmat{j}),'Color',colormapdata(j,1:3),'LineWidth',3)
    if exist('outsuffix','var')
        saveas(h,strcat(outsuffix,'_velocity_community_',num2str(j),'.tif'));
    end
end
close all
h = figure(1)
if size(accmat{1},1) > 1
    plot(timepts,mean(accmat{1}),'Color',colormapdata(1,1:3),'LineWidth',3)
else
    plot(timepts,accmat{1},'Color',colormapdata(1,1:3),'LineWidth',3)
end
hold
for j = 2:length(accmat)
    if size(velmat{j},1) > 1
        plot(timepts,mean(accmat{j}),'Color',colormapdata(j,1:3),'LineWidth',3)
    else
        plot(timepts,accmat{j},'Color',colormapdata(j,1:3),'LineWidth',3)
    end
end
title('Central tendency acceleration plots for all groups','FontSize',20,'FontWeight','Bold','FontName','Arial')
xlabel('time','FontSize',16,'FontWeight','Bold','FontName','Arial')
ylabel('metric','FontSize',16,'FontWeight','Bold','FontName','Arial')
if exist('outsuffix','var')
    saveas(h,strcat(outsuffix,'_acceleration_',num2str(1),'.tif'));
end
for j = 1:length(accmat)
    h = figure(j+1)
    plot(timepts,mean(accmat{j}),'Color',colormapdata(j,1:3),'LineWidth',3)
    title(strcat('Individual acceleration plots for group #',num2str(j)),'FontSize',20,'FontWeight','Bold','FontName','Arial')
    xlabel('time','FontSize',16,'FontWeight','Bold','FontName','Arial')
    ylabel('metric','FontSize',16,'FontWeight','Bold','FontName','Arial')
    hold
    for i = 1:size(accmat{j},1)
         plot(timepts,accmat{j}(i,:),'Color',colormapdata(j,4:6))
    end
    plot(timepts,mean(accmat{j}),'Color',colormapdata(j,1:3),'LineWidth',3)
    if exist('outsuffix','var')
        saveas(h,strcat(outsuffix,'_acceleration_community_',num2str(j),'.tif'));
    end
end
end

