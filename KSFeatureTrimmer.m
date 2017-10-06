function [trimmed_group1_data,trimmed_group2_data,features_used] = KSFeatureTrimmer(group1_data,group2_data,nfeatures)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
nvars = size(group1_data,2);
KSTATS = zeros(nvars,1);
for i = 1:nvars
    KSTATS(i) = kstest2(group1_data(:,i),group2_data(:,i));
end
[~,comp_index] = sort(KSTATS,'descend');
features_used = comp_index(1:nfeatures,1);
trimmed_group1_data = group1_data(:,features_used);
trimmed_group2_data = group2_data(:,features_used);
end

