function [group1_data, group2_data] = SimulateTwoBiGroupDataByDoubling(group1_subjectsize,group2_subjectsize,effsize,effsizesubgroup1,effsizesubgroup2)
%SimulateTwoBiGroupData will generate learning and testing datasets to use for
%constructing a model and predicting the model for two groups with subgroup
%distinctions
%   Inputs:
%       group1_subjectsize -- a whole number that represents the number
%       of subjects in group1
%       group2_subjectsize -- a whole number that represents the number
%       of subjects in group2
%       effsize -- a Mx1 vector where M is the number of variables, each
%       value represents the effect size (cohen's d) of a given variable.
%       effsizesubgroup1 --  Mx1 vector where M is the number of
%       variables, each value represents the effect size between subgroups
%       in group 1
%       effsizesubgroup2 -- a Mx1 vector where M is the number of
%       variables, each value represents the effect size between subgroups
%       in group 2
%   Outputs:
%       group1_data -- an SxM matrix where S is the number of subjects,
%       and M is the number of variables. 
%       group2_data -- an SxM matrix where S is the number of subjects,
%       and M is the number of variables. 
totaleffsize = effsize;
totaleffsize(end+1:end+size(effsizesubgroup1,1),1) = effsizesubgroup1;
totaleffsize(end+1:end+size(effsizesubgroup2,1),1) = effsizesubgroup2;
group1_data = randn(group1_subjectsize,size(totaleffsize,1));
group2_data = randn(group2_subjectsize,size(totaleffsize,1));
for i = 1:size(effsize,1)
    group2_data(:,i) = group2_data(:,i) + effsize(i);
end
count = 0;
for i = size(effsize,1)+1:size(effsize,1)+size(effsizesubgroup1,1)
    count = count + 1;
    group1_data(1:floor(group1_subjectsize/2),i) = group1_data(1:floor(group1_subjectsize/2),i) + effsizesubgroup1(count);
    group1_data(floor(group1_subjectsize/2)+1:group1_subjectsize,i) = group1_data(floor(group1_subjectsize/2)+1:group1_subjectsize,i) + effsizesubgroup1(count)*2;
end
count = 0;
for i = size(effsize,1)+size(effsizesubgroup1,1)+1:size(effsize,1)+size(effsizesubgroup1,1)+size(effsizesubgroup2,1)
    count = count + 1;
    group2_data(1:floor(group2_subjectsize/2),i) = group2_data(1:floor(group2_subjectsize/2),i) + effsizesubgroup2(count);
    group2_data(floor(group2_subjectsize/2)+1:group2_subjectsize,i) = group2_data(floor(group2_subjectsize/2)+1:group2_subjectsize,i) + effsizesubgroup2(count)*2;
end
end