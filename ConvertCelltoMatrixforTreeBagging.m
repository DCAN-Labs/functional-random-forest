function [categorical_vector datamat] = ConvertCelltoMatrixforTreeBagging(data)
[nsubs nvars] = size(data);
datamat = zeros(nsubs,nvars);
categorical_vector = zeros(1,nvars);
for k = 1:nvars
    try
        datamat(:,k) = cell2mat(data(:,k));
    catch
        categorical_vector(k) = 1;
        uniques = unique(data(:,k));
        for i = 1:max(size(uniques))
            if strcmp(char(uniques{i}),'NaN')
                datamat(cellfun(@(x) isempty(x),strfind(data(:,k),char(uniques{i}))) == 0,k) = NaN; 
            else
                datamat(cellfun(@(x) isempty(x),strfind(data(:,k),char(uniques{i}))) == 0,k) = i;
            end
        end
    end
end
categorical_vector = logical(categorical_vector);
end