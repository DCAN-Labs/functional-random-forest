%these examples create three types of toy two-group datasets:
%1) Two groups where subgroups in each group represent a "low" and "high"
%group. Meant to simulate a toy example where severity of measures is a
%factor
%2) Two groups where two subgroups in one group may "sandwich" the other
%two subgroups. Meant to simulate a toy example where a single threshold is
%insufficient to dissociate the subgroups.
%3) Two groups where subgroups vary by additional variables. Although on
%average, these additional variables will not distinguish between primary groups.
%These additional variables can help distinguish the subgroups in one group from
%another group. Meant to simulate an two example where unrelated variables
%may influence group composition.
%declare cell variables, where each cell contains an array of effect sizes
effsizedouble = cell(3,1);
effsizesign = cell(3,1);
effsizesplitvar = cell(5,1);
%generate 600 variables for examples #1 and #2
effsizedouble{1} = zeros(600,1);
effsizesign{1} = zeros(600,1);
%set the group1 and group2 subject sizes to be even.
group1_subjectsize = 60;
group2_subjectsize = 60;
%set variables for example #1 that generate subgroups
effsizedouble{2} = zeros(600,1) + 0.5;
effsizedouble{3} = zeros(600,1) + 0.5;
%set variablse for example #2 that genereate subgroups
effsizesign{2} = zeros(600,1) + 5;
effsizesign{3} = zeros(600,1) + 5;
%set variables for example #3
effsizesplitvar{1} = zeros(600,1); %variable different between the two groups
effsizesplitvar{2} = zeros(150,1) + 0.5; %variables where subgroup1 in group1 differ
effsizesplitvar{3} = zeros(150,1) + 0.5; %variables where subgroup2 in group1 differ
effsizesplitvar{4} = zeros(150,1) + 0.5; %variables where subgroup1 in group2 differ
effsizesplitvar{5} = zeros(150,1) + 0.5; %variables where subgroup2 in group2 differ
%run functions to generate datasets
[group1_data_double, group2_data_double] = SimulateTwoBiGroupDataByDoubling(group1_subjectsize,group2_subjectsize,effsizedouble{1},effsizedouble{2},effsizedouble{3});
[group1_data_sign, group2_data_sign] = SimulateTwoBiGroupDataBySign(group1_subjectsize,group2_subjectsize,effsizesign{1},effsizesign{2},effsizesign{3});
[group1_data_split, group2_data_split] = SimulateTwoBiGroupDataSplitVar(group1_subjectsize,group2_subjectsize,effsizesplitvar{1},effsizesplitvar{2},effsizesplitvar{3},effsizesplitvar{4},effsizesplitvar{5});
%merge datasets to create group_data suitable for RFAnalysis.
group_col = zeros(group1_subjectsize+group2_subjectsize,1);
group_col(1:group1_subjectsize) = 1;
group_col(group1_subjectsize+1:group1_subjectsize+group2_subjectsize) = 2;
group_data_double = [group_col [group1_data_double;group2_data_double]];
group_data_sign = [group_col [group1_data_sign;group2_data_sign]];
group_data_split = [group_col [group1_data_split;group2_data_split]];
%save data to .mat file
output_filename = 'example_group_comparisons.mat';
save(output_filename,'group_data_double','group_data_sign','group_data_split');