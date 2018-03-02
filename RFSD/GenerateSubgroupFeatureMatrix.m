function feature_matrix = GenerateSubgroupFeatureMatrix(community,group1_data,group2_data)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
categorical_vector = 0;
if iscell(group1_data)
    [categorical_vector, group1_data] = ConvertCelltoMatrixforTreeBagging(group1_data);
else
    categorical_vector = logical(zeros(size(group1_data,2),1));
end
if iscell(group2_data)
    [categorical_vector, group2_data] = ConvertCelltoMatrixforTreeBagging(group2_data);
    all_data = group1_data;
    all_data(size(group1_data,1)+1:size(group1_data,1)+size(group2_data,1),:) = group2_data;    
elseif group2_data == 0
    all_data = group1_data;   
else
    all_data = group1_data;
    all_data(size(group1_data,1)+1:size(group1_data,1)+size(group2_data,1),:) = group2_data;
end
categorical_vectors_to_use = categorical_vector;
subgroups = unique(community);
nsubgroups = size(subgroups,1);
nsubgroup_count = 0;
for i = 1:nsubgroups
    if max(size(find(community == subgroups(i)))) > 1
        nsubgroup_count = nsubgroup_count + 1;
    end
end
feature_matrix = zeros(size(all_data,2),nsubgroup_count,3) + 10;
for feature = 1:size(all_data,2)
    if categorical_vectors_to_use == 0
        feature_data = (tiedrank(all_data(:,feature))-1) / (length(all_data(:,feature))-1);
    elseif categorical_vectors_to_use(feature) == 0
        feature_data = (tiedrank(all_data(:,feature))-1) / (length(all_data(:,feature))-1);
    else
        feature_data = all_data(:,feature);
    end
    nsubgroup_count = 1;
    for subgroup = 1:nsubgroups
        if max(size(find(community == subgroups(subgroup)))) > 1
            if categorical_vectors_to_use == 0
                feature_matrix(feature,subgroup,:) = prctile(feature_data(community == subgroups(subgroup)),[17 50 83]);
            elseif categorical_vectors_to_use(feature) == 0
                feature_matrix(feature,subgroup,:) = prctile(feature_data(community == subgroups(subgroup)),[17 50 83]);
            else
                feature_matrix(feature,subgroup,:) = 1;
            end
            nsubgroup_count = nsubgroup_count + 1;
        end
    end
end

