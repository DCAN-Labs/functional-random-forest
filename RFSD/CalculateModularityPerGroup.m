function [modularity] = CalculateModularityPerGroup(adj_mat,modules,varargin)
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
module_vector = unique(modules);
nmodules = length(module_vector);
modularity = zeros(nmodules,1);
if iscell(adj_mat)
    adj_mat_sum = zeros(size(adj_mat{1}));
    for i = 1:max(size(adj_mat))
        adj_mat_sum = adj_mat_sum + adj_mat{i};
    end
    adj_mat_sum = adj_mat_sum/max(size(adj_mat));
else
    adj_mat_sum = adj_mat;
end
%binarize adjacency matrix
if edgedensity < 1
    adj_mat_sum = ThresholdGraph(adj_mat_sum,edgedensity);
end
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

