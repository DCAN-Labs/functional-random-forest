%unit test for building AlignSubGroups.m -- set the package_path to the apprporiate
%repo before running
package_path='/mnt/max/shared/projects/FAIR_users/Feczko/code_in_dev/RFAnalysis/';

addpath(genpath(package_path))

%% declare variables
threshold = 0.1;
target_community_assignments = randi(5,20,5);
scaled_community_assignments = target_community_assignments(:,1) + 10;
shuffled_community_assignments = target_community_assignments(randperm(length(target_community_assignments)));
denser_community_assignments = randi(10,20,1);
tighter_community_assignments = randi(3,20,1);

%% run scaled test

aligned_scaled_community_assignments = AlignSubGroups(target_community_assignments,scaled_community_assignments,'Threshold',threshold);

%% run shuffled test

aligned_shuffled_community_assignments = AlignSubGroups(target_community_assignments,shuffled_community_assignments,'Threshold',threshold);

%% run denser test

aligned_dense_community_assignments = AlignSubGroups(target_community_assignments,denser_community_assignments,'Threshold',threshold);


%% run tighter test

aligned_tighter_community_assignments = AlignSubGroups(target_community_assignments,tighter_community_assignments,'Threshold',threshold);
