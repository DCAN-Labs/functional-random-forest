function [observed_modularity,modularity_p] = PermuteModularityPerGroupByEdge(adj_mat,modules,nperms,varargin)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
edgedensity = 1;
if isempty(varargin) == 0
    for i = 1:size(varargin,2)
        if isstruct(varargin{i}) == 0
            switch(varargin{i})
                case('EdgeDensity')
                    edgedensity = varargin{i+1};
            end
        end
    end
end
rng('shuffle')
observed_modularity = CalculateModularityPerGroup(adj_mat,modules,'EdgeDensity',edgedensity);
permuted_modularity = zeros(length(unique(modules)),nperms);
for curr_perm = 1:nperms
    modules_perm = modules(randperm(length(modules)));
    permuted_modularity(:,curr_perm) = CalculateModularityPerGroup(adj_mat,modules_perm, 'EdgeDensity',edgedensity);
end
modularity_p = sum(observed_modularity < permuted_modularity,2)/nperms;
modularity_p(modularity_p==0) = 1/nperms;
end

