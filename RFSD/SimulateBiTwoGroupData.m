function [group1_data, group2_data] = SimulateBiTwoGroupData(group1_subjectsize,group2_subjectsize,effsizegroup,effsizesubgroup1,effsizesubgroup2)
%SimulateTwoGroupData will generate learning and testing datasets to use for
%constructing a model and predicting the model for two groups only
%   Inputs:
%       group1_subjectsize -- a whole number that represents the number
%       of subjects in group1
%       group2_subjectsize -- a whole number that represents the number
%       of subjects in group2
%       effsize -- a Mx1 vector where M is the number of variables, each
%       value represents the effect size (cohen's d) of a given variable.
%   Outputs:
%       group1_data -- an SxM matrix where S is the number of subjects,
%       and M is the number of variables. 
%       group2_data -- an SxM matrix where S is the number of subjects,
%       and M is the number of variables. 
group1_data = randn(group1_subjectsize,size(effsize,1));
group2_data = randn(group2_subjectsize,size(effsize,1));
for i = 1:size(effsize,1)
    group2_data(:,i) = group2_data(:,i) + effsize(i);
end
end

