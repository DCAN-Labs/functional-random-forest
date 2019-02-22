function [modularity] = CalculateModularityPerGroup(adj_mat,modules)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
module_vector = unique(modules);
nmodules = length(module_vector);
modularity = zeros(nmodules,1);
if iscell(adj_mat)
    adj_mat_sum = zeros(size(adj_mat{1}));
    for i = 1:max(size(adj_mat))
        adj_mat_sum = adj_mat_sum + adj_mat{i};
    end
else
    adj_mat_sum = adj_mat;
end
%binarize adjacency matrix
adj_mat_sum = double(adj_mat_sum~=0);
%calculate node_degree
node_degrees = sum(adj_mat_sum);
%calculate total edges m
total_edges = sum(node_degrees);
%vectorization for calculating modularity matrix: B
degree_mat = repmat(node_degrees,length(node_degrees),1);
kikj_mult_mat = degree_mat.*degree_mat';
B = adj_mat_sum - (kikj_mult_mat/(2*total_edges));
for curr_mod = 1:nmodules
    S = ones(length(modules),1)*-1;
    S(modules==module_vector(curr_mod)) = 1;
    modularity(curr_mod) = (S'*B*S)/(4*total_edges);
end
end

