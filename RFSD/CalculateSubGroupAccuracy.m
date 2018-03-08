function [subaccuracy] = CalculateSubGroupAccuracy(classmat,groupvector)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
tic
nrows = size(classmat,1);
ngroups = size(unique(groupvector),1);
subaccuracy = zeros(nrows,ngroups+1);
for k = 1:nrows
    temp_classes = classmat(k,:).';
    unique_values = nonzeros(unique(temp_classes));
    nclasses = size(unique_values,1);
    groupings = zeros(ngroups,3);
    for i = 1:ngroups
        [groupings(i,1), groupings(i,2)] = mode(nonzeros(temp_classes(groupvector == i)));
    end
    for j = 1:ngroups
        for i = 1:nclasses
            if groupings(j,1) == unique_values(i)
                if isempty(find(groupings(:,3) == unique_values(i)))
                    groupings(j,3) = unique_values(i);
                end
            end
        end
    end
    if isempty(setdiff(unique_values,groupings(:,3))) == 0
        unassigned_vals = setdiff(unique_values,groupings(:,3));
        unassigned_groups = find(groupings(:,3) == 0);
        count = 0;
        for i = 1:size(unassigned_groups,1)
            for j = 1:size(unassigned_vals,1)
                if size(find(temp_classes(groupvector == unassigned_groups(i)) == unassigned_vals(j)),1)
                    count = count + 1;
                    possible_assignment(count,1) = unassigned_vals(j);
                    possible_assignment(count,2) = size(find(temp_classes(groupvector == unassigned_groups(i)) == unassigned_vals(j)),1);
                end
            end
            [~,assignval_index] = max(possible_assignment(:,2));
            groupings(unassigned_groups(i),3) = possible_assignment(assignval_index,1);
            unassigned_vals = setdiff(unassigned_vals,possible_assignment(assignval_index,1));
            clear possible_assignment
        end
    end
    for i = 1:ngroups
        if groupings(i,3) ~= 0
            subaccuracy(k,i) = size(find(temp_classes(groupvector == i) == groupings(i,3)),1)/(size(find(groupvector == i),1)-size(find(temp_classes(groupvector == i) == 0),1));
        else
            subaccuracy(k,i) = 0;
        end
    end
    subaccuracy(k,ngroups+1) = mean(subaccuracy(k,1:ngroups));
end
toc
end

