function RF_EDA(final_outcomes,predicted_outcomes,accuracy,permute_accuracy,regressionflag,output_directory)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
switch(regressionflag)
    case('Regression')
        figure(1)
        comparison_graph=gramm('x',final_outcomes,'y',predicted_outcomes);
        comparison_graph.stat_bin2d('nbins',[40 40],'geom','image');
        comparison_graph.set_names('x','observed outcomes','y','predicted outcomes','color','count');
        comparison_graph.set_title('Observed vs predicted performance');
        comparison_graph.set_text_options('font','Courier',...
            'base_size',14,...
            'label_scaling',1,...
            'legend_scaling',1.5,...
            'legend_title_scaling',1.5,...
            'facet_scaling',1,...
            'title_scaling',1.3);
        comparison_graph.draw();
        line(0:1,0:1,'LineWidth',2,'Color','Black','Parent',comparison_graph.facet_axes_handles(1))
        comparison_graph.export('file_name',strcat(output_directory,'/RF_performance_scatterplot'));
        if (isnan(permute_accuracy))
            figure(2)
               accuracy_long = reshape(accuracy,[],1);
               metric_type=repmat({'MAE';'R';'ICC'},length(accuracy_long)/3,1);
               accuracy_graph=gramm('x',metric_type,'y',accuracy_long,'color',metric_type);
               accuracy_graph.stat_summary('geom',{'bar'},'dodge',0.7,'width',0.7);
               accuracy_graph.set_names('x','metric','y','value','color','metric');
               accuracy_graph.set_title('RF performance');
               accuracy_graph.set_text_options('font','Courier',...
                    'base_size',14,...
                    'label_scaling',1,...
                    'legend_scaling',1.5,...
                    'legend_title_scaling',1.5,...
                    'facet_scaling',1,...
                    'title_scaling',1.3);
               accuracy_graph.draw();
               accuracy_graph.geom_vline('xintercept',0.5:1:10.5,'style','k-');
               accuracy_graph.export('file_name',strcat(output_directory,'/RF_performance_bar'));            
        else
            figure(2)
               accuracy_long = reshape(accuracy,[],1);
               permute_accuracy_long = reshape(permute_accuracy,[],1);
               combined_accuracy = [ accuracy_long ; permute_accuracy_long ];
               permute_status = cell(size(combined_accuracy,1),1);
               permute_status(1:length(accuracy_long),1) = {'observed'};
               permute_status(length(accuracy_long)+1:end,1) = {'permuted'};
               metric_type=repmat({'MAE';'R';'ICC'},length(combined_accuracy)/3,1);               
               accuracy_graph=gramm('x',metric_type,'y',combined_accuracy','color',permute_status);
               accuracy_graph.stat_summary('geom',{'bar'},'dodge',0.7,'width',0.7);
               accuracy_graph.set_names('x','metric','y','value','color','metric');
               accuracy_graph.set_title('RF performance');
               accuracy_graph.set_text_options('font','Courier',...
                    'base_size',14,...
                    'label_scaling',1,...
                    'legend_scaling',1.5,...
                    'legend_title_scaling',1.5,...
                    'facet_scaling',1,...
                    'title_scaling',1.3);
               accuracy_graph.draw();
               accuracy_graph.geom_vline('xintercept',0.5:1:10.5,'style','k-');
               accuracy_graph.export('file_name',strcat(output_directory,'/RF_performance_bar'));     
        end
    case('Classification')
               metric_list = cell(size(accuracy,1),1);
               metric_list(1) = {'total'};
               ncomps = length(metric_list);
               for iter=2:ncomps
                    metric_list(iter) = {strcat('Group',num2str(iter-1))};
               end
        if (isnan(permute_accuracy))
            figure(1)
               accuracy_long = reshape(accuracy,[],1);               
               metric_type=repmat(metric_list,length(accuracy_long)/ncomps,1);
               accuracy_graph=gramm('x',metric_type,'y',accuracy_long,'color',metric_type);
               accuracy_graph.stat_summary('geom',{'bar'},'dodge',0.7,'width',0.7);
               accuracy_graph.set_names('x','metric','y','value','color','metric');
               accuracy_graph.set_title('RF performance');
               accuracy_graph.set_text_options('font','Courier',...
                    'base_size',14,...
                    'label_scaling',1,...
                    'legend_scaling',1.5,...
                    'legend_title_scaling',1.5,...
                    'facet_scaling',1,...
                    'title_scaling',1.3);
               accuracy_graph.draw();
               accuracy_graph.geom_vline('xintercept',0.5:1:10.5,'style','k-');
               accuracy_graph.export('file_name',strcat(output_directory,'/RF_performance_bar'));            
        else
            figure(2)
               accuracy_long = reshape(accuracy,[],1);
               permute_accuracy_long = reshape(permute_accuracy,[],1);
               combined_accuracy = [ accuracy_long ; permute_accuracy_long ];
               permute_status = cell(size(combined_accuracy,1),1);
               permute_status(1:length(accuracy_long),1) = {'observed'};
               permute_status(length(accuracy_long)+1:end,1) = {'permuted'};
               metric_type=repmat(metric_list,length(combined_accuracy)/ncomps,1);               
               accuracy_graph=gramm('x',metric_type,'y',combined_accuracy','color',permute_status);
               accuracy_graph.stat_summary('geom',{'bar'},'dodge',0.7,'width',0.7);
               accuracy_graph.set_names('x','metric','y','value','color','metric');
               accuracy_graph.set_title('RF performance');
               accuracy_graph.set_text_options('font','Courier',...
                    'base_size',14,...
                    'label_scaling',1,...
                    'legend_scaling',1.5,...
                    'legend_title_scaling',1.5,...
                    'facet_scaling',1,...
                    'title_scaling',1.3);
               accuracy_graph.draw();
               accuracy_graph.geom_vline('xintercept',0.5:1:10.5,'style','k-');
               accuracy_graph.export('file_name',strcat(output_directory,'/RF_performance_bar'));     
        end        
end
close all
end

