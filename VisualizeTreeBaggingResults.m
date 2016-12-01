function VisualizeTreeBaggingResults(matfile,output_directory,type,group1_data,group2_data,command_file)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
nreps = 100;
if exist('group2_data','var')
    if isempty(group2_data)
        group2_data = 0;
    end
else
    group2_data = 0;
end
if isstruct(group1_data)
    group1_data = struct2array(load(group1_data.path,group1_data.variable));
end
if isstruct(group2_data)
    group2_data = struct2array(load(group2_data.path,group2_data.variable));
end
stuff = load(matfile);
accuracy = stuff.accuracy;
permute_accuracy = stuff.permute_accuracy;
proxmat = stuff.proxmat;
features = stuff.features;
mkdir(output_directory);
switch(type)
    case('classification')
%plot accuracy and permuted accuracy print ttest results on figure itself
%plot total accuracy first
        nbins = 0:0.025:1;
        h = figure(1);
        acc_elements = hist(accuracy(1,:),nbins);
        hist(accuracy(1,:),nbins);
        hold
        perm_elements = hist(permute_accuracy(1,:),nbins);
        hist(permute_accuracy(1,:),nbins);
        acc_h = findobj(gca,'Type','patch');
        permute_h = acc_h(1);
        acc_h = acc_h(2);
        set(permute_h,'FaceColor',[1 0 0],'EdgeColor','k','FaceAlpha',0.5);
        set(acc_h,'FaceColor',[0 0 1],'EdgeColor','k');
        xlim([-0.025 1.025]);
        ylim([0 (max([ max(acc_elements); max(perm_elements) ])*1.2)]);
        xlabel('total accuracy','FontSize',20,'FontName','Arial','FontWeight','Bold');
        ylabel('frequency','FontSize',20,'FontName','Arial','FontWeight','Bold');
        title('observed and permuted accuracy distributions across both groups','FontSize',24,'FontName','Arial','FontWeight','Bold');       
        set(gca,'FontName','Arial','FontSize',18,'PlotBoxAspectRatio',[1.5 1.2 1.5]);
        legend('accuracy','permuted accuracy'); 
        set(gcf,'Position',[0 0 1024 768],'PaperUnits','points','PaperPosition',[0 0 1024 768]);
        [~, P, CI, STATS] = ttest2(accuracy(1,:),permute_accuracy(1,:));
        if P == 0
            P = realmin;
        end
        text(.1,max([ max(acc_elements); max(perm_elements) ])*1.2/1.05,strcat('t(',num2str(STATS.df),')=',num2str(STATS.tstat),', {\it p}','=',num2str(P),', lowerCI=',num2str(CI(1)),', upperCI=',num2str(CI(2))),'FontName','Arial','FontSize',14);
        saveas(h,strcat(output_directory,'/total_accuracy.tif'));
        hold
%plot group accuracies in a loop
    for i = 2:size(accuracy,1);
        h = figure(i);
        acc_elements = hist(accuracy(i,:),nbins);
        hist(accuracy(i,:),nbins);
        hold
        perm_elements = hist(permute_accuracy(i,:),nbins);
        hist(permute_accuracy(i,:),nbins);
        acc_h = findobj(gca,'Type','patch');
        permute_h = acc_h(1);
        acc_h = acc_h(2);
        set(permute_h,'FaceColor',[1 0 0],'EdgeColor','k','FaceAlpha',0.5);
        set(acc_h,'FaceColor',[0 0 1],'EdgeColor','k');
        xlim([-0.025 1.025]);
        xlabelstr = strcat('group',num2str(i-1),' -- accuracy');
        xlabel(xlabelstr,'FontSize',20,'FontName','Arial','FontWeight','Bold');
        ylabel('frequency','FontSize',20,'FontName','Arial','FontWeight','Bold');
        titlestr = strcat('observed and permuted accuracy distributions for group',num2str(i-1));
        title(titlestr,'FontSize',24,'FontName','Arial','FontWeight','Bold');
        ylim([0 (max([ max(acc_elements); max(perm_elements) ])*1.2)]);        
        set(gca,'FontName','Arial','FontSize',18,'PlotBoxAspectRatio',[1.5 1.2 1.5]);
        legend('accuracy','permuted accuracy');
        set(gcf,'Position',[0 0 1024 768],'PaperUnits','points','PaperPosition',[0 0 1024 768]);
        [~, P, CI, STATS] = ttest2(accuracy(i,:),permute_accuracy(i,:));
        if P == 0
            P = realmin;
        end
        text(.1,max([ max(acc_elements); max(perm_elements) ])*1.2/1.05,strcat('t(',num2str(STATS.df),')=',num2str(STATS.tstat),', {\it p}','=',num2str(P),', lowerCI=',num2str(CI(1)),', upperCI=',num2str(CI(2))),'FontName','Arial','FontSize',14);
        saveas(h,strcat(output_directory,'/group', num2str(i-1),'_accuracy.tif'));
        hold
    end
    nfigures = i;
    case('regression')
%plot observed and permuted regression results and print ttest results on figure itself
%plot mean error first
        nbins = round(size(accuracy,2)/20);
        if nbins < 10
            nbins = 10;
        end
        h = figure(1);
        acc_elements = hist(accuracy(1,:),nbins);
        hist(accuracy(1,:),nbins);
        hold
        perm_elements = hist(permute_accuracy(1,:),nbins);
        hist(permute_accuracy(1,:),nbins);
        limits = xlim;
        acc_h = findobj(gca,'Type','patch');
        permute_h = acc_h(1);
        acc_h = acc_h(2);
        set(permute_h,'FaceColor',[1 0 0],'EdgeColor','k','FaceAlpha',0.5);
        set(acc_h,'FaceColor',[0 0 1],'EdgeColor','k');
        xlabel('mean error','FontSize',20,'FontName','Arial','FontWeight','Bold');
        ylabel('frequency','FontSize',20,'FontName','Arial','FontWeight','Bold');
        title('observed and permuted mean error distributions across both groups','FontSize',24,'FontName','Arial','FontWeight','Bold');
        ylim([0 (max([ max(acc_elements); max(perm_elements) ])*1.2)]);
        set(gca,'FontName','Arial','FontSize',18,'PlotBoxAspectRatio',[1.5 1.2 1.5]);
        legend('mean error','permuted mean error');
        set(gcf,'Position',[0 0 1024 768],'PaperUnits','points','PaperPosition',[0 0 1024 768]);
        [~, P, CI, STATS] = ttest2(accuracy(1,:),permute_accuracy(1,:));
        if P == 0
            P = realmin;
        end        
        text(limits(2)/10,max([ max(acc_elements); max(perm_elements) ])/1.05,strcat('t(',num2str(STATS.df),')=',num2str(STATS.tstat),', {\it p}','=',num2str(P),', lowerCI=',num2str(CI(1)),', upperCI=',num2str(CI(2))),'FontName','Arial','FontSize',14);
        saveas(h,strcat(output_directory,'/mean_error.tif'));    
        hold
%plot correlations second
        h = figure(2);
        acc_elements = hist(accuracy(2,:),nbins);
        hist(accuracy(2,:),nbins);
        hold
        perm_elements = hist(permute_accuracy(2,:),nbins);
        hist(permute_accuracy(2,:),nbins);
        limits = xlim;
        acc_h = findobj(gca,'Type','patch');
        permute_h = acc_h(1);
        acc_h = acc_h(2);
        set(permute_h,'FaceColor',[1 0 0],'EdgeColor','k','FaceAlpha',0.5);
        set(acc_h,'FaceColor',[0 0 1],'EdgeColor','k');
        xlabel('correlation','FontSize',20,'FontName','Arial','FontWeight','Bold');
        ylabel('frequency','FontSize',20,'FontName','Arial','FontWeight','Bold');
        title('observed and permuted correlation distributions across both groups','FontSize',24,'FontName','Arial','FontWeight','Bold');
        ylim([0 (max([ max(acc_elements); max(perm_elements) ])*1.2)]);
        set(gca,'FontName','Arial','FontSize',18,'PlotBoxAspectRatio',[1.5 1.2 1.5]);
        legend('correlation','permuted correlation');
        set(gcf,'Position',[0 0 1024 768],'PaperUnits','points','PaperPosition',[0 0 1024 768]);
        [~, P, CI, STATS] = ttest2(accuracy(2,:),permute_accuracy(2,:));
        if P == 0
            P = realmin;
        end        
        text(limits(2)/10,max([ max(acc_elements); max(perm_elements) ])/1.05,strcat('t(',num2str(STATS.df),')=',num2str(STATS.tstat),', {\it p}','=',num2str(P),', lowerCI=',num2str(CI(1)),', upperCI=',num2str(CI(2))),'FontName','Arial','FontSize',14);
        saveas(h,strcat(output_directory,'/correlation.tif'));
        hold
%plot intra-class correlation coefficient (ICC) third
        h = figure(3);
        acc_elements = hist(accuracy(3,:),nbins);
        hist(accuracy(3,:),nbins);
        hold
        perm_elements = hist(permute_accuracy(3,:),nbins);
        hist(permute_accuracy(3,:),nbins);
        limits = xlim;
        acc_h = findobj(gca,'Type','patch');
        permute_h = acc_h(1);
        acc_h = acc_h(2);
        set(permute_h,'FaceColor',[1 0 0],'EdgeColor','k','FaceAlpha',0.5);
        set(acc_h,'FaceColor',[0 0 1],'EdgeColor','k');
        xlabel('intra-class correlation coefficient (ICC)','FontSize',20,'FontName','Arial','FontWeight','Bold');
        ylabel('frequency','FontSize',20,'FontName','Arial','FontWeight','Bold');
        title('observed and permuted ICC distributions across both groups','FontSize',24,'FontName','Arial','FontWeight','Bold');
        ylim([0 (max([ max(acc_elements); max(perm_elements) ])*1.2)]);     
        set(gca,'FontName','Arial','FontSize',18,'PlotBoxAspectRatio',[1.5 1.2 1.5]);
        legend('ICC','permuted ICC');
        set(gcf,'Position',[0 0 1024 768],'PaperUnits','points','PaperPosition',[0 0 1024 768]);
        [~, P, CI, STATS] = ttest2(accuracy(3,:),permute_accuracy(3,:));
        if P == 0
            P = realmin;
        end
        text(limits(2)/10,max([ max(acc_elements); max(perm_elements) ])/1.05,strcat('t(',num2str(STATS.df),')=',num2str(STATS.tstat),', {\it p}','=',num2str(P),', lowerCI=',num2str(CI(1)),', upperCI=',num2str(CI(2))),'FontName','Arial','FontSize',14);
        saveas(h,strcat(output_directory,'/ICC.tif'));
        hold
        nfigures = 3;
end
%generate proximity matrix figure
proxmat_sum = zeros(size(proxmat{1}));
for i = 1:max(size(proxmat))
proxmat_sum = proxmat_sum + proxmat{i};
end
h = figure(1 + nfigures);
imagesc(proxmat_sum./max(size(proxmat)));
colormap(jet)
xlabel('subject #','FontSize',20,'FontName','Arial','FontWeight','Bold');
ylabel('subject #','FontSize',20,'FontName','Arial','FontWeight','Bold');
title('proximity matrix','FontName','Arial','FontSize',24,'FontWeight','Bold');
set(gca,'FontName','Arial','FontSize',18);
set(gcf,'Position',[0 0 1024 768],'PaperUnits','points','PaperPosition',[0 0 1024 768]);
caxis([0 max(max(triu(proxmat_sum./max(size(proxmat)),1)))]);
colorbar
saveas(h,strcat(output_directory,'/proximity_matrix.tif'));
%plot features used
h = figure(2 + nfigures);
bar(features)
xlabel('feature #','FontSize',20,'FontName','Arial','FontWeight','Bold');
ylabel('# times used','FontSize',20,'FontName','Arial','FontWeight','Bold');
title('frequency of features used across all random forests','FontName','Arial','FontSize',24,'FontWeight','Bold');
set(gca,'FontName','Arial','FontSize',18);
set(gcf,'Position',[0 0 1024 768],'PaperUnits','points','PaperPosition',[0 0 1024 768]);
saveas(h,strcat(output_directory,'/feature_usage.tif'));
%incorporating newer community detection here:
    [community_matrix, sorting_order] = RunAndVisualizeCommunityDetection(proxmat,output_directory,command_file,nreps);
    %reproduce sorted matrix
    proxmat_sum_sorted = proxmat_sum(sorting_order,sorting_order);
    h = figure(3 + nfigures);
    imagesc(proxmat_sum_sorted./max(size(proxmat)));
    colormap(jet)
    xlabel('subject #','FontSize',20,'FontName','Arial','FontWeight','Bold');
    ylabel('subject #','FontSize',20,'FontName','Arial','FontWeight','Bold');
    title('proximity matrix','FontName','Arial','FontSize',24,'FontWeight','Bold');
    set(gca,'FontName','Arial','FontSize',18);
    set(gcf,'Position',[0 0 1024 768],'PaperUnits','points','PaperPosition',[0 0 1024 768]);
    caxis([0 max(max(triu(proxmat_sum_sorted./max(size(proxmat)),1)))]);
    colorbar
    saveas(h,strcat(output_directory,'/proximity_matrix_sorted.tif'));
    %visualize community matrix
    h = figure(4 + nfigures);
    imagesc(community_matrix);
    colormap(colorcube)
    caxis([min(min(community_matrix)) max(max(community_matrix))]);
    xlabel('edge density (%)','FontSize',20,'FontName','Arial','FontWeight','Bold');
    ylabel('subject #','FontSize',20,'FontName','Arial','FontWeight','Bold');
    title('subgroups identified by random forests','FontName','Arial','FontSize',24,'FontWeight','Bold');
    set(gca,'FontName','Arial','FontSize',18);
    set(gcf,'Position',[0 0 1024 768],'PaperUnits','points','PaperPosition',[0 0 1024 768]);
    saveas(h,strcat(output_directory,'/community_matrix.tif'));
    %visualize sorted commmunity matrix
    h = figure(5 + nfigures);
    community_matrix_sorted = community_matrix(sorting_order);
    imagesc(community_matrix_sorted);
    colormap(colorcube)
    caxis([min(min(community_matrix_sorted)) max(max(community_matrix_sorted))]);
    xlabel('edge density (%)','FontSize',20,'FontName','Arial','FontWeight','Bold');
    ylabel('subject #','FontSize',20,'FontName','Arial','FontWeight','Bold');
    title('subgroups identified by random forests','FontName','Arial','FontSize',24,'FontWeight','Bold');
    set(gca,'FontName','Arial','FontSize',18);
    set(gcf,'Position',[0 0 1024 768],'PaperUnits','points','PaperPosition',[0 0 1024 768]);
    saveas(h,strcat(output_directory,'/community_matrix_sorted.tif'));
    %visualize use of features
    feature_matrix=GenerateSubgroupFeatureMatrix(community_matrix,group1_data,group2_data);
    h=figure(17);
    errorbar(repmat(1:size(feature_matrix,1),size(feature_matrix,2),1).',feature_matrix(:,:,2),feature_matrix(:,:,2) - feature_matrix(:,:,1),feature_matrix(:,:,3) - feature_matrix(:,:,2))
    xlabel('feature #','FontSize',20,'FontName','Arial','FontWeight','Bold');
    ylabel('percentile of feature','FontSize',20,'FontName','Arial','FontWeight','Bold');
    set(gca,'FontName','Arial','FontSize',18);
    set(gcf,'Position',[0 0 1024 768],'PaperUnits','points','PaperPosition',[0 0 1024 768]);
    legend('toggle','Location','Best')
    title('normalized feature percentiles by subgroup','FontSize',24,'FontName','Arial','FontWeight','Bold');
    saveas(h,strcat(output_directory,'/features_by_subgroup_plot.tif'));
    save(strcat(output_directory,'/community_assignments.mat'),'community_matrix','community_matrix_sorted','sorting_order');
close all
end


