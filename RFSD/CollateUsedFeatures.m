function featuremat = CollateUsedFeatures(tree,nvars)
%I'll put stuff here later because I'm lazy.
%
%Sorry, it could be worse though.
tic
featuremat = zeros(nvars,1);
for i = 1:max(size(tree))
    tempvals = cell2mat(cellfun(@(x) str2num(x(2:end)),tree{i}.CutPredictor,'UniformOutput',0));
    for j = 1:size(tempvals,1)
        featuremat(tempvals(j)) = featuremat(tempvals(j)) + 1;
    end
end
toc
end