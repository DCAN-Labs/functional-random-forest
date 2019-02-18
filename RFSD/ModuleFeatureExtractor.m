function feature_data = ModuleFeatureExtractor(varargin)
%ModuleFeatureExtractor will extract features from adjacency matrices that
%have reduced dimensionality. Used as a method to perform dimensionality
%reduction on connectivity data, but can also be used for other data types.
%With X ROIs, this approach will reduce the number of features from
%X(X-1)/2 to M + (M(M-1)/2), where M is the number of modules. For example,
%the Gordon parcellation contains 353 ROIs and 17 networks. The number of
%features for the Gordon parcellation are reduced from 62128 to 153.
%
%
%INPUTS
%
%Possible inputs comprise 'name','value' pairs where 'name' is a property and
%always represented as a string. The 'value' represents the value of the
%named property:
%
% 'InputData',matrix -- a cell or numeric matrix used for data reduction. 
% shape depends on the type of reduction performed
% 'modules',module_vector -- a numerical array of length ROI, which
% represents the communities for each row/column. Items with the same
% numbers represent ROIs in the same community.
% 'DimType',dim_approach -- a string representing the type of
% dimensionality reduction. Currently only 'PCA' is available, but graph
% theoretic approaches are also planned.
%
%OUTPUTS
%
% feature_data -- a 2D matrix NxF matrix, where N is the number of cases
% and F is the number of extracted features. 
dim_type = 'PCA';
if isempty(varargin) == 0
    for i = 1:size(varargin,2)
        if isstruct(varargin{i}) == 0
            if ischar(varargin{i})
                switch(varargin{i})
                    case('InputData')
                        input_data = varargin{i+1};
                    case('Modules')
                        modules = varargin{i+1};
                    case('DimType')
                        dim_type = varargin{i+1};
                    case('NumComponents')
                        num_components = varargin{i+1};
                    case('BCTPath')
                        bctpath = varargin{i+1};
                    case('EdgeDensity')
                        edgedensity = varargin{i+1};
                    case('Systems')
                        systems = varargin{i+1};
                end
            end
        end
    end
end
switch(dim_type)
    case('PCA')
        disp('performing dimensionality reduction via PCA')
        disp(['number of components:' num2str(num_components)])
        nsubs = size(input_data,1);
        module_sets = unique(modules);
        nmodules = length(module_sets);
        feature_data = zeros(nsubs,nmodules*num_components);
        curr_mod_count = 1;
        for curr_mod = 1:nmodules
            [coeff,score,latent] = pca(input_data(:,find(modules == module_sets(curr_mod)))); 
            %right now, just grab the first PCA, but we may switch this since its not optimal
            feature_data(:,curr_mod_count:curr_mod_count+num_components-1) = score(:,1:num_components);
            curr_mod_count = curr_mod_count + num_components;
        end
        disp('dimensionality reduction complete. RFSD will now continue...')
    case('graph')
        disp('performing graph theory extraction with the following features:')
        disp('Betweenness Centrality')
        disp('Degree Centrality')
        disp('Clustering Coefficient')
        disp('participation coefficient')
        disp('local assortativity')
        disp('diversity coefficient')
        disp('eigenvector centrality')
        disp('Within module degree zscore*participation coefficient')
        disp('---------------------')
        disp('metrics extracted: Mean')
        disp('8 total metrics extracted per module')
        module_sets = unique(modules(:,1));
        nmodules = length(module_sets);
        if nmodules == length(modules(:,1))
            graph_ROI = true;
        else
            graph_ROI = false;
        end
        addpath(genpath(bctpath));
        nsubs = size(input_data,3);
        nrois = size(input_data,1);
        %the check below is intended to optimize speed when calculating ROI
        %based metrics -- the modular approach is quite slow and
        %unneccessary here.
        if graph_ROI
            feature_data = zeros(nsubs,nmodules); % currently extracting only one feature per ROI, due to dimensionality issues           
            for curr_sub = 1:nsubs
                threshed_mat = threshold_proportional(input_data(:,:,curr_sub),edgedensity);
                %feature_data(curr_sub,1:nrois) = betweenness_wei(threshed_mat);
                %feature_data(curr_sub,1:nrois)  = feature_data(curr_sub,1:nrois)./((nrois-1)*(nrois-2));
                feature_data(curr_sub,:) = module_degree_zscore(threshed_mat,systems,0);
                %feature_data(curr_sub,(nrois*2)+1:nrois*3) = participation_coef(threshed_mat,systems,0);
            end            
        else
            feature_data = zeros(nsubs,nmodules*8);      
            for curr_sub = 1:nsubs
                threshed_mat = threshold_proportional(input_data(:,:,curr_sub),edgedensity);
                metrics = zeros(nrois,8);
                metrics(:,1) = betweenness_wei(threshed_mat);
                metrics(:,1) = metrics(:,1)./((nrois-1)*(nrois-2));
                metrics(:,2) = degrees_und(threshed_mat);
                metrics(:,3) = clustering_coef_wu(threshed_mat);                
                temp_metric(:,1) = module_degree_zscore(threshed_mat,systems,0);
                metrics(:,4) = participation_coef(threshed_mat,systems,0);
                metrics(:,5) = local_assortativity_wu_sign(input_data(:,:,curr_sub));
                metrics(:,6) = diversity_coef_sign(input_data(:,:,curr_sub),systems);
                metrics(:,7) = eigenvector_centrality_und(threshed_mat);
                metrics(:,8) = temp_metric.*metrics(:,4);
                curr_mod_count = 1;
                for curr_mod = 1:nmodules
                    feature_data(curr_sub,curr_mod_count:curr_mod_count+7) = mean(metrics(modules(modules(:,1) == module_sets(curr_mod),2),:));
                    curr_mod_count = curr_mod_count + 8;                
                end
            end
        end
        feature_data_corr = corr(feature_data);
        h = imagesc(feature_data_corr);
        colorbar
        caxis([min(min(feature_data_corr)) max(max(triu(feature_data_corr,1)))])
        saveas(h,'graph_correlation.tif');
        disp('---------------------')
        disp('graph theory metric extraction complete, RFSD analysis continuing...')
        
end
        
end

