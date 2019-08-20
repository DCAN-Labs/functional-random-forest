function [bin_mat] = ThresholdGraph(weighted_mat,edgedensity)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
    ranked_values = sort(unique(triu(weighted_mat,1)),'descend');
    bin_mat = (weighted_mat >= ranked_values(round(length(ranked_values)*edgedensity))).*weighted_mat;

end

