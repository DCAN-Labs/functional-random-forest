function [modularity] = CalculateModularityPerGroup(adj_mat,modules)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
module_vector = unique(modules);
nmodules = length(module_vector);
modularity = zeros(nmodules,1);
%binarize adjacency matrix
adj_mat = double(adj_mat~=0);
%calculate node_degree
node_degrees = sum(adj_mat);
%calculate total edges m
total_edges = sum(node_degrees);
%vectorization for calculating modularity matrix: B
degree_mat = repmat(node_degrees,length(node_degrees),1);
kikj_mult_mat = degree_mat.*degree_mat';
B = adj_mat - (kikj_mult_mat/(2*total_edges));
for curr_mod = 1:nmodules
    S = ones(length(modules),1)*-1;
    S(modules==module_vector(curr_mod)) = 1;
    modularity(curr_mod) = (S'*B*S)/(4*total_edges);
end
end

