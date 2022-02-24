function VisualizeTreeBaggingResults(matfile,output_directory,type,command_file,varargin)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
nreps = 10;
lowdensity = 0.2;
highdensity = 1;
stepdensity = 0.05;
use_search_params = 0;
grammpath='/home/faird/shared/code/external/utilities/gramm/';
showmpath='/home/faird/shared/code/internal/utilities/plotting-tools/showM/';
bctpath='/home/faird/shared/code/external/utilities/BCT/BCT/2019_03_03_BCT';
junkthreshold = 5;
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
                case('GridSearchDir')
                    gridsearchdir = varargin{i+1};
                    use_search_params = 1;
                case('GrammPath')
                    grammpath = varargin{i+1};
                case('ShowMPath')
                    showmpath = varargin{i+1};
                case('JunkThreshold')
                    junkthreshold = varargin{i+1};
                case('BCTPath')
                    bctpath=varargin{i+1};
                case('ConnectednessThreshold')
                    connectedness_thresh = varargin{i+1};
            end
        end
    end
end
if ~isdeployed
    addpath(genpath(grammpath))
    addpath(genpath(showmpath))
    addpath(genpath(bctpath))
end
ncomps_per_rep = length(lowdensity:stepdensity:highdensity);
stuff = load(matfile);
accuracy = stuff.accuracy;
permute_accuracy = stuff.permute_accuracy;
proxmat = stuff.proxmat;
features = stuff.features;
final_data = stuff.final_data;
final_outcomes = stuff.final_outcomes;
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
                if (length(final_outcomes) ~= length(group2predict))
                    RF_EDA(final_outcomes,[group1predict;group2predict],accuracy,permute_accuracy,'Classification',output_directory);
                    FRFAUC = ComputeROCfromFRF(group1predict,group2predict,group1scores,group2scores,final_outcomes,strcat(output_directory,'/summary'));
                    outcome_performance = final_outcomes - [group1predict;group2predict];
                else
                    RF_EDA(final_outcomes,group2predict,accuracy,permute_accuracy,'Classification',output_directory);
                    FRFAUC = ComputeROCfromFRF(group2predict,[],group2scores,[],final_outcomes,strcat(output_directory,'/summary'));
                    outcome_performance = final_outcomes - group2predict;
                end
                save(strcat(output_directory,'/AUC.mat'),'FRFAUC','-v7.3');
            catch
                warning('could not generate ROC curves -- skipping');
                outcome_performance = NaN;
            end
        end
    case('regression')
        try
            final_outcomes = stuff.final_outcomes;
        catch
            warning('final outcomes values are not found. community detection will operate on entire matrix');
            final_outcomes = NaN;
        end
        try
            group1predict = stuff.group1predict;
            group2predict = stuff.group2predict;
            if (length(final_outcomes) > length(group2predict))
                RF_EDA(final_outcomes,[group1predict;group2predict],accuracy,permute_accuracy,'Regression',output_directory);
                outcome_performance = final_outcomes - [group1predict;group2predict];            
            else
                RF_EDA(final_outcomes,group2predict,accuracy,permute_accuracy,'Regression',output_directory);
                outcome_performance = final_outcomes - group2predict;
            end
        catch
            warning('could not load group predictions for making performance plots, skipping...');
        outcome_performance = NaN;
        end
end

%load new colormaps
load('group_colormap.mat');
%generate proximity matrix figure
proxmat_sum = zeros(size(proxmat{1}));
for i = 1:max(size(proxmat))
proxmat_sum = proxmat_sum + proxmat{i};
end
h = figure();
proxmat_sum = proxmat_sum./max(size(proxmat));
imagesc(proxmat_sum);
colormap(gray)
xlabel('subject #','FontSize',20,'FontName','Arial','FontWeight','Bold');
ylabel('subject #','FontSize',20,'FontName','Arial','FontWeight','Bold');
title('proximity matrix','FontName','Arial','FontSize',24,'FontWeight','Bold');
set(gca,'FontName','Arial','FontSize',18);
set(gcf,'Position',[0 0 1024 768],'PaperUnits','points','PaperPosition',[0 0 1024 768]);
caxis([quantile(quantile(triu(proxmat_sum,1),0.05),0.05) quantile(quantile(triu(proxmat_sum,1),0.95),0.95)]);
colorbar
saveas(h,strcat(output_directory,'/proximity_matrix.tif'));
close all
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
        proxclass_outdir = strcat(output_directory,'/proximity_by_class/');
        mkdir(proxclass_outdir);
        See_communities(proxmat_sum,final_outcomes,final_data,outcome_performance,[],proxclass_outdir,junkthreshold,all_colors,0.3,[],[]);
    end
else
    modularity_classification = NaN;
    modularity_classification_p = NaN;
end
%plot features used
h = figure()
bar(features)
xlabel('feature #','FontSize',20,'FontName','Arial','FontWeight','Bold');
ylabel('# times used','FontSize',20,'FontName','Arial','FontWeight','Bold');
title('frequency of features used across all random forests','FontName','Arial','FontSize',24,'FontWeight','Bold');
set(gca,'FontName','Arial','FontSize',18);
set(gcf,'Position',[0 0 1024 768],'PaperUnits','points','PaperPosition',[0 0 1024 768]);
saveas(h,strcat(output_directory,'/feature_usage.tif'));
close all
%incorporating newer community detection here:
ColorData = all_colors;
    if use_search_params
        [community_matrix, sorting_order,commproxmat,unsorted_community,reverse_sorting_order,lowdensity,stepdensity,highdensity] = RunAndVisualizeCommunityDetection(proxmat,output_directory,command_file,nreps,'LowDensity',lowdensity,'StepDensity',stepdensity,'HighDensity',highdensity,'InfomapFile',infomapfile,'GridSearchDir',gridsearchdir,'BCTPath',bctpath,'ConnectednessThreshold',connectedness_thresh);
    else
        [community_matrix, sorting_order,commproxmat,unsorted_community,reverse_sorting_order,lowdensity,stepdensity,highdensity] = RunAndVisualizeCommunityDetection(proxmat,output_directory,command_file,nreps,'LowDensity',lowdensity,'StepDensity',stepdensity,'HighDensity',highdensity,'InfomapFile',infomapfile,'BCTPath',bctpath,'ConnectednessThreshold',connectedness_thresh);
    end
    %reproduce sorted matrix
    count = 0;
    community_vector = unique(community_matrix);
    for iter = 1:length(community_vector)
        if length(find(community_matrix == community_vector(iter))) > junkthreshold
            count = count + 1;
        end
    end
    modularity_communities = zeros(count,ncomps_per_rep);
    modularity_communities_p = modularity_communities;
    col_count = 1;
    for curr_density = lowdensity:stepdensity:highdensity
        [modularity_communities(:,col_count), modularity_communities_p(:,col_count)] = PermuteModularityPerGroup(proxmat,community_matrix,1000,'EdgeDensity',curr_density,'JunkThreshold',junkthreshold);
        col_count = col_count + 1;
    end
    proxsub_outdir = strcat(output_directory,'/proximity_by_subgroup/');
    mkdir(proxsub_outdir)
    See_communities(commproxmat,unsorted_community,final_data,outcome_performance,[],proxsub_outdir,junkthreshold,all_colors,1,[],1);
    save(strcat(output_directory,'/community_outputs.mat'),'modularity_communities','modularity_communities_p',...
        'community_matrix','sorting_order','commproxmat',...
        'unsorted_community','reverse_sorting_order','lowdensity',...
        'stepdensity','highdensity','modularity_classification_p','modularity_classification','outcome_performance');
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
    h = figure();
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
    h = figure();
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
        figure()
            oob_varimp_long = reshape(oob_varimp',size(oob_varimp,1)*size(oob_varimp,2),1);
            feature_num_long = repmat(1:size(oob_varimp,2),1,size(oob_varimp,1))';
            oob_varimp_graph=gramm('x',feature_num_long,'y',oob_varimp_long);
            oob_varimp_graph.stat_smooth();
            oob_varimp_graph.set_names('x','feature #','y','variable importance');
            oob_varimp_graph.no_legend();
            oob_varimp_graph.set_title('feature importance');
            oob_varimp_graph.set_text_options('font','Courier',...
                'base_size',14,...
                'label_scaling',1,...
                'legend_scaling',1.5,...
                'legend_title_scaling',1.5,...
                'facet_scaling',1,...
                'title_scaling',1.3);
            oob_varimp_graph.draw();
            oob_varimp_graph.export('file_name',strcat(output_directory,'/feature_importance'));
    catch
        warning('could not produce OOB variable importance plot despite presence of real variable...skipping');
    end
end
if isnan(oob_error(1)) == 0
    try
        figure()
            oob_error_long = reshape(oob_error',size(oob_error,1)*size(oob_error,2),1);
            tree_num_long = repmat(1:size(oob_error,2),1,size(oob_error,1))';
            oob_error_graph=gramm('x',tree_num_long,'y',oob_error_long);
            oob_error_graph.stat_smooth();
            oob_error_graph.set_names('x','feature #','y','variable importance');
            oob_error_graph.no_legend();
            oob_error_graph.set_title('feature importance');
            oob_error_graph.set_text_options('font','Courier',...
                'base_size',14,...
                'label_scaling',1,...
                'legend_scaling',1.5,...
                'legend_title_scaling',1.5,...
                'facet_scaling',1,...
                'title_scaling',1.3);
            oob_error_graph.draw();
            oob_error_graph.export('file_name',strcat(output_directory,'/out_of_bag_error')); 
    catch
        warning('could not produce OOB error plot despite presence of real variable...skipping');
    end
end


close all
end


