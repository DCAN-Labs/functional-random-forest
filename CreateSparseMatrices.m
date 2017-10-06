function [sparsedatamat,timemat,timebinmat,subjects,anchor_subjects] = CreateSparseMatrices(datamat,idcol,agecol,valcol,roundfactor,varargin)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
time_range = [NaN NaN];
time_range_flex = 0;
if isempty(varargin) == 0
    for i = 1:size(varargin,2)
        if ischar(varargin{i})
            switch(varargin{i})
                case('time_range')
                    time_range = varargin{i+1};
                case('time_range_flex')
                    time_range_flex = varargin{i+1};
            end
        end
    end
end
datamat(1,1)
if ischar(datamat)
    if strcmp(datamat(end-3:end),'xlsx')
        rawdata = xlsread(datamat);
    elseif strcmp(datamat(end-2:end),'xls')
        rawdata = xlsread(datamat);
    elseif strcmp(datamat(end-2:end),'mat')
        rawdata = struct2array(load(datamat));
    end
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
anchor_subjects = zeros(nsubjects,1);
ages = unique(age_round);
ages = sort(ages,'ascend');
nages = size(ages,1);
sparsedatamat=nan(nages,nsubjects);
timemat=nan(nages,nsubjects);
timebinmat = nan(nages,nsubjects);
time_range
time_range_flex
for i = 1:nsubjects
    id_temp = subjects(i);
    use_subject = 1;
    age_temp = age(id==id_temp);
    age_round_temp = age_round(id==id_temp);
    val_temp = val(id==id_temp);
    age_check = age_round_temp(isnan(val_temp)==0);
    if isnan(time_range(1)) == 0
        [min_age_temp,min_age_index] = min(age_check);
        if time_range(1) > min_age_temp
            [~,new_min_index] = min(abs(age_check - time_range(1)));
            if new_min_index ~= min_age_index
                age_temp = age_temp(age_round_temp >= age_check(new_min_index));
                val_temp = val_temp(age_round_temp >= age_check(new_min_index));
                age_round_temp = age_round_temp(age_round_temp >= age_check(new_min_index));
            end
        elseif time_range(1) < min_age_temp
            temp_flex = min_age_temp - time_range(1);
            if time_range_flex > temp_flex
                age_round_temp(age_round_temp == age_check(min_age_index)) = min_age_temp - temp_flex;
                anchor_subjects(i) = anchor_subjects(i) + 1;
            else
                use_subject = 0;
            end
        end
    end                           
    if isnan(time_range(2)) == 0
        [max_age_temp,max_age_index] = max(age_check);
        if time_range(2) < max_age_temp
            [~,new_max_index] = max(abs(time_range(2) - age_check));
            if new_max_index ~= max_age_index
                age_temp = age_temp(age_round_temp >= age_check(new_max_index));
                val_temp = val_temp(age_round_temp >= age_check(new_max_index));
                age_round_temp = age_round_temp(age_round_temp >= age_check(new_max_index));
            end
        elseif time_range(2) > max_age_temp
            temp_flex = time_range(2) - max_age_temp;
            if time_range_flex > temp_flex
                age_round_temp(age_round_temp == age_check(max_age_index)) = max_age_temp + temp_flex;
                anchor_subjects(i) = anchor_subjects(i) + 2;
            else
                use_subject = 0;
            end
        end
    end    
    if use_subject
        for j = 1:max(size(age_temp))
            if isempty(find(age_temp(1:max(size(age_temp))~=j) == age_temp(j)))
                if isnan(val_temp(j)) == 0
                    sparsedatamat(ages==age_round_temp(j),i) = val_temp(j);
                    timemat(ages==age_round_temp(j),i) = age_temp(j);
                    timebinmat(ages==age_round_temp(j),i) = age_round_temp(j);
                end
            else
                matched_ages = find(age_temp(1:max(size(age_temp))~=j) == age_temp(j));
                median_val_temp = nanmedian(val_temp([j matched_ages]));
                median_age_temp = nanmedian(age_temp([j matched_ages]));
                sparsedatamat(ages==age_temp(j),i) = median_val_temp;
                timemat(ages==age_temp(j),i) = median_age_temp;
                timebinmat(ages==age_round_temp(j),i) = age_round_temp(j);
            end
        end
    end
end
end

