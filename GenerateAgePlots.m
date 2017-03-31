function GenerateAgePlots(subject_ID,age_data,outputfilename,group_data,min_age_thresh_lo,min_age_thresh_hi,ntimepts)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
[age_data,age_data_index] = sort(age_data,'ascend');
subject_ID = subject_ID(age_data_index);
if exist('group_data','var') == 0
    group_data = 0;
end
if exist('min_age_thresh_lo','var') == 0
    min_age_thresh_lo = 0;
end
if exist('min_age_thresh_hi','var') == 0
    min_age_thresh_hi = 0;
end
if exist('ntimepts','var') == 0
    ntimepts = 0;
end
if isempty(ntimepts)
    ntimepts = 0;
end
if isempty(min_age_thresh_lo)
    min_age_thresh_lo = 0;
end
if isempty(min_age_thresh_hi)
    min_age_thresh_hi = 0;
end
if isempty(group_data)
    group_data = 0;
end
if group_data ~= 0
    groups = unique(group_data);
    groups = groups(groups > -900);
    groups = groups(isnan(groups) == 0);
    ngroups = max(size(groups));
    for i = 1:ngroups
        switch(i)
            case(1)
                groupname(1,1) = groups(1);
                groupcolor(1,:) = [0 0 0];
            case(2)
                groupname(2,1) = groups(2);
                groupcolor(2,:) = [1 0 0];
            case(3)
                groupname(3,1) = groups(3);
                groupcolor(3,:) = [0 0 1];
            case(4)
                groupname(4,1) = groups(4);                
                groupcolor(4,:) = [1 0 1];
            case(5)
                groupname(5,1) = groups(5);                
                groupcolor(5,:) = [0.5 0.5 0];
        end
    end
end
subjects = unique(subject_ID);
subject_count = 0;
for i = 1:size(subjects,1)
    [age_data_index] = find(subject_ID == subjects(i));
    [min_age_temp, min_index] = min(age_data(find(subject_ID == subjects(i))));
    if min_age_thresh_lo == 0 || min_age_temp >= min_age_thresh_lo
        if min_age_thresh_hi == 0 || min_age_temp <= min_age_thresh_hi
            subject_count = subject_count + 1;
            min_age(subject_count,1) = min_age_temp;
            min_age_index(subject_count,1) = age_data_index(min_index);
        end
    end
end
[~,subject_index] = sort(min_age,'ascend');
subjects_sorted = subject_ID(min_age_index(subject_index));
close all
h = figure(1);
hold
for i = 1:size(subjects_sorted,1)
    R = 0;
    G = 0;
    B = 0;    
    if group_data ~= 0
        group_to_use = group_data(min_age_index(i));
        if group_to_use > 0
            R = groupcolor(groups(group_to_use),1);
            G = groupcolor(groups(group_to_use),2);
            B = groupcolor(groups(group_to_use),3);
        else
            R = 0.5;
            G = 0.5;
            B = 0.5;
        end
    end
    if ntimepts == 0
        plot(age_data(find(subject_ID == subjects_sorted(i))),zeros(max(size(find(subject_ID == subjects_sorted(i)))),1) + size(subjects_sorted,1) + 1 - i,'Color',[R G B],'Marker','o');
    elseif ntimepts == -1   
        temp_age_data = age_data(find(subject_ID == subjects_sorted(i)));
        plotted_age_data = zeros(3,1);
        plotted_age_data(1,1) = min(temp_age_data);
        plotted_age_data(2,1) = median(temp_age_data);
        plotted_age_data(3,1) = max(temp_age_data);
        plot(plotted_age_data,zeros(3,1) + size(subjects_sorted,1) + 1 - i,'Color',[R G B],'Marker','o');
    else
        plot(age_data(find(subject_ID == subjects_sorted(i),ntimepts)),zeros(max(size(find(subject_ID == subjects_sorted(i),ntimepts))),1) + size(subjects_sorted,1) + 1 - i,'Color',[R G B],'Marker','o');
    end
end
title('Subject by age at visit plot','FontSize',20,'FontWeight','Bold','FontName','Arial');
xlabel('age (years)','FontSize',16,'FontWeight','Bold','FontName','Arial');
ylabel('subject #','FontSize',16,'FontWeight','Bold','FontName','Arial');
set(gca,'FontName','Arial','FontSize',18,'PlotBoxAspectRatio',[1.5 1.2 1.5]);
set(gcf,'Position',[0 0 1024 768],'PaperUnits','points','PaperPosition',[0 0 1024 768]);   
hold
saveas(h,strcat(outputfilename,'.tif'));
close all
end

