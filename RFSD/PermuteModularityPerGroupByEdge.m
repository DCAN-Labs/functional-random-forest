function [observed_modularity_all,observed_modularity,modularity_all_p,modularity_p] = PermuteModularityPerGroupByEdge(varargin)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
lowdensity=0.05;
stepdensity=0.05;
highdensity=1;
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
                case('NumPermutations')
                    nperms = varargin{i+1};
                case('Modules')
                    modules = varargin{i+1};
                case('InputMatrix')
                    adj_mat = varargin{i+1};
            end
        end
    end
end
ncomps_to_rep = length(lowdensity:stepdensity:highdensity);
col_count = 1;
observed_modularity=zeros(length(unique(modules)),ncomps_to_rep);
observed_modularity_all = zeros(1,ncomps_to_rep);
for curr_density = lowdensity:stepdensity:highdensity
    [observed_modularity_all(1,col_count),observed_modularity(:,col_count)] = CalculateModularityPerGroup(adj_mat,modules,'EdgeDensity',edgedensity);
    col_count = col_count + 1;
end
rng('shuffle')
permuted_modularity = zeros(length(unique(modules)),nperms);
permuted_modularity_all = zeros(1,nperms);
for curr_perm = 1:nperms
    modules_perm = modules(randperm(length(modules)));
    [permuted_modularity_all(1,curr_perm),permuted_modularity(:,curr_perm)] = CalculateModularityPerGroup(adj_mat,modules_perm, 'EdgeDensity',edgedensity);
end
modularity_p = sum(observed_modularity < permuted_modularity,2)/nperms;
modularity_p(modularity_p==0) = 1/nperms;
modularity_all_p = sum(observed_modularity_all < permuted_modularity_all)/nperms;
if modularity_all_p == 0
    modularity_all_p = 1/nperms;
end

end

