function [observed_modularity,modularity_p] = PermuteModularityPerGroup(adj_mat,modules,nperms)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
rng('shuffle')
observed_modularity = CalculateModularityPerGroup(adj_mat,modules);
permuted_modularity = zeros(length(unique(modules)),nperms);
for curr_perm = 1:nperms
    modules_perm = modules(randperm(length(modules)));
    permuted_modularity(:,curr_perm) = CalculateModularityPerGroup(adj_mat,modules_perm);
end
modularity_p = sum(observed_modularity < permuted_modularity,2)/nperms;
modularity_p(modularity_p==0) = 1/nperms;
end

