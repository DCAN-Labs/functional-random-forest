function [ datafinecorrmat ] = GenerateTrajectoryCorrelationMatrix(functional_data_group,subject_use_flag,filename,corrtype,piecetype,timebinmat)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
if exist('piecetype','var') == 0
    piecetype = 'full';
end
if exist('corrtype','var') == 0
    corrtype='all';
end
if isstruct(functional_data_group)
    functional_data_group_old = functional_data_group;
    clear functional_data_group
    functional_data_group_new = struct2cell(load(functional_data_group_old.path,functional_data_group_old.variable));
    functional_data_group = functional_data_group_new{1};
    clear functional_data_group_new functional_data_group_old
end
if exist('subject_use_flag','var') == 0
else
    if isempty(subject_use_flag)
    elseif isstruct(subject_use_flag)
        subject_use_flag_old = subject_use_flag;
        clear subject_use_flag
        subject_use_flag_new = struct2cell(load(subject_use_flag_old.path,subject_use_flag_old.variable));
        subject_use_flag = subject_use_flag_new{1};
        clear subject_use_flag_new subject_use_flag_old
        functional_data_touse = functional_data_group(sum(subject_use_flag,2) == size(subject_use_flag,2),:);
    else
        functional_data_touse = functional_data_group(sum(subject_use_flag,2) == size(subject_use_flag,2),:);
    end
end
switch(piecetype)
    case('full')
    switch(corrtype)
        case('dat')
        nsubs = size(functional_data_touse,1);
        ntrajs = size(functional_data_touse,2);
        nbins = length(functional_data_touse{1}.datafine);
        datafinemat = zeros(nbins,nsubs);
        datafinecorrmat_all = zeros(nsubs,nsubs,ntrajs);
        for j = 1:ntrajs
            for i = 1:nsubs
                datafinemat(:,i) = functional_data_touse{i,j}.datafine;
            end
            datafinecorrmat_all(:,:,j) = corr(datafinemat);
        end
        if ntrajs > 1
            datafinecorrmat = mean(datafinecorrmat_all,3);
        else
            datafinecorrmat = datafinecorrmat_all;
        end
        case('acc')
        nsubs = size(functional_data_touse,1);
        ntrajs = size(functional_data_touse,2);
        nbins = length(functional_data_touse{1}.accfine);
        datafinemat = zeros(nbins,nsubs);
        datafinecorrmat_all = zeros(nsubs,nsubs,ntrajs);
        for j = 1:ntrajs
            for i = 1:nsubs
                datafinemat(:,i) = functional_data_touse{i,j}.accfine;
            end
            datafinecorrmat_all(:,:,j) = corr(datafinemat);
        end
        if ntrajs > 1
            datafinecorrmat = mean(datafinecorrmat_all,3);
        else
            datafinecorrmat = datafinecorrmat_all;
        end        
        case('vel')
        nsubs = size(functional_data_touse,1);
        ntrajs = size(functional_data_touse,2);
        nbins = length(functional_data_touse{1}.velfine);
        datafinemat = zeros(nbins,nsubs);
        datafinecorrmat_all = zeros(nsubs,nsubs,ntrajs);
        for j = 1:ntrajs
            for i = 1:nsubs
                datafinemat(:,i) = functional_data_touse{i,j}.velfine;
            end
            datafinecorrmat_all(:,:,j) = corr(datafinemat);
        end
        if ntrajs > 1
            datafinecorrmat = mean(datafinecorrmat_all,3);
        else
            datafinecorrmat = datafinecorrmat_all;
        end    
        case('all')
        nsubs = size(functional_data_touse,1);
        ntrajs = size(functional_data_touse,2);
        nbins = length(functional_data_touse{1}.datafine);
        datafinemat = zeros(nbins,nsubs,3);
        datafinecorrmat_all = zeros(nsubs,nsubs,ntrajs);
        for j = 1:ntrajs
            corrmat_temp = zeros(nsubs,nsubs,3);
            for i = 1:nsubs
                datafinemat(:,i,1) = functional_data_touse{i,j}.datafine;
                datafinemat(:,i,2) = functional_data_touse{i,j}.velfine;
                datafinemat(:,i,3) = functional_data_touse{i,j}.accfine;
            end
            corrmat_temp(:,:,1) = corr(datafinemat(:,:,1));
            corrmat_temp(:,:,2) = corr(datafinemat(:,:,2));
            corrmat_temp(:,:,3) = corr(datafinemat(:,:,3));
            datafinecorrmat_all(:,:,j) = mean(corrmat_temp,3);
        end
        if ntrajs > 1
            datafinecorrmat = mean(datafinecorrmat_all,3);
        else
            datafinecorrmat = datafinecorrmat_all;
        end   
    end
    case('piece')
    switch(corrtype)
        case('dat')
        nsubs = size(functional_data_touse,1);
        ntrajs = size(functional_data_touse,2);
        timebins = unique(timebinmat{1});
        timebins_index = find(isnan(timebins) == 0);
        timebins = timebins(timebins_index);
        timemulti = length(functional_data_touse{1,1}.datafine)/length(functional_data_touse{1,1}.timevector);
        nbins = length(timebins)*timemulti;
        datafinecorrmat_all = zeros(nsubs,nsubs,ntrajs);
        for j = 1:ntrajs
            datafinemat = nan(nbins,nsubs);
            for i = 1:nsubs
                blah_vect = [timebins_index(ismember(timebins,functional_data_touse{i,j}.timevector))*timemulti-timemulti+1];
                for blah = 2:timemulti
                    blah_vect = vertcat(blah_vect,[timebins_index(ismember(timebins,functional_data_touse{i,j}.timevector))*timemulti-timemulti+blah]);
                end
                blah_vect = sort(blah_vect);                
                datafinemat(blah_vect,i) = functional_data_touse{i,j}.datafine;
            end
            for subjects = 1:nsubs-1
                for subject_pair = subjects+1:nsubs
                    if length(find(sum(isnan(datafinemat(:,[subjects subject_pair])),2) == 0)) > timemulti*0
                        datafinecorrmat_all([subjects subject_pair],[subjects subject_pair],j) = corr(datafinemat(:,[subjects subject_pair]),'rows','complete');
                    end
                end
            end  
        end
        if ntrajs > 1
            datafinecorrmat = mean(datafinecorrmat_all,3);
        else
            datafinecorrmat = datafinecorrmat_all;
        end
        case('acc')
        nsubs = size(functional_data_touse,1);
        ntrajs = size(functional_data_touse,2);
        timebins = unique(timebinmat{1});
        timebins_index = find(isnan(timebins) == 0);
        timebins = timebins(timebins_index);
        timemulti = length(functional_data_touse{1,1}.datafine)/length(functional_data_touse{1,1}.timevector);
        nbins = length(timebins)*timemulti;
        datafinecorrmat_all = zeros(nsubs,nsubs,ntrajs);
        for j = 1:ntrajs
            datafinemat = nan(nbins,nsubs);
            for i = 1:nsubs
                blah_vect = [timebins_index(ismember(timebins,functional_data_touse{i,j}.timevector))*timemulti-timemulti+1];
                for blah = 2:timemulti
                    blah_vect = vertcat(blah_vect,[timebins_index(ismember(timebins,functional_data_touse{i,j}.timevector))*timemulti-timemulti+blah]);
                end
                blah_vect = sort(blah_vect);                
                datafinemat(blah_vect,i) = functional_data_touse{i,j}.accfine;
            end
            for subjects = 1:nsubs-1
                for subject_pair = subjects+1:nsubs
                    if length(find(sum(isnan(datafinemat(:,[subjects subject_pair])),2) == 0)) > timemulti*0
                        datafinecorrmat_all([subjects subject_pair],[subjects subject_pair],j) = corr(datafinemat(:,[subjects subject_pair]),'rows','complete');
                    end
                end
            end  
        end
        if ntrajs > 1
            datafinecorrmat = mean(datafinecorrmat_all,3);
        else
            datafinecorrmat = datafinecorrmat_all;
        end        
        case('vel')
        nsubs = size(functional_data_touse,1);
        ntrajs = size(functional_data_touse,2);
        timebins = unique(timebinmat{1});
        timebins_index = find(isnan(timebins) == 0);
        timebins = timebins(timebins_index);
        timemulti = length(functional_data_touse{1,1}.datafine)/length(functional_data_touse{1,1}.timevector);
        nbins = length(timebins)*timemulti;
        datafinecorrmat_all = zeros(nsubs,nsubs,ntrajs);
        for j = 1:ntrajs
            datafinemat = nan(nbins,nsubs);
            for i = 1:nsubs
                blah_vect = [timebins_index(ismember(timebins,functional_data_touse{i,j}.timevector))*timemulti-timemulti+1];
                for blah = 2:timemulti
                    blah_vect = vertcat(blah_vect,[timebins_index(ismember(timebins,functional_data_touse{i,j}.timevector))*timemulti-timemulti+blah]);
                end
                blah_vect = sort(blah_vect);                
                datafinemat(blah_vect,i) = functional_data_touse{i,j}.velfine;
            end
            for subjects = 1:nsubs-1
                for subject_pair = subjects+1:nsubs
                    if length(find(sum(isnan(datafinemat(:,[subjects subject_pair])),2) == 0)) > timemulti*0
                        datafinecorrmat_all([subjects subject_pair],[subjects subject_pair],j) = corr(datafinemat(:,[subjects subject_pair]),'rows','complete');
                    end
                end
            end            
        end
        if ntrajs > 1
            datafinecorrmat = mean(datafinecorrmat_all,3);
        else
            datafinecorrmat = datafinecorrmat_all;
        end    
        case('all')
        nsubs = size(functional_data_touse,1);
        ntrajs = size(functional_data_touse,2);
        timebins = unique(timebinmat{1});
        timebins_index = find(isnan(timebins) == 0);
        timebins = timebins(timebins_index);
        timemulti = length(functional_data_touse{1,1}.datafine)/length(functional_data_touse{1,1}.timevector);
        nbins = length(timebins)*timemulti;
        datafinecorrmat_all = zeros(nsubs,nsubs,ntrajs);
        for j = 1:ntrajs
            datafinemat = nan(nbins,nsubs,3);
            corrmat_temp = zeros(nsubs,nsubs,3);
            for i = 1:nsubs
                blah_vect = [timebins_index(ismember(timebins,functional_data_touse{i,j}.timevector))*timemulti-timemulti+1];
                for blah = 2:timemulti
                    blah_vect = vertcat(blah_vect,[timebins_index(ismember(timebins,functional_data_touse{i,j}.timevector))*timemulti-timemulti+blah]);
                end
                blah_vect = sort(blah_vect);
                datafinemat(blah_vect,i,1) = functional_data_touse{i,j}.datafine;
                datafinemat(blah_vect,i,2) = functional_data_touse{i,j}.velfine;
                datafinemat(blah_vect,i,3) = functional_data_touse{i,j}.accfine;
            end
            for subjects = 1:nsubs-1
                for subject_pair = subjects+1:nsubs
                    if length(find(sum(isnan(datafinemat(:,[subjects subject_pair],1)),2) == 0)) > timemulti*0
                        corrmat_temp([subjects subject_pair],[subjects subject_pair],1) = corr(datafinemat(:,[subjects subject_pair],1),'rows','complete');
                        corrmat_temp([subjects subject_pair],[subjects subject_pair],2) = corr(datafinemat(:,[subjects subject_pair],2),'rows','complete');
                        corrmat_temp([subjects subject_pair],[subjects subject_pair],3) = corr(datafinemat(:,[subjects subject_pair],3),'rows','complete');                                        
                    end
                end
            end
            datafinecorrmat_all(:,:,j) = mean(corrmat_temp,3);
        end
        if ntrajs > 1
            datafinecorrmat = mean(datafinecorrmat_all,3);
        else
            datafinecorrmat = datafinecorrmat_all;
        end   
    end        
end
if exist('filename','var')
    save(strcat(filename,'/fda_corrmat.mat'),'datafinecorrmat','datafinecorrmat_all');
end
end

