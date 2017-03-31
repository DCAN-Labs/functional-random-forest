function [commcellmat,timepts,datacellmat,timecellmat,accmat,velmat] = ConstructAllSubgroupTrajectories(fdacellvector,community_assignments,sparsedatamat,timemat,subject_use_flag,outputfile)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
communityIDs = unique(community_assignments);
ncommunities = length(communityIDs);
ntrajectories = size(fdacellvector,2);
commcellmat = cell(ncommunities,ntrajectories);
datacellmat = cell(ncommunities,ntrajectories);
timecellmat = cell(ncommunities,ntrajectories);
accmat = cell(ncommunities,ntrajectories);
velmat = cell(ncommunities,ntrajectories);
timepts = cell(ntrajectories,1);
if exist('subject_use_flag','var')
    if isempty(subject_use_flag)
        for i = 1:ntrajectories
            [commcellmat(:,i), timepts{i},datacellmat(:,i),timecellmat(:,i),accmat(:,i),velmat(:,i)] = GenerateSubgroupTrajectories(fdacellvector(:,i),community_assignments,sparsedatamat{i},timemat{i});
        end
    else
        for i = 1:ntrajectories
            [commcellmat(:,i), timepts{i},datacellmat(:,i),timecellmat(:,i),accmat(:,i),velmat(:,i)] = GenerateSubgroupTrajectories(fdacellvector(:,i),community_assignments,sparsedatamat{i},timemat{i},subject_use_flag);
        end
    end
else
    for i = 1:ntrajectories
        [commcellmat(:,i), timepts{i},datacellmat(:,i),timecellmat(:,i),accmat(:,i),velmat(:,i)] = GenerateSubgroupTrajectories(fdacellvector(:,i),community_assignments,sparsedatamat{i},timemat{i});
    end    
end
if exist('outputfile','var')
    save(outputfile,'commcellmat','timepts','datacellmat','timecellmat','accmat','velmat');
end

end

