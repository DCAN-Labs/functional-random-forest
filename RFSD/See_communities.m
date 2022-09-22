function See_communities(similarity_matrix,community,feature_data,performance_data,...
    parcel,output_directory,junk_threshold,community_colormap,edge_density,...
    fconn_options,save_community_outputs)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
if isempty(save_community_outputs)
    save_community_outputs=0;
else
    save_community_outputs=1;
end
if isempty(parcel)
    parcellate_features=0;
else
    parcellate_features=1;
end
if ischar(parcel)
    parcel_info = load(parcel);
    parcelnames = fieldnames(parcel_info);
    parcel_data = getfield(parcel_info,parcelnames{1});
else
    parcel_data = parcel;
end
if ischar(community_colormap)
    community_file=community_colormap;
    clear community_colormap
    community_colormap_info = load(community_file);
    community_colormap_names = fieldnames(community_colormap_info);
    community_colormap = getfield(community_colormap_info,community_colormap_names{1});
end
all_unique_communities = unique(community);
threshold_communities = community;
community_size = zeros(length(all_unique_communities),1);
count_comm = 0;
for iter = 1:length(all_unique_communities)
    community_size(iter) = length(find(community == all_unique_communities(iter,1)));
    if community_size(iter) < junk_threshold
        threshold_communities(community == all_unique_communities(iter,1)) = 0;
    else
        count_comm = count_comm +1;
        community_parcel(count_comm).name=strcat('subtype',num2str(iter));
        community_parcel(count_comm).shortname=strcat('sub',num2str(iter));
        community_parcel(count_comm).ix=find(community == all_unique_communities(iter,1));
        community_parcel(count_comm).n=community_size(iter);
        community_parcel(count_comm).RGB=community_colormap(count_comm+1,:);
    end
end
community_parcel(count_comm+1).name='none';
community_parcel(count_comm+1).shortname='iso';
community_parcel(count_comm+1).ix=find(threshold_communities==0);
community_parcel(count_comm+1).n = length(community_parcel(count_comm+1).ix);
community_parcel(count_comm+1).RGB=community_colormap(1,:);
clear count_comm
threshold_communities_filtered = threshold_communities(threshold_communities > 0);
partial_matrix = similarity_matrix(threshold_communities > 0,threshold_communities >0);
filtered_unique_communities = unique(threshold_communities_filtered);
for iter = 1:length(filtered_unique_communities)
    community_parcel_filtered(iter).name=strcat('subtype',num2str(iter));
    community_parcel_filtered(iter).shortname=strcat('sub',num2str(iter));
    community_parcel_filtered(iter).ix=find(threshold_communities_filtered == filtered_unique_communities(iter,1));
    community_parcel_filtered(iter).n=length(community_parcel_filtered(iter).ix);
    community_parcel_filtered(iter).RGB=community_colormap(iter+1,:);
end
cmax_all = max(max(triu(similarity_matrix,1)));
cmax_partial = max(max(triu(partial_matrix,1)));
all_sorted_figure = showM(similarity_matrix,'parcel',community_parcel,...
    'line_color',[0 0 0],'clims',[-1 cmax_all],'my_color','RB');
saveas(all_sorted_figure,strcat(output_directory,filesep,...
    'similarity_matrix_sorted.svg'));
close all
partial_sorted_figure = showM(partial_matrix,'parcel',...
    community_parcel_filtered,'line_color',[0 0 0],...
    'clims',[-1 cmax_partial],'my_color','RB');
saveas(partial_sorted_figure,strcat(output_directory,filesep,...
    'similarity_matrix_sorted_filtered.svg'));
close all
proxmat_vector = similarity_matrix(abs((triu(similarity_matrix,1))) > 0);
if edge_density < 1
    proxmat_threshold = quantile(proxmat_vector,1-edge_density);
    partial_matrix_thresh = partial_matrix > proxmat_threshold;
else
    partial_matrix_thresh = partial_matrix;
end
%commproxgraph = graph(partial_matrix_thresh,'omitselfloops','upper');
%graph_layout=plot(commproxgraph,'Layout','force','NodeCData',...
%    threshold_communities_filtered+1,'EdgeAlpha',0.8,'EdgeColor',...
%    [.7 .7 .7],'Marker','o');
%colormap(community_colormap)
%caxis([1 length(community_colormap)])
%title('Graph of connected nodes','FontName','courier','FontSize',16,...
%    'FontWeight','bold')
%saveas(graph_layout,strcat(output_directory,filesep,...
%    'community_graph_layout.svg'))
if parcellate_features 
    mkdir(strcat(output_directory,'/polyneuro_subtype_plots_by_network'))
    load(parcel,'parcel')
    total_ROI=0;
    for iter = 1:length(parcel)
        total_ROI = total_ROI + parcel(iter).n;
    end
    parcel_index = zeros(total_ROI,1);
    for iter = 1:length(parcel)
        parcel_index(parcel(iter).ix) = iter;
    end
    parcel_mat=zeros(total_ROI,total_ROI,2);
    for community_a = 1:length(parcel)
        for community_b = community_a:length(parcel)
            ordered_comms = sort([community_a community_b]);
            parcel_mat(parcel(community_a).ix,parcel(community_b).ix,1) = ordered_comms(1);
            parcel_mat(parcel(community_b).ix,parcel(community_a).ix,1) = ordered_comms(1);  
            parcel_mat(parcel(community_a).ix,parcel(community_b).ix,2) = ordered_comms(2);
            parcel_mat(parcel(community_b).ix,parcel(community_a).ix,2) = ordered_comms(2);            
        end
    end
    parcel_array = ReshapeMR(parcel_mat,fconn_options)';
    feature_data_column = reshape(feature_data',size(feature_data,1)*size(feature_data,2),1);
    community_column = repelem(threshold_communities,size(feature_data,2));
    index_column = repmat(1:size(feature_data,2),1,size(feature_data,1))';
    parcel_column=repmat(parcel_array,size(feature_data,1),1);
    close all
    for curr_comm_a = 1:length(parcel)
        for curr_comm_b = curr_comm_a:length(parcel)
            figure()
            parcel_mask = parcel_column == [curr_comm_a curr_comm_b];
            parcel_mask = logical(parcel_mask(:,1).*parcel_mask(:,2));
            index_temp = index_column(parcel_mask);
            index_temp = repmat(1:length(unique(index_temp)),1,size(feature_data,1));
            feature_data_temp = feature_data_column(parcel_mask)';
            community_temp = community_column(parcel_mask)';
            feature_graph=...
                gramm('x',index_temp,...
                'y',feature_data_temp,...
                'color',community_temp);
            feature_graph.stat_summary('geom',{'area'});
            feature_graph.set_names('x','connection','y','connection strength','color','subtype #');
            feature_graph.set_title(strcat(parcel(curr_comm_a).shortname," to ",parcel(curr_comm_b).shortname," connectivity"));
            feature_graph.set_text_options('font','Courier',...
                'base_size',14,...
                'label_scaling',1,...
                'legend_scaling',1.5,...
                'legend_title_scaling',1.5,...
                'facet_scaling',1,...
                'title_scaling',1.3);
            feature_graph.draw();
            feature_graph.export('file_name',strcat(output_directory,'/polyneuro_subtype_plots_by_network/',parcel(curr_comm_a).shortname,'_to_',parcel(curr_comm_b).shortname));
            close all
        end
    end
    figure('position',[100 50 1200 700])
    for curr_comm_a = 1:length(parcel)
        for curr_comm_b = curr_comm_a:length(parcel)
            parcel_mask = parcel_column == [curr_comm_a curr_comm_b];
            parcel_mask = logical(parcel_mask(:,1).*parcel_mask(:,2));
            index_temp = index_column(parcel_mask);
            index_temp = repmat(1:length(unique(index_temp)),1,size(feature_data,1));
            feature_data_temp = feature_data_column(parcel_mask)';
            community_temp = community_column(parcel_mask)';
            feature_graph(curr_comm_a,curr_comm_b)=...
                gramm('x',index_temp,...
                'y',feature_data_temp,...
                'color',community_temp);
            feature_graph(curr_comm_a,curr_comm_b).stat_summary('geom',{'area'});
            feature_graph(curr_comm_a,curr_comm_b).set_names('color','subtype #');
            feature_graph(curr_comm_a,curr_comm_b).set_title(strcat(parcel(curr_comm_a).shortname," to ",parcel(curr_comm_b).shortname));
            feature_graph(curr_comm_a,curr_comm_b).set_text_options('font','Courier',...
                'base_size',4,...
                'label_scaling',1,...
                'legend_scaling',1,...
                'legend_title_scaling',1,...
                'facet_scaling',1,...
                'title_scaling',1);
        end
    end
    feature_graph.draw();
    feature_graph.export('file_name',strcat(output_directory,'/polyneuro_subtype_plots_by_network_grid'));
    close all
else
    figure()
    accuracy_graph_test=gramm('x',threshold_communities+1,'y',performance_data','color',threshold_communities+1);
               accuracy_graph_test.stat_summary('geom',{'bar'},'dodge',0.7,'width',0.7);
               accuracy_graph_test.set_names('x','metric','y','value','color','metric');
               accuracy_graph_test.set_title('subject performance');
               accuracy_graph_test.set_text_options('font','Courier',...
                    'base_size',14,...
                    'label_scaling',1,...
                    'legend_scaling',1.5,...
                    'legend_title_scaling',1.5,...
                    'facet_scaling',1,...
                    'title_scaling',1.3);
               accuracy_graph_test.draw();
               miny = 0;
               maxy = 0;
               for iter = 1:length(accuracy_graph_test.results.stat_summary)
                   if miny > min(min(accuracy_graph_test.results.stat_summary(iter).yci))
                    miny = min(min(accuracy_graph_test.results.stat_summary(iter).yci));
                   end
                   if maxy < max(max(accuracy_graph_test.results.stat_summary(iter).yci))
                    maxy = max(max(accuracy_graph_test.results.stat_summary(iter).yci));
                   end
               end
               close all
               figure()
               accuracy_graph=gramm('x',threshold_communities+1,'y',performance_data','color',threshold_communities+1);
               accuracy_graph.stat_summary('geom',{'bar'},'dodge',0.7,'width',0.7);
               accuracy_graph.set_names('x','metric','y','value','color','metric');
               accuracy_graph.set_title('subject performance');
               accuracy_graph.set_text_options('font','Courier',...
                    'base_size',14,...
                    'label_scaling',1,...
                    'legend_scaling',1.5,...
                    'legend_title_scaling',1.5,...
                    'facet_scaling',1,...
                    'title_scaling',1.3);
               accuracy_graph.axe_property('ylim',[miny maxy]);
               accuracy_graph.draw();
               accuracy_graph.geom_vline('xintercept',0.5:1:10.5,'style','k-');               
               accuracy_graph.export('file_name',strcat(output_directory,'/subgroup_performance_bar'));
   feature_data_pvalue = zeros(size(feature_data,2),1);
   feature_data_zscored = zeros(size(feature_data));
   for iter = 1:size(feature_data,2)
       feature_data_pvalue(iter,1) = anova1(feature_data(:,iter),threshold_communities,'off');
       feature_data_zscored(:,iter) = (feature_data(:,iter) - mean(feature_data(:,iter),'omitnan'))/std(feature_data(:,iter),[],'omitnan');
   end
   feature_data_pvalue = -log10(feature_data_pvalue);
   figure()
    manhattan_graph=gramm('x',1:length(feature_data_pvalue),'y',feature_data_pvalue,'size',feature_data_pvalue);
    manhattan_graph.geom_point();
    manhattan_graph.set_names('x','feature #','y','-log10(p)');
    manhattan_graph.no_legend();
               manhattan_graph.set_title('features varied by community');
               manhattan_graph.set_text_options('font','Courier',...
                    'base_size',14,...
                    'label_scaling',1,...
                    'legend_scaling',1.5,...
                    'legend_title_scaling',1.5,...
                    'facet_scaling',1,...
                    'title_scaling',1.3);
               manhattan_graph.draw();
               manhattan_graph.export('file_name',strcat(output_directory,'/feature_by_subgroup_pvalue'));
      figure()
            feature_data_long = reshape(feature_data_zscored,size(feature_data_zscored,1)*size(feature_data_zscored,2),1);
            feature_num = sort(repmat(1:size(feature_data_zscored,2),1,size(feature_data_zscored,1))');
            community_long = repmat(threshold_communities+1,size(feature_data_zscored,2),1);
            subfeatures_graph_test=gramm('x',feature_num,'y',feature_data_long','color',community_long);
               subfeatures_graph_test.stat_summary('geom',{'bar'},'dodge',0.7,'width',0.7);
               subfeatures_graph_test.set_names('x','feature #','y','value','color','community');
               subfeatures_graph_test.set_title('subgroups by feature');            
               subfeatures_graph_test.set_text_options('font','Courier',...
                    'base_size',14,...
                    'label_scaling',1,...
                    'legend_scaling',1.5,...
                    'legend_title_scaling',1.5,...
                    'facet_scaling',1,...
                    'title_scaling',1.3);
               subfeatures_graph_test.draw();
               miny = 0;
               maxy = 0;
               for iter = 1:length(subfeatures_graph_test.results.stat_summary)
                   if miny > min(min(subfeatures_graph_test.results.stat_summary(iter).yci))
                    miny = min(min(subfeatures_graph_test.results.stat_summary(iter).yci));
                   end
                   if maxy < max(max(subfeatures_graph_test.results.stat_summary(iter).yci))
                    maxy = max(max(subfeatures_graph_test.results.stat_summary(iter).yci));
                   end
               end
           figure()
               subfeatures_graph=gramm('x',feature_num,'y',feature_data_long','color',community_long);
               subfeatures_graph.stat_summary('geom',{'bar'},'dodge',0.7,'width',0.7);
               subfeatures_graph.set_names('x','feature #','y','value','color','community');
               subfeatures_graph.set_title('subgroups by feature');            
               subfeatures_graph.set_text_options('font','Courier',...
                    'base_size',14,...
                    'label_scaling',1,...
                    'legend_scaling',1.5,...
                    'legend_title_scaling',1.5,...
                    'facet_scaling',1,...
                    'title_scaling',1.3);                              
               subfeatures_graph.axe_property('ylim',[miny maxy])
               subfeatures_graph.draw()
               subfeatures_graph.export('file_name',strcat(output_directory,'/features_by_subgroup'));
end
close all
partial_matrix_output = partial_matrix_thresh.*partial_matrix;
subtype_names_partial=cell(length(partial_matrix_output),1);
similarity_matrix_output = similarity_matrix.*(similarity_matrix > proxmat_threshold);
subtype_names = cell(length(similarity_matrix_output),1);
for curr_comm = 1:length(community_parcel)
    subtype_names(community_parcel(curr_comm).ix)={community_parcel(curr_comm).shortname};
end
for curr_comm = 1:length(community_parcel_filtered)
    subtype_names_partial(community_parcel_filtered(curr_comm).ix)={community_parcel_filtered(curr_comm).shortname};
end
if save_community_outputs
    partial_matrix_cell = cell(length(partial_matrix_output)*(length(partial_matrix_output)-1)/2,3);
    subtype_partial_rows = repmat(subtype_names_partial,1,length(subtype_names_partial));
    subtype_partial_cols = repmat(subtype_names_partial',length(subtype_names_partial),1);
    partial_matrix_filter = ones(size(partial_matrix_output));
    partial_matrix_cell(:,3) = num2cell(partial_matrix_output(triu(partial_matrix_filter,1) > 0));
    partial_matrix_cell(:,1) = subtype_partial_rows(triu(partial_matrix_filter,1) > 0);
    partial_matrix_cell(:,2) = subtype_partial_cols(triu(partial_matrix_filter,1) > 0);

    similarity_matrix_cell = cell(length(similarity_matrix_output)*(length(similarity_matrix_output)-1)/2,3);
    subtype_rows = repmat(subtype_names,1,length(subtype_names));
    subtype_cols = repmat(subtype_names',length(subtype_names),1);
    similarity_matrix_filter = ones(size(similarity_matrix_output));
    similarity_matrix_cell(:,3) = num2cell(similarity_matrix_output(triu(similarity_matrix_filter,1) > 0));
    similarity_matrix_cell(:,1) = subtype_rows(triu(similarity_matrix_filter,1) > 0);
    similarity_matrix_cell(:,2) = subtype_cols(triu(similarity_matrix_filter,1) > 0);

    writecell(similarity_matrix_cell,strcat(output_directory,filesep,'similarity_matrix.csv'));
    writecell(partial_matrix_cell,strcat(output_directory,filesep,'partial_similarity_matrix.csv'));
end
