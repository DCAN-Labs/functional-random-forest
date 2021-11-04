function VisualizeTreeBaggingResults(matfile,output_directory,type,group1_data,group2_data,command_file,varargin)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
nreps = 10;
lowdensity = 0.2;
highdensity = 1;
stepdensity = 0.05;
if isempty(varargin) == 0
    for i = 1:size(varargin,2)
        if isstruct(varargin{i}) == 0
            switch(varargin{i})
                case('LowDensity')
                    lowdensity = varargin{i+1};
                case('HighDensity')
                    highdensity = varargin{i+1};
                case('StepDensity')
                    stepdensity = varargin{i+1};
                case('InfomapFile')
					infomapfile = varargin{i+1};
                case('InfomapNreps')
                    nreps = varargin{i+1};
            end
        end
    end
end
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
ncomps_per_rep = length(lowdensity:stepdensity:highdensity);
stuff = load(matfile);
accuracy = stuff.accuracy;
permute_accuracy = stuff.permute_accuracy;
proxmat = stuff.proxmat;
features = stuff.features;
plot_performance_by_subgroups = 0;
try
    if isempty(dir(command_file))
        errmsg = strcat('error: infomap command not found, command_file variable not valid, quitting...',command_file);
        warning('TB:comfilechk',errmsg);
    end
catch
    errmsg = strcat('error: infomap command not found, command_file variable not valid, quitting...',command_file);
    warning('TB:comfilechk',errmsg);
end
try
    if isempty(dir(infomapfile))
        errmsg = strcat('error: infomap repo not found, infomapfile variable not valid, quitting...',infomapfile);
        error('TB:comfilechk',errmsg);
    end
catch
    errmsg = strcat('error: infomap repo not found, infomapfile variable not valid, quitting...',infomapfile);
    error('TB:comfilechk',errmsg);
end
try
    oob_error = stuff.outofbag_error;
catch
    warning('out of bag (OOB) error variable not found. Skipping OOB error visualization');
    oob_error = NaN;
end
try
    oob_varimp = stuff.outofbag_varimp;
catch
    warning('out of bag (OOB) variable importance measure not found. Skipping OOB variable importance visualization');
    oob_varimp = NaN;
end
try
    group1class = stuff.group1class;
    group2class = stuff.group2class;
    allclass = [group1class ; group2class];
    plot_performance_by_subgroups = 1;
catch
    warning('could not find subject specific accuracy variable. Skipping individual and subgroup accuracy visualizations');
end   
outcomes_recorded = 0;
mkdir(output_directory);
Pvalues = size(accuracy,1);
switch(type)
    case('classification')
%plot accuracy and permuted accuracy print ttest results on figure itself
%plot total accuracy first
        try
            final_outcomes = stuff.final_outcomes;
            outcomes_recorded = 1;
        catch
            warning('final outcomes values are not found. community detection will operate on entire matrix');
            final_outcomes = NaN;
        end
        if outcomes_recorded == 1
            try
                group1scores = stuff.group1scores;
                group2scores = stuff.group2scores;
                group1predict = stuff.group1predict;
                group2predict = stuff.group2predict;
                FRFAUC = ComputeROCfromFRF(group1predict,group2predict,group1scores,group2scores,final_outcomes,strcat(output_directory,'/summary'));
                save(strcat(output_directory,'/AUC.mat'),'FRFAUC','-v7.3');
            catch
                warning('could not generate ROC curves -- skipping');
            end
        end
        PlotTitle = {'Total'};
        nbins = 0:0.025:1;
        h = figure(1);
        acc_elements = hist(accuracy(1,:),nbins);
        hist(accuracy(1,:),nbins);
        size(accuracy)
        size(permute_accuracy)
        hold
        if isnan(permute_accuracy) == 0
            perm_elements = hist(permute_accuracy(1,:),nbins);
            hist(permute_accuracy(1,:),nbins);
            acc_h = findobj(gca,'Type','patch');
            size(acc_h)
            permute_h = acc_h(1);
            acc_h = acc_h(2);
            set(permute_h,'FaceColor',[1 0 0],'EdgeColor','k','FaceAlpha',0.5);            
        else
            acc_h = findobj(gca,'Type','patch');
        end
        set(acc_h,'FaceColor',[0 0 1],'EdgeColor','k');
        xlim([-0.025 1.025]);
        if isnan(permute_accuracy) == 0
            ylim([0 (max([ max(acc_elements); max(perm_elements) ])*1.2)]);
        else
            ylim([0 max(acc_elements)*1.2 ]);
        end
        xlabel('total accuracy','FontSize',20,'FontName','Arial','FontWeight','Bold');
        ylabel('frequency','FontSize',20,'FontName','Arial','FontWeight','Bold');
        title('observed and permuted accuracy distributions across both groups','FontSize',24,'FontName','Arial','FontWeight','Bold');       
        set(gca,'FontName','Arial','FontSize',18,'PlotBoxAspectRatio',[1.5 1.2 1.5]);
        if isnan(permute_accuracy) == 0
            legend('accuracy','permuted accuracy'); 
        else
            legend('accuracy');
        end
        set(gcf,'Position',[0 0 1024 768],'PaperUnits','points','PaperPosition',[0 0 1024 768]);
        if isnan(permute_accuracy) == 0
            [~, P, CI, STATS] = ttest2(accuracy(1,:),permute_accuracy(1,:));
            if P == 0
                P = realmin;
            end
            Pvalues(1) = P;
            text(.1,max([ max(acc_elements); max(perm_elements) ])*1.2/1.05,strcat('t(',num2str(STATS.df),')=',num2str(STATS.tstat),', {\it p}','=',num2str(P),', lowerCI=',num2str(CI(1)),', upperCI=',num2str(CI(2))),'FontName','Arial','FontSize',14);
        end
        saveas(h,strcat(output_directory,'/total_accuracy.tif'));
        hold
%plot group accuracies in a loop
    for i = 2:size(accuracy,1)
        PlotTitle(end+1) = {strcat('group',num2str(i-1))};
        h = figure(i);
        acc_elements = hist(accuracy(i,:),nbins);
        hist(accuracy(i,:),nbins);
        hold
        if isnan(permute_accuracy) == 0
            perm_elements = hist(permute_accuracy(i,:),nbins);
            hist(permute_accuracy(i,:),nbins);
            acc_h = findobj(gca,'Type','patch');
            permute_h = acc_h(1);
            acc_h = acc_h(2);
            set(permute_h,'FaceColor',[1 0 0],'EdgeColor','k','FaceAlpha',0.5);
        else
            acc_h = findobj(gca,'Type','patch');
        end
        set(acc_h,'FaceColor',[0 0 1],'EdgeColor','k');
        xlim([-0.025 1.025]);
        xlabelstr = strcat('group',num2str(i-1),' -- accuracy');
        xlabel(xlabelstr,'FontSize',20,'FontName','Arial','FontWeight','Bold');
        ylabel('frequency','FontSize',20,'FontName','Arial','FontWeight','Bold');
        titlestr = strcat('observed and permuted accuracy distributions for group',num2str(i-1));
        title(titlestr,'FontSize',24,'FontName','Arial','FontWeight','Bold');
        if isnan(permute_accuracy) == 0
            ylim([0 (max([ max(acc_elements); max(perm_elements) ])*1.2)]);
        else
            ylim([0 max(acc_elements)*1.2]);
        end
        set(gca,'FontName','Arial','FontSize',18,'PlotBoxAspectRatio',[1.5 1.2 1.5]);
        if isnan(permute_accuracy) == 0
            legend('accuracy','permuted accuracy');
        else
            legend('accuracy');
        end
        set(gcf,'Position',[0 0 1024 768],'PaperUnits','points','PaperPosition',[0 0 1024 768]);
        if isnan(permute_accuracy) == 0
            [~, P, CI, STATS] = ttest2(accuracy(i,:),permute_accuracy(i,:));
            if P == 0
                P = realmin;
            end
            Pvalues(i) = P;
            text(.1,max([ max(acc_elements); max(perm_elements) ])*1.2/1.05,strcat('t(',num2str(STATS.df),')=',num2str(STATS.tstat),', {\it p}','=',num2str(P),', lowerCI=',num2str(CI(1)),', upperCI=',num2str(CI(2))),'FontName','Arial','FontSize',14);
        end
        saveas(h,strcat(output_directory,'/group', num2str(i-1),'_accuracy.tif'));
        hold
    end
    nfigures = i;
    if isnan(permute_accuracy) == 0
        try
            BOMDPlot('InputData',accuracy,'InputData',permute_accuracy,'OutputDirectory',strcat(output_directory,'/model_performance_summary.tif'),'PlotTitle',PlotTitle,'PValues',Pvalues,'BetweenHorz',0.2,'LegendFont',24,'TitleFont',28,'AxisFont',24,'ThinLineWidth',6,'ThickLineWidth',12);
        catch
            warning('Could not produce summary plot, skipping');
        end
    else
        try
            BOMDPlot('InputData',accuracy,'OutputDirectory',strcat(output_directory,'/model_performance_summary.tif'),'PlotTitle',PlotTitle,'PValues',Pvalues,'BetweenHorz',0.2,'LegendFont',24,'TitleFont',28,'AxisFont',24,'ThinLineWidth',6,'ThickLineWidth',12);
        catch
            warning('Could not produce summary plot, skipping');
        end
    end    
    nfigures = nfigures + 1;
    case('regression')
%plot observed and permuted regression results and print ttest results on figure itself
%plot mean error first
        try
            final_outcomes = stuff.final_outcomes;
        catch
            warning('final outcomes values are not found. community detection will operate on entire matrix');
            final_outcomes = NaN;
        end
        nbins = round(size(accuracy,2)/20);
        if nbins < 10
            nbins = 10;
        end
        h = figure(1);
        acc_elements = hist(accuracy(1,:),nbins);
        hist(accuracy(1,:),nbins);
        hold
        if isnan(permute_accuracy) == 0
            perm_elements = hist(permute_accuracy(1,:),nbins);
            hist(permute_accuracy(1,:),nbins);
        end
        limits = xlim;
        acc_h = findobj(gca,'Type','patch');
        if isnan(permute_accuracy) == 0
            permute_h = acc_h(1);
            acc_h = acc_h(2);
            set(permute_h,'FaceColor',[1 0 0],'EdgeColor','k','FaceAlpha',0.5);
        end
        set(acc_h,'FaceColor',[0 0 1],'EdgeColor','k');
        xlabel('mean error','FontSize',20,'FontName','Arial','FontWeight','Bold');
        ylabel('frequency','FontSize',20,'FontName','Arial','FontWeight','Bold');
        title('observed and permuted mean error distributions across both groups','FontSize',24,'FontName','Arial','FontWeight','Bold');
        if isnan(permute_accuracy) == 0
            ylim([0 (max([ max(acc_elements); max(perm_elements) ])*1.2)]);
        else
            ylim([0 max(acc_elements)*1.2]);
        end
        set(gca,'FontName','Arial','FontSize',18,'PlotBoxAspectRatio',[1.5 1.2 1.5]);
        if isnan(permute_accuracy) == 0
            legend('mean error','permuted mean error');
        else
            legend('mean error');
        end
        set(gcf,'Position',[0 0 1024 768],'PaperUnits','points','PaperPosition',[0 0 1024 768]);
        if isnan(permute_accuracy) == 0
            [~, P, CI, STATS] = ttest2(accuracy(1,:),permute_accuracy(1,:));
            if P == 0
                P = realmin;
            end
            Pvalues(1) = P;
            text(limits(2)/10,max([ max(acc_elements); max(perm_elements) ])/1.05,strcat('t(',num2str(STATS.df),')=',num2str(STATS.tstat),', {\it p}','=',num2str(P),', lowerCI=',num2str(CI(1)),', upperCI=',num2str(CI(2))),'FontName','Arial','FontSize',14);
        end
        saveas(h,strcat(output_directory,'/mean_error.tif'));    
        hold
%plot correlations second
        h = figure(2);
        acc_elements = hist(accuracy(2,:),nbins);
        hist(accuracy(2,:),nbins);
        hold
        if isnan(permute_accuracy) == 0
            perm_elements = hist(permute_accuracy(2,:),nbins);
            hist(permute_accuracy(2,:),nbins);
        end
        limits = xlim;
        acc_h = findobj(gca,'Type','patch');
        if isnan(permute_accuracy) == 0
            permute_h = acc_h(1);
            acc_h = acc_h(2);
            set(permute_h,'FaceColor',[1 0 0],'EdgeColor','k','FaceAlpha',0.5);
        end
        set(acc_h,'FaceColor',[0 0 1],'EdgeColor','k');
        xlabel('correlation','FontSize',20,'FontName','Arial','FontWeight','Bold');
        ylabel('frequency','FontSize',20,'FontName','Arial','FontWeight','Bold');
        title('observed and permuted correlation distributions across both groups','FontSize',24,'FontName','Arial','FontWeight','Bold');
        if isnan(permute_accuracy) == 0
            ylim([0 (max([ max(acc_elements); max(perm_elements) ])*1.2)]);
        else
            ylim([0 max(acc_elements)*1.2]);
        end
        set(gca,'FontName','Arial','FontSize',18,'PlotBoxAspectRatio',[1.5 1.2 1.5]);
        if isnan(permute_accuracy) == 0
            legend('correlation','permuted correlation');
        else
            legend('correlation');
        end
        set(gcf,'Position',[0 0 1024 768],'PaperUnits','points','PaperPosition',[0 0 1024 768]);
        if isnan(permute_accuracy) == 0
            [~, P, CI, STATS] = ttest2(accuracy(2,:),permute_accuracy(2,:));
            if P == 0
                P = realmin;
            end
            Pvalues(2) = P;
            text(limits(2)/10,max([ max(acc_elements); max(perm_elements) ])/1.05,strcat('t(',num2str(STATS.df),')=',num2str(STATS.tstat),', {\it p}','=',num2str(P),', lowerCI=',num2str(CI(1)),', upperCI=',num2str(CI(2))),'FontName','Arial','FontSize',14);
        end
        saveas(h,strcat(output_directory,'/correlation.tif'));
        hold
%plot intra-class correlation coefficient (ICC) third
        h = figure(3);
        acc_elements = hist(accuracy(3,:),nbins);
        hist(accuracy(3,:),nbins);
        hold
        if isnan(permute_accuracy) == 0
            perm_elements = hist(permute_accuracy(3,:),nbins);
            hist(permute_accuracy(3,:),nbins);
        end
        limits = xlim;
        acc_h = findobj(gca,'Type','patch');
        if isnan(permute_accuracy) == 0
            permute_h = acc_h(1);
            acc_h = acc_h(2);
            set(permute_h,'FaceColor',[1 0 0],'EdgeColor','k','FaceAlpha',0.5);
        end
        set(acc_h,'FaceColor',[0 0 1],'EdgeColor','k');
        xlabel('intra-class correlation coefficient (ICC)','FontSize',20,'FontName','Arial','FontWeight','Bold');
        ylabel('frequency','FontSize',20,'FontName','Arial','FontWeight','Bold');
        title('observed and permuted ICC distributions across both groups','FontSize',24,'FontName','Arial','FontWeight','Bold');
        if isnan(permute_accuracy) == 0
            ylim([0 (max([ max(acc_elements); max(perm_elements) ])*1.2)]);
        else
            ylim([0 max(acc_elements)*1.2]);
        end
        set(gca,'FontName','Arial','FontSize',18,'PlotBoxAspectRatio',[1.5 1.2 1.5]);
        if isnan(permute_accuracy) == 0
            legend('ICC','permuted ICC');
        else
            legend('ICC');
        end
        set(gcf,'Position',[0 0 1024 768],'PaperUnits','points','PaperPosition',[0 0 1024 768]);
        if isnan(permute_accuracy) == 0
            [~, P, CI, STATS] = ttest2(accuracy(3,:),permute_accuracy(3,:));
            if P == 0
                P = realmin;
            end
            Pvalues(3) = P;
            text(limits(2)/10,max([ max(acc_elements); max(perm_elements) ])/1.05,strcat('t(',num2str(STATS.df),')=',num2str(STATS.tstat),', {\it p}','=',num2str(P),', lowerCI=',num2str(CI(1)),', upperCI=',num2str(CI(2))),'FontName','Arial','FontSize',14);
        end
        saveas(h,strcat(output_directory,'/ICC.tif'));
        hold
        nfigures = 3;
        if isnan(permute_accuracy) == 0
            try
                BOMDPlot('InputData',accuracy,'InputData',permute_accuracy,'OutputDirectory',strcat(output_directory,'/model_performance_summary.tif'),'PlotTitle',{'MAE','r','ICC'},'PValues',Pvalues,'BetweenHorz',0.2,'LegendFont',24,'TitleFont',28,'AxisFont',24,'ThinLineWidth',6,'ThickLineWidth',12);
            catch
                warning('Could not produce summary plot, skipping')
            end
        else
            try
                BOMDPlot('InputData',accuracy,'OutputDirectory',strcat(output_directory,'/model_performance_summary.tif'),'PlotTitle',{'MAE','r','ICC'},'PValues',Pvalues,'BetweenHorz',0.2,'LegendFont',24,'TitleFont',28,'AxisFont',24,'ThinLineWidth',6,'ThickLineWidth',12);
            catch
                warning('Could not produce summary plot, skipping')
            end
        end
        nfigures = nfigures + 1;
end
%load new colormaps
load('group_colormap.mat');
%generate proximity matrix figure
proxmat_sum = zeros(size(proxmat{1}));
for i = 1:max(size(proxmat))
proxmat_sum = proxmat_sum + proxmat{i};
end
h = figure(1 + nfigures);
imagesc(proxmat_sum./max(size(proxmat)));
colormap(gray)
xlabel('subject #','FontSize',20,'FontName','Arial','FontWeight','Bold');
ylabel('subject #','FontSize',20,'FontName','Arial','FontWeight','Bold');
title('proximity matrix','FontName','Arial','FontSize',24,'FontWeight','Bold');
set(gca,'FontName','Arial','FontSize',18);
set(gcf,'Position',[0 0 1024 768],'PaperUnits','points','PaperPosition',[0 0 1024 768]);
caxis([quantile(quantile(triu(proxmat_sum./max(size(proxmat)),1),0.05),0.05) quantile(quantile(triu(proxmat_sum./max(size(proxmat)),1),0.95),0.95)]);
colorbar
if strcmp(type,'classification')
    if length(proxmat{1}) == length(final_outcomes)/2
        display('unsupervised classification detected, will not calculate modularity on classification')
        modularity_classification = NaN;
        modularity_classification_p = NaN;
        modularity_all_classification = NaN;
        modularity_all_classification_p = NaN;
    else
        modularity_classification = zeros(length(unique(final_outcomes)),ncomps_per_rep);
        modularity_classification_p = modularity_classification;
        col_count = 1;
        for curr_density = lowdensity:stepdensity:highdensity
            [modularity_classification(:,col_count), modularity_classification_p(:,col_count)] = PermuteModularityPerGroup(proxmat,final_outcomes,10000,'EdgeDensity',curr_density);
            col_count = col_count + 1;
        end
        num_outcomes = unique(final_outcomes);
        community_vis = zeros(size(proxmat_sum,1),size(proxmat_sum,2),3);
        color_outcome = 0;
        for curr_outcome = 1:length(num_outcomes)
            color_outcome = color_outcome + 1;
            community_vis(find(final_outcomes == num_outcomes(curr_outcome)),find(final_outcomes == num_outcomes(curr_outcome)),1) = primary_colors(color_outcome,1);
            community_vis(find(final_outcomes == num_outcomes(curr_outcome)),find(final_outcomes == num_outcomes(curr_outcome)),2) = primary_colors(color_outcome,2);
            community_vis(find(final_outcomes == num_outcomes(curr_outcome)),find(final_outcomes == num_outcomes(curr_outcome)),3) = primary_colors(color_outcome,3);
            if curr_outcome == size(primary_colors,1)
                color_outcome = 0;
            end
        end
        hold on
        h = imshow(community_vis);
        hold off
        set(h,'AlphaData',0.3);
    end
else
    modularity_classification = NaN;
    modularity_classification_p = NaN;
end
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
ColorData = all_colors;
    [community_matrix, sorting_order] = RunAndVisualizeCommunityDetection(proxmat,output_directory,command_file,nreps,'LowDensity',lowdensity,'StepDensity',stepdensity,'HighDensity',highdensity,'InfomapFile',infomapfile);
    %reproduce sorted matrix
    modularity_communities = zeros(length(unique(community_matrix)),ncomps_per_rep);
    modularity_communities_p = modularity_communities;
    col_count = 1;
    for curr_density = lowdensity:stepdensity:highdensity
        [modularity_communities(:,col_count), modularity_communities_p(:,col_count)] = PermuteModularityPerGroup(proxmat,community_matrix,10000,'EdgeDensity',curr_density);
        col_count = col_count + 1;
    end
    proxmat_sum_sorted = proxmat_sum(sorting_order,sorting_order);
    h = figure(3 + nfigures);
    imagesc(proxmat_sum_sorted./max(size(proxmat)));
    colormap(gray)
    xlabel('subject #','FontSize',20,'FontName','Arial','FontWeight','Bold');
    ylabel('subject #','FontSize',20,'FontName','Arial','FontWeight','Bold');
    title('proximity matrix','FontName','Arial','FontSize',24,'FontWeight','Bold');
    set(gca,'FontName','Arial','FontSize',18);
    set(gcf,'Position',[0 0 1024 768],'PaperUnits','points','PaperPosition',[0 0 1024 768]);
    caxis([quantile(quantile(triu(proxmat_sum./max(size(proxmat)),1),0.05),0.05) quantile(quantile(triu(proxmat_sum./max(size(proxmat)),1),0.95),0.95)]);
    colorbar
    community_vis = zeros(size(proxmat_sum,1),size(proxmat_sum,2),3);
    num_subgroups = unique(community_matrix);
    community_initial_sorted = community_matrix(sorting_order);
    color_outcome = 0;
    for curr_outcome = 1:length(num_subgroups)
        color_outcome = color_outcome + 1;
        community_vis(find(community_initial_sorted == num_subgroups(curr_outcome)),find(community_initial_sorted == num_subgroups(curr_outcome)),1) = ColorData(color_outcome,1);
        community_vis(find(community_initial_sorted == num_subgroups(curr_outcome)),find(community_initial_sorted == num_subgroups(curr_outcome)),2) = ColorData(color_outcome,2);
        community_vis(find(community_initial_sorted == num_subgroups(curr_outcome)),find(community_initial_sorted == num_subgroups(curr_outcome)),3) = ColorData(color_outcome,3);
        if color_outcome == curr_outcome
            color_outcome = 0;
        end
    end
    hold on
    h = imshow(community_vis);
    hold off
    set(h,'AlphaData',0.3);
    saveas(h,strcat(output_directory,'/proximity_matrix_sorted.tif'));
    %visualize community matrix
    h = figure(4 + nfigures);
    imagesc(community_matrix);
    colormap(ColorData)
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
    colormap(ColorData)
    caxis([min(min(community_matrix_sorted)) max(max(community_matrix_sorted))]);
    xlabel('edge density (%)','FontSize',20,'FontName','Arial','FontWeight','Bold');
    ylabel('subject #','FontSize',20,'FontName','Arial','FontWeight','Bold');
    title('subgroups identified by random forests','FontName','Arial','FontSize',24,'FontWeight','Bold');
    set(gca,'FontName','Arial','FontSize',18);
    set(gcf,'Position',[0 0 1024 768],'PaperUnits','points','PaperPosition',[0 0 1024 768]);
    saveas(h,strcat(output_directory,'/community_matrix_sorted.tif'));
    %visualize use of features
    feature_matrix=GenerateSubgroupFeatureMatrix(community_matrix,group1_data,group2_data);
    h=figure(6 + nfigures);
    errorbar(repmat(1:size(feature_matrix,1),size(feature_matrix,2),1).',feature_matrix(:,:,2),feature_matrix(:,:,2) - feature_matrix(:,:,1),feature_matrix(:,:,3) - feature_matrix(:,:,2))
    xlabel('feature #','FontSize',20,'FontName','Arial','FontWeight','Bold');
    ylabel('percentile of feature','FontSize',20,'FontName','Arial','FontWeight','Bold');
    set(gca,'FontName','Arial','FontSize',18);
    set(gcf,'Position',[0 0 1024 768],'PaperUnits','points','PaperPosition',[0 0 1024 768]);
    legend('toggle','Location','Best')
    title('normalized feature percentiles by subgroup','FontSize',24,'FontName','Arial','FontWeight','Bold');
    saveas(h,strcat(output_directory,'/features_by_subgroup_plot.tif'));
%generate community performance metric and visualization
    community_labels = unique(community_matrix);
    ncommunities = length(community_labels);
    community_performance = cell(ncommunities,1);
    for iter = 1:ncommunities
        community_performance{iter} = allclass(community_matrix == community_labels(iter))';
        PlotTitle_comm{iter} = strcat('subgroup',num2str(iter));
        Pvalues_comm(iter) = mean(community_performance{iter});
    end
    save(strcat(output_directory,'/community_assignments.mat'),'modularity_classification','modularity_communities','modularity_classification_p','modularity_communities_p','community_matrix','community_matrix_sorted','sorting_order','community_performance');    
    try
        BOMDPlot('InputData',community_performance,'OutputDirectory',strcat(output_directory,'/model_performance_by_community.tif'),'PlotTitle',PlotTitle_comm,'PValues',Pvalues_comm,'BetweenHorz',0.2,'LegendFont',24,'TitleFont',28,'AxisFont',24,'ThinLineWidth',6,'ThickLineWidth',12);
    catch
        warning('Could not produce community summary plot, skipping');
    end
%if the outcome measure is in the output file AND supervised classification was selected, subgroup detection will also be performed on the initial groups
%this can help identify subgroups that may be hidden by the overarching
%group distinctions
if outcomes_recorded == 1
    if (length(proxmat_sum) == length(final_outcomes))
    subgroup_community_assignments = cell(length(proxmat_sum),1);
    subgroup_community_num = zeros(length(proxmat_sum),2);
    subgroups = unique(final_outcomes);
    nsubgroups = length(subgroups);
    proxmat_subgroups = cell(nsubgroups,1);
    subgroup_index = cell(nsubgroups,1);
    subgroup_communities = cell(nsubgroups,1);
    modularity_subgroup_communities = cell(nsubgroups,1);
    modularity_subgroup_communities_p = cell(nsubgroups,1);
    subgroup_sorting_orders = cell(nsubgroups,1);
    sub_index = 1;
    for iter = 1:nsubgroups
        subgroup_index(iter) = {find(final_outcomes == subgroups(iter))};
        subgroup_community_num(sub_index:length(subgroup_index{iter})+sub_index-1,1) = iter;
        proxmat_subgroups(iter) = {proxmat_sum(subgroup_index{iter},subgroup_index{iter})};
        [community_matrix_temp, sorting_order_temp] = RunAndVisualizeCommunityDetection(proxmat_subgroups(iter),strcat(output_directory,'group_',num2str(iter)),command_file,nreps,'LowDensity',lowdensity,'StepDensity',stepdensity,'HighDensity',highdensity,'InfomapFile',infomapfile);
        modularity_subgroup_temp = zeros(length(unique(community_matrix_temp)),ncomps_per_rep);
        modularity_subgroup_temp_p = modularity_subgroup_temp;
        col_count = 1;
        for curr_density = lowdensity:stepdensity:highdensity
            [modularity_subgroup_temp(:,col_count), modularity_subgroup_temp_p(:,col_count)] = PermuteModularityPerGroup(proxmat_subgroups(iter),community_matrix_temp,10000,'EdgeDensity',curr_density);
            col_count = col_count + 1;
        end
        subgroup_community_assignments(sub_index:length(subgroup_index{iter})+sub_index-1,1) = cellstr( [repmat(strcat('G',num2str(iter),'_'),length(community_matrix_temp),1),num2str(community_matrix_temp(sorting_order_temp))]);        
        subgroup_community_num(sub_index:length(subgroup_index{iter})+sub_index-1,2) = community_matrix_temp(sorting_order_temp);    
        subgroup_communities{iter} = community_matrix_temp;
        modularity_subgroup_communities{iter} = modularity_subgroup_temp;
        modularity_subgroup_communities_p{iter} = modularity_subgroup_temp_p;
        subgroup_sorting_orders{iter} = sorting_order_temp;
        sub_index = sub_index + length(subgroup_index{iter});
    end
    proxmat_subgroup_sorted = proxmat_sum;
    curr_row = 1;
    for row_group = 1:nsubgroups
        row_index = subgroup_index{row_group};
        last_row = length(row_index) + curr_row - 1;
        curr_col = 1;
        for col_group = 1:nsubgroups
            col_index = subgroup_index{col_group};
            last_col = length(col_index) + curr_col - 1;
            proxmat_subgroup_sorted(curr_row:last_row,curr_col:last_col) = proxmat_sum(row_index(subgroup_sorting_orders{row_group}),col_index(subgroup_sorting_orders{col_group}));
            curr_col = last_col + 1;
        end
        curr_row = last_row + 1;
    end
%visualize subgroup sorted proximity matrix
    h = figure(7 + nfigures);
    imagesc(proxmat_subgroup_sorted./max(size(proxmat)));
    colormap(gray)
    xlabel('subject #','FontSize',20,'FontName','Arial','FontWeight','Bold');
    ylabel('subject #','FontSize',20,'FontName','Arial','FontWeight','Bold');
    title('proximity matrix sorted by subgroup','FontName','Arial','FontSize',24,'FontWeight','Bold');
    set(gca,'FontName','Arial','FontSize',18);
    set(gcf,'Position',[0 0 1024 768],'PaperUnits','points','PaperPosition',[0 0 1024 768]);
    caxis([quantile(quantile(triu(proxmat_subgroup_sorted./max(size(proxmat)),1),0.05),0.05) quantile(quantile(triu(proxmat_subgroup_sorted./max(size(proxmat)),1),0.95),0.95)]);
    colorbar
    community_vis = zeros(size(proxmat_subgroup_sorted,1),size(proxmat_subgroup_sorted,2),3);
    num_maingroups = unique(subgroup_community_num(:,1));
    color_maingroup = 0;
    for curr_maingroup = 1:length(num_maingroups)
        color_maingroup = color_maingroup + 1;
        color_outcome = (color_maingroup-1)*6;
        subgroup_comm = find(subgroup_community_num(:,1) == curr_maingroup);
        num_subgroups = unique(subgroup_community_num(subgroup_comm,2));
        for curr_outcome = 1:length(num_subgroups)
            color_outcome = color_outcome + 1;
            community_vis(intersect(subgroup_comm,find(subgroup_community_num(:,2) == num_subgroups(curr_outcome))),intersect(subgroup_comm,find(subgroup_community_num(:,2) == num_subgroups(curr_outcome))),1) = ColorData(color_outcome,1);
            community_vis(intersect(subgroup_comm,find(subgroup_community_num(:,2) == num_subgroups(curr_outcome))),intersect(subgroup_comm,find(subgroup_community_num(:,2) == num_subgroups(curr_outcome))),2) = ColorData(color_outcome,2);
            community_vis(intersect(subgroup_comm,find(subgroup_community_num(:,2) == num_subgroups(curr_outcome))),intersect(subgroup_comm,find(subgroup_community_num(:,2) == num_subgroups(curr_outcome))),3) = ColorData(color_outcome,3);
            if color_outcome > (color_maingroup-1)*6 + 5
                color_outcome = (color_maingroup-1)*6;
            end
        end
        if curr_maingroup > 4
            color_maingroup = 0;
        end
    end
    hold on
    h = imshow(community_vis);
    hold off
    set(h,'AlphaData',0.3);
    saveas(h,strcat(output_directory,'/proximity_matrix_sorted_by_subgroup.tif'));
%visualize sorted commmunity matrix
    h = figure(8 + nfigures);
    imagesc(subgroup_community_num);
    colormap(ColorData)
    caxis([min(min(subgroup_community_num)) max(max(subgroup_community_num))]);
    xlabel('group type','FontSize',20,'FontName','Arial','FontWeight','Bold');
    ylabel('subject #','FontSize',20,'FontName','Arial','FontWeight','Bold');
    title('subgroups identified by random forests','FontName','Arial','FontSize',24,'FontWeight','Bold');
    set(gca,'FontName','Arial','FontSize',18);
    set(gcf,'Position',[0 0 1024 768],'PaperUnits','points','PaperPosition',[0 0 1024 768]);
    saveas(h,strcat(output_directory,'/community_matrix_sorted_by_subgroup.tif'));
%check the status of subgroup performance variables, check against existing
%subgroups and generate performance visualizations by subgroup    
%save subgroup analysis
    community_subgroup_performance = cell(nsubgroups,1);
    subplot_count = 0;    
    for iter = 1:nsubgroups
        subgroup_index = find(subgroup_community_num(:,1) == iter);
        community_labels_subgroups{iter} = unique(subgroup_community_num(subgroup_index,2));
        ncommunities_subgroups{iter} = length(community_labels_subgroups{iter});
        community_subgroup_performance{iter} = cell(ncommunities,1);
        for iter_comm = 1:ncommunities_subgroups{iter}
            subplot_count = subplot_count + 1;
            temp_comms = community_labels_subgroups{iter}(iter_comm);
            community_subgroup_performance_temp{iter_comm} = allclass(subgroup_community_num(subgroup_index,2) == temp_comms)';
            PlotTitle_comm{subplot_count} = strcat('subgroup','_G',num2str(iter),'_S',num2str(iter_comm));
            Pvalues_comm(subplot_count) = mean(community_subgroup_performance_temp{iter_comm});
        end
        community_subgroup_performance{iter} = {community_subgroup_performance_temp};
        clear community_subgroup_performance_temp
    end
    if length(Pvalues_comm) > 6
        try
            BOMDPlot('InputData',community_subgroup_performance,'OutputDirectory',strcat(output_directory,'/model_performance_by_community.tif'),'PlotTitle',PlotTitle_comm,'PValues',Pvalues_comm,'BetweenHorz',0.2,'LegendFont',12,'TitleFont',14,'AxisFont',12,'ThinLineWidth',3,'ThickLineWidth',6);
        catch
            warning('Could not produce summary community plot, skipping')
        end
    else
        try
            BOMDPlot('InputData',community_subgroup_performance,'OutputDirectory',strcat(output_directory,'/model_performance_by_community.tif'),'PlotTitle',PlotTitle_comm,'PValues',Pvalues_comm,'BetweenHorz',0.2,'LegendFont',24,'TitleFont',28,'AxisFont',24,'ThinLineWidth',6,'ThickLineWidth',12);  
        catch
            warning('Could not produce summary community plot, skipping');
        end
    end
    save(strcat(output_directory,'/subgroup_community_assignments.mat'),'modularity_subgroup_communities','modularity_subgroup_communities_p','proxmat_subgroup_sorted','subgroup_community_num','subgroup_sorting_orders','subgroup_communities','subgroup_community_assignments','community_subgroup_performance','-v7.3');
    end
end
%check the status of out of bag variables, generate visualizations if they
%indeed exist.
if isnan(oob_varimp(1)) == 0
    try
        h = figure(nfigures + 10);
        bar(outofbag_varimp)
        xlabel('input variable #','FontSize',20,'FontName','Arial','FontWeight','Bold');
        ylabel('variable importance','FontSize',20,'FontName','Arial','FontWeight','Bold');
        title('variable importance plot','FontName','Arial','FontSize',24,'FontWeight','Bold');
        set(gca,'FontName','Arial','FontSize',18);
        saveas(h,strcat(output_directory,'/variable_importance.tif'));    
    catch
        warning('could not produce OOB variable importance plot despite presence of real variable...skipping');
    end
end
if isnan(oob_error(1)) == 0
    try
        h = figure(nfigures + 11);
        plot(outofbag_error,'LineWidth',3)
        xlabel('# of trees','FontSize',20,'FontName','Arial','FontWeight','Bold');
        ylabel('OOB error (%)','FontSize',20,'FontName','Arial','FontWeight','Bold');
        title('out of bag error by # of trees','FontName','Arial','FontSize',24,'FontWeight','Bold');
        set(gca,'FontName','Arial','FontSize',18);
        saveas(h,strcat(output_directory,'/OOB_error.tif'));     
    catch
        warning('could not produce OOB error plot despite presence of real variable...skipping');
    end
end


close all
end


