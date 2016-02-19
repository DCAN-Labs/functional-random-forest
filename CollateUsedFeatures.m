function featuremat = CollateUsedFeatures(pruned_tree,nvars)
%I'll put stuff here later because I'm lazy.
%
%Sorry, it could be worse though.
tic
maximum_level = 0;
for i = 1:size(pruned_tree,1)
    if max(pruned_tree{i}.PruneList) > maximum_level
        maximum_level = max(pruned_tree{i}.PruneList);
    end
end
featuremat = zeros(size(pruned_tree,1),nvars,maximum_level);
for i = 1:size(pruned_tree,1)
    tempvals = cell2mat(cellfun(@(x) str2num(x(2:end)),pruned_tree{i}.CutPredictor,'UniformOutput',0));
    node_levels = pruned_tree{i}.PruneList(pruned_tree{i}.PruneList ~= 0);
    for j = 1:size(node_levels,1)
        featuremat(i,tempvals(j),node_levels(j)) = featuremat(i,tempvals(j),node_levels(j)) + 1;
    end
end
toc
end