function [commcellmat,timepts,datacellmat,timecellmat,accmat,velmat] = GenerateSubgroupTrajectories(fdacellvector,community_assignments,sparsedatamat,timemat,subject_use_flag,outputfile,piecetype,timebinmat)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
if exist('piecetype','var')
    if isempty(piecetype)
        piecetype = 'full';
    end
else
    piecetype = 'full';
end
if exist('subject_use_flag','var')
    if isempty(subject_use_flag) == 0
        fda_celldata = fdacellvector(subject_use_flag==1);
        sparsedatamat_touse = sparsedatamat(:,subject_use_flag==1);
        timemat_touse = timemat(:,subject_use_flag==1);
    else
        fda_celldata = fdacellvector;
        sparsedatamat_touse = sparsedatamat;
        timemat_touse = timemat; 
    end
else
    fda_celldata = fdacellvector;
    sparsedatamat_touse = sparsedatamat;
    timemat_touse = timemat;
end
if strcmp(piecetype,'piece')
    timebins = unique(timebinmat{1});
    timebins_index = find(isnan(timebins) == 0);
    timebins = timebins(timebins_index);
    timemulti = length(fda_celldata{1,1}.datafine)/length(fda_celldata{1,1}.timevector);
    ndatapts = length(timebins)*timemulti;
    timepts = linspace(min(timebins),max(timebins),ndatapts);
else
    timepts = fda_celldata{1}.timefine;
    ndatapts = length(fda_celldata{1}.datafine);
end
nrawdatapts = size(sparsedatamat_touse,1);
communityIDs = unique(community_assignments);
ncommunities = length(communityIDs);
commcellmat = cell(ncommunities,1);
datacellmat = cell(ncommunities,1);
timecellmat = cell(ncommunities,1);
for i = 1:ncommunities
    commcellmat{i} = nan(length(find(community_assignments == communityIDs(i))),ndatapts);
    accmat = commcellmat;
    velmat = commcellmat;
    datacellmat{i} = nan(length(find(community_assignments == communityIDs(i))),nrawdatapts);
    timecellmat{i} = nan(length(find(community_assignments == communityIDs(i))),nrawdatapts);
end
commcounts = zeros(ncommunities,1);
switch(piecetype)
    case('full')
        for i = 1:length(community_assignments)
            commcounts(community_assignments(i)) = commcounts(community_assignments(i)) + 1;
            commcellmat{community_assignments(i)}(commcounts(community_assignments(i)),:) = fda_celldata{i}.datafine;
            accmat{community_assignments(i)}(commcounts(community_assignments(i)),:) = fda_celldata{i}.accfine;
            velmat{community_assignments(i)}(commcounts(community_assignments(i)),:) = fda_celldata{i}.velfine;
            datacellmat{community_assignments(i)}(commcounts(community_assignments(i)),:) = sparsedatamat_touse(:,i);
            timecellmat{community_assignments(i)}(commcounts(community_assignments(i)),:) = timemat_touse(:,i);
        end
    case('piece')
        for i = 1:length(community_assignments)
            commcounts(community_assignments(i)) = commcounts(community_assignments(i)) + 1;
            blah_vect = [timebins_index(ismember(timebins,fda_celldata{i}.timevector))*timemulti-timemulti+1];
            for blah = 2:timemulti
                blah_vect = vertcat(blah_vect,[timebins_index(ismember(timebins,fda_celldata{i}.timevector))*timemulti-timemulti+blah]);
            end
            blah_vect = sort(blah_vect);           
            commcellmat{community_assignments(i)}(commcounts(community_assignments(i)),blah_vect) = fda_celldata{i}.datafine;
            accmat{community_assignments(i)}(commcounts(community_assignments(i)),blah_vect) = fda_celldata{i}.accfine;
            velmat{community_assignments(i)}(commcounts(community_assignments(i)),blah_vect) = fda_celldata{i}.velfine;
            datacellmat{community_assignments(i)}(commcounts(community_assignments(i)),:) = sparsedatamat_touse(:,i);
            timecellmat{community_assignments(i)}(commcounts(community_assignments(i)),:) = timemat_touse(:,i);
        end        
end
if exist('outputfile','var')
    if isempty(outputfile) == 0
        save(outputfile,'commcellmat','timepts','datacellmat','timecellmat','accmat','velmat');
    end
end
end

