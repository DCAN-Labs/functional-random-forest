function [sparsedatamat,timemat,timebinmat,subjects] = CreateSparseMatrices(datamat,idcol,agecol,valcol,roundfactor)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
if ischar(datamat)
    [~,~,rawdata] = xlsread(datamat);
else
    rawdata = datamat;
end
if iscell(rawdata)
    id = cell2mat(rawdata(2:end,idcol));
    age = cell2mat(rawdata(2:end,agecol));
    val = cell2mat(rawdata(2:end,valcol));
else
    id = rawdata(:,idcol);
    age = rawdata(:,agecol);
    val = rawdata(:,valcol);
end
clear rawdata
if exist('roundfactor','var')
    age_round = round(age .* 10^roundfactor)./(1* 10^roundfactor);
end
subjects = unique(id);
nsubjects = size(subjects,1);
ages = unique(age_round);
ages = sort(ages,'ascend');
nages = size(ages,1);
sparsedatamat=nan(nages,nsubjects);
timemat=nan(nages,nsubjects);
timebinmat = nan(nages,nsubjects);
for i = 1:nsubjects
    id_temp = subjects(i);
    age_temp = age(id==id_temp);
    age_round_temp = age_round(id==id_temp);
    val_temp = val(id==id_temp);
    for j = 1:max(size(age_temp))
        if isempty(find(age_temp(1:max(size(age_temp))~=j) == age_temp(j)))
            if isnan(val_temp(j)) == 0
                sparsedatamat(ages==age_round_temp(j),i) = val_temp(j);
                timemat(ages==age_round_temp(j),i) = age_temp(j);
                timebinmat(ages==age_round_temp(j),i) = age_round_temp(j);
            end
        else
            matched_ages = find(age_temp(1:max(size(age_temp))~=j) == age_temp(j));
            median_val_temp = median(val_temp([j matched_ages]),'omitnan');
            median_age_temp = median(age_temp([j matched_ages]),'omitnan');
            sparsedatamat(ages==age_temp(j),i) = median_val_temp;
            timemat(ages==age_temp(j),i) = median_age_temp;
            timebinmat(ages==age_round_temp(j),i) = age_round_temp(j);
        end
    end
end
end

