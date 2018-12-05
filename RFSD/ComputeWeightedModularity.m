function [ WM ] = ComputeWeightedModularity(weighted_mat,community_assignments,bctpath)
%ComputeWeightedModularity will compute the weighted modularity on a weighted graph
%   Detailed explanation goes here

addpath(genpath(bctpath))
WM = 0;
node_strength = (strengths_und(weighted_mat) - 1)';
network_strength = sum(node_strength)/2;
for curr_node = 1:length(node_strength)
    lambda_weights = double(community_assignments == community_assignments(curr_node));
    pair_weights = (node_strength.*node_strength(curr_node));
    node_mod = (weighted_mat(:,curr_node) - (pair_weights./network_strength)).*lambda_weights;
    node_mod(curr_node) = 0;
    WM = WM + sum(node_mod);
end
WM = WM/network_strength;
