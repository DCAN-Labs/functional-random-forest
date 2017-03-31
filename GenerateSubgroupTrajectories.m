function [commcellmat,timepts,datacellmat,timecellmat,accmat,velmat] = GenerateSubgroupTrajectories(fdacellvector,community_assignments,sparsedatamat,timemat,subject_use_flag,outputfile)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
if exist('subject_use_flag','var')
    fda_celldata = fdacellvector(subject_use_flag==1);
    sparsedatamat_touse = sparsedatamat(:,subject_use_flag==1);
    timemat_touse = timemat(:,subject_use_flag==1);
else
    fda_celldata = fdacellvector;
    sparsedatamat_touse = sparsedatamat;
    timemat_touse = timemat;
end
timepts = fda_celldata{1}.timefine;
ndatapts = length(fda_celldata{1}.datafine);
nrawdatapts = size(sparsedatamat_touse,1);
communityIDs = unique(community_assignments);
ncommunities = length(communityIDs);
commcellmat = cell(ncommunities,1);
datacellmat = cell(ncommunities,1);
timecellmat = cell(ncommunities,1);
for i = 1:ncommunities
    commcellmat{i} = zeros(length(find(community_assignments == communityIDs(i))),ndatapts);
    accmat = commcellmat;
    velmat = commcellmat;
    datacellmat{i} = nan(length(find(community_assignments == communityIDs(i))),nrawdatapts);
    timecellmat{i} = nan(length(find(community_assignments == communityIDs(i))),nrawdatapts);
end
commcounts = zeros(ncommunities,1);
for i = 1:length(community_assignments)
    commcounts(community_assignments(i)) = commcounts(community_assignments(i)) + 1;
    commcellmat{community_assignments(i)}(commcounts(community_assignments(i)),:) = fda_celldata{i}.datafine;
    accmat{community_assignments(i)}(commcounts(community_assignments(i)),:) = fda_celldata{i}.accfine;
    velmat{community_assignments(i)}(commcounts(community_assignments(i)),:) = fda_celldata{i}.velfine;
    datacellmat{community_assignments(i)}(commcounts(community_assignments(i)),:) = sparsedatamat_touse(:,i);
    timecellmat{community_assignments(i)}(commcounts(community_assignments(i)),:) = timemat_touse(:,i);
end
if exist('outputfile','var')
    save(outputfile,'commcellmat','timepts','datacellmat','timecellmat','accmat','velmat');
end
end

