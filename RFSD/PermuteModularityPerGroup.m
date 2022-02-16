function [observed_modularity_all,observed_modularity,modularity_all_p,modularity_p] = PermuteModularityPerGroup(adj_mat,modules,nperms,varargin)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
edgedensity = 1;
if isempty(varargin) == 0
    for i = 1:size(varargin,2)
        if isstruct(varargin{i}) == 0
            switch(varargin{i})
                case('EdgeDensity')
                    edgedensity = varargin{i+1};
                case('JunkThreshold')
                    junkthreshold = varargin{i+1};
            end
        end
    end
end
rng('shuffle')
[observed_modularity_all, observed_modularity]= CalculateModularityPerGroup(adj_mat,modules,'EdgeDensity',edgedensity,'JunkThreshold',junkthreshold);
permuted_modularity = zeros(length(observed_modularity),nperms);
permuted_modularity_all = zeros(1,nperms);
for curr_perm = 1:nperms
    modules_perm = modules(randperm(length(modules)));
    [permuted_modularity_all(1,curr_perm), permuted_modularity(:,curr_perm) ]= CalculateModularityPerGroup(adj_mat,modules_perm, 'EdgeDensity',edgedensity,'JunkThreshold',junkthreshold);
end
modularity_p = sum(observed_modularity < permuted_modularity,2)/nperms;
modularity_p(modularity_p==0) = 1/nperms;
modularity_all_p = sum(observed_modularity_all < permuted_modularity_all)/nperms;
if modularity_all_p == 0
    modularity_all_p = 1/nperms;
end
end

