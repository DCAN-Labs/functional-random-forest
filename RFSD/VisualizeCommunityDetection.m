function [community, sorting_order] = VisualizeCommunityDetection(commdirectory,groups,type)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% load communities from commdirectory
if isempty(strfind(computer,'WIN'))
    slashies = '/';
else
    slashies = '\';
end
filecount = 1;
for density = 0.05:0.05:1
    temp = num2str(density,'%2.2f');
    density_str=temp(strfind(temp,'.')+1:end);
    if density == 0.05
        density_dir='5';
    elseif density == 1
        density_dir='100';
    else
        density_dir=density_str;
    end
    commfile=dir(strcat(commdirectory,slashies,'community0p',density_dir,slashies,'community_detection',slashies,'*.txt'));
    commdirplusfile=strcat(commdirectory,slashies,'community0p',density_dir,slashies,'community_detection',slashies,commfile.name);
    init_community_matrix(:,filecount) = dlmread(commdirplusfile);
    filecount = filecount + 1;
end
ncols = size(init_community_matrix,2);
switch(type)
    case('classification')
        acc_subs_across_mods = zeros(ncols,3);
        for i = 1:ncols
            nmods = unique(init_community_matrix(:,i));
            for j = 1:max(size(nmods))
                subs_in_mod = groups(init_community_matrix(:,i) == nmods(j),1);
                if max(size(subs_in_mod)) ~= 1
                    acc_subs_across_mods(i,1) = acc_subs_across_mods(i,1) + size(find(subs_in_mod == mode(subs_in_mod)),1);
                    acc_subs_across_mods(i,3) = acc_subs_across_mods(i,3) + size(find(subs_in_mod ~= mode(subs_in_mod)),1);
                else
                    acc_subs_across_mods(i,2) = acc_subs_across_mods(i,2) + 1;
                end
            end
        end
        weighted_acc = (acc_subs_across_mods(:,1) + acc_subs_across_mods(:,2)*.5)./(acc_subs_across_mods(:,1) + acc_subs_across_mods(:,2) + acc_subs_across_mods(:,3));
        [~,ncol_to_use] = max(weighted_acc);
    case('regression')
        acc_subs_across_mods = zeros(ncols,1);
        for i = 1:ncols
            junk_mods = zeros(size(init_community_matrix,1));
            nmods = unique(init_community_matrix(:,i));
            number_of_nonjunk_mods = 0;
            for j = 1:max(size(nmods))
                subs_in_mod = groups(init_community_matrix(:,i) == nmods(j),1);
                if max(size(subs_in_mod)) == 1
                    junk_mods(find(init_community_matrix(:,i) == nmods(j)),1) = 1;
                else
                    number_of_nonjunk_mods = number_of_nonjunk_mods + 1;
                end
            end
            modvariances = zeros(number_of_nonjunk_mods,1);
            number_of_nonjunk_mods = 0;
            for j = 1:max(size(nmods))
                if max(size(groups(init_community_matrix(:,i) == nmods(j),1))) ~= 1
                    number_of_nonjunk_mods = number_of_nonjunk_mods + 1;
                    modvariances(number_of_nonjunk_mods,1) = var([groups(init_community_matrix(:,i) == nmods(j),1); groups(find(junk_mods == 1),1)]);
                end
            end
            acc_subs_across_mods(i,1) = mean(modvariances);
        end
        [~,ncol_to_use] = max(acc_subs_across_mods);
end
community = init_community_matrix(:,ncol_to_use);
[~,sorting_order] = sort(community,'ascend');

