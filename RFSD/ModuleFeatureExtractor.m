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
% 'InputData',matrix -- a 3D numerical matrix organized in an ROIxROIxN matrix
% where N is the number of cases
% 'modules',module_vector -- a numerical array of length ROI, which
% represents the communities for each row/column. Items with the same
% numbers represent ROIs in the same community.
% 'DimType',dim_approach -- a string representing the type of
% dimensionality reduction. Currently only 'PCA' is available, but graph
% theoretic approaches are also planned.
% 'NetworksOnly' sets whether features are extracted
% from within networks or also within and between. In the example above,
% setting this to true would reduce the number of features from 153 to 17.
%
%OUTPUTS
%
% feature_data -- a 2D matrix NxF matrix, where N is the number of cases
% and F is the number of extracted features. 
dim_type = 'PCA';
if isempty(varargin) == 0
    for i = 1:size(varargin,2)
        if isstruct(varargin{i}) == 0
           switch(varargin{i})
                case('InputData')
                    input_data = varargin{i+1};
                case('Modules')
                    modules = varargin{i+1};
                case('DimType')
                    dim_type = varargin{i+1};
           end
        end
    end
end
module_sets = unique(modules);
nmodules = length(module_sets);
nsubs = size(input_data,1);
feature_data = zeros(nsubs,nmodules);
switch(dim_type)
    case('PCA')
        for curr_mod = 1:nmodules
            [coeff,score,latent] = pca(input_data(:,find(modules == module_sets(curr_mod)))); 
            %right now, just grab the first PCA, but we may switch this since its not optimal
            feature_data(:,curr_mod) = score(:,1);
        end
end
        
end

