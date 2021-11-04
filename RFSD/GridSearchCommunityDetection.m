function [modularity,lowdensity,stepdensity,highdensity] = GridSearchCommunityDetection(proxmat,outdir,nreps,varargin)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
slashies=filesep;
blah = version;
matlab_version = blah(strfind(version,'(')+1:strfind(version,'(')+5);
if isstruct(proxmat)
    proxmat_old = proxmat;
    clear proxmat
    proxmat_new = struct2cell(load(proxmat_old.path,proxmat_old.variable));
    proxmat = proxmat_new{1};
    clear proxmat_new proxmat_old
end
if iscell(proxmat) == 0
    proxmat = {proxmat};
end
lowdensity = 0.01;
highdensity = 0.05;
stepdensity = 0.01;
cleaning = 1;
if isempty(varargin) == 0
    for i = 1:size(varargin,2)
        if isstruct(varargin{i}) == 0
            switch(varargin{i})
                case('LowDensity')
                    lowdensity = varargin{i+1};
                case('HighDensity')
                    highdensity = varargin{i+1};
                case('StepDensity')
                    stepdensity = varargin{i+1};                    
                case('InfomapFile')
					infomapfile = varargin{i+1};
                case('KeepAllFiles')
                    cleaning = 0;
            end
        end
    end
end
modularity = 0;
lowdensityopt = lowdensity;
stepdensityopt = stepdensity;
highdensityopt = highdensity;
if size(dir(outdir),1) == 0
    try
        mkdir(outdir);
    catch
        errmsg = strcat('error: directory path is invalid, qutting...',outdir);
        error('TB:dirchk',errmsg);
    end
end
try
    if isempty(dir(infomapfile))
        errmsg = strcat('error: infomap repo not found, infomapfile variable not valid, quitting...',infomapfile);
        error('TB:comfilechk',errmsg);
    end
catch
    errmsg = strcat('error: infomap repo not found, infomapfile variable not valid, quitting...',infomapfile);
    error('TB:comfilechk',errmsg);
end
ncomps_per_rep = length(lowdensity:stepdensity:highdensity);
ncomps = ncomps_per_rep;
outdirpath = strcat(outdir,filesep);
proxmat_sum = zeros(size(proxmat{1}));
for i = 1:max(size(proxmat))
    proxmat_sum = proxmat_sum + proxmat{i};
end
clear proxmat
commproxmat = zeros(max(size(proxmat_sum)),max(size(proxmat_sum)));
nnodes=size(proxmat_sum,1);
for iter=1:nnodes
    proxmat_sum(iter,iter) = 0;
end
rng('Shuffle');
for density = lowdensity:stepdensity:highdensity
    try
        outfoldname = strcat(outdirpath,'community0p',num2str(density*100));
        mkdir(outfoldname); 
        system(strcat("rm -rf ",outfoldname,filesep,'*'));
       % EF 3/12/21 -- refactoring out simple_infomap.py so running
        % threhsolding and map2pajek here
        indices = matrix_thresholder_simple(proxmat_sum,density);
        pajekfilename = strcat(outfoldname,filesep,'community0p',num2str(density*100),'_pajekfile.net');
        mat2pajek_byindex(proxmat_sum,indices,pajekfilename);
        command = strcat(infomapfile," ",pajekfilename," ",outfoldname,...
            " --clu -2 --tree --ftree -i pajek -fundirected -s ",num2str(randi(9999))," -N ",num2str(nreps));
        system(command);        
        temp = num2str(density,'%2.2f');
        density_str=temp(strfind(temp,'.')+1:end);
        if density < 0.1
            density_dir=num2str(density*100);
        elseif density == 1
            density_dir='100';
        else
            density_dir=density_str;
        end
        commfile=dir(strcat(outdirpath,'community0p',density_dir,filesep,'*.clu'));
        commdirplusfile=strcat(outdirpath,'community0p',density_dir,filesep,commfile.name);
        clutable = readtable(commdirplusfile,'FileType','text','Delimiter',' ','ReadVariableNames',true,'HeaderLines',5);
        if strcmp(matlab_version,'R2021')
            cluarray = cell2mat(table2cell(clutable(4:end,1:2)));
        else
            cluarray = cellfun(@str2num, table2cell(clutable(4:end,1:2)));
        end
        temp_community_matrix = cluarray(:,2);
        temp_sorting_order = cluarray(:,1);
        [~,reverse_sorting_order] = sort(temp_sorting_order,'ascend');
        temp_unsorted_communities = temp_community_matrix(reverse_sorting_order);
        ncomms_temp = unique(temp_unsorted_communities);
        for j = 1:max(size(ncomms_temp))
            ROIs_in_comm = find(temp_unsorted_communities == ncomms_temp(j));
            commproxmat(ROIs_in_comm,ROIs_in_comm) = commproxmat(ROIs_in_comm,ROIs_in_comm) + 1;
        end
        if cleaning
            system(strcat("rm -r ",outdirpath,"community0p",density_dir,filesep));
        end
    catch
    warning(strcat('Error in running infomap. This typically occurs because the edge density used:',num2str(density*100),' does not contain a sufficiently connected graph. Please consult the file to be sure. The program will now skip this specific edge density.'))
    end
end
commproxmat = commproxmat./ncomps;
commproxpath = strcat(outdirpath,'commproxmat.mat');
save(commproxpath,'commproxmat','-v7.3');
outfoldname = strcat(outdirpath,'combined_infomap');
mkdir(outfoldname);
system(strcat("rm -rf ",outfoldname,filesep,'*'));
indices = matrix_thresholder_simple(commproxmat,1);
pajekfilename = strcat(outfoldname,filesep,'combined_filemap_pajekfile.net');
mat2pajek_byindex(commproxmat,indices,pajekfilename);
command = strcat(infomapfile," ",pajekfilename," ",outfoldname,...
" --clu -2 --tree --ftree -i pajek -fundirected -s ",num2str(randi(9999))," -N ",num2str(nreps));
system(command);    
commfile=dir(strcat(outfoldname,filesep,'*.clu'));
commdirplusfile=strcat(outfoldname,filesep,commfile.name);
clutable = readtable(commdirplusfile,'FileType','text','Delimiter',' ','ReadVariableNames',true,'HeaderLines',5);
if strcmp(matlab_version,'R2021')
    cluarray = cell2mat(table2cell(clutable(4:end,1:2)));
else
    cluarray = cellfun(@str2num, table2cell(clutable(4:end,1:2)));
end
community = cluarray(:,2);
sorting_order = cluarray(:,1);
[~,reverse_sorting_order] = sort(sorting_order,'ascend');
unsorted_community=community(reverse_sorting_order);
modularity = CalculateModularityPerGroup(commproxmat,unsorted_community);
if cleaning
    system(strcat("rm -r ",outfoldname));
end
outputcommpath_txt = strcat(outdirpath,'optimal_parameters.csv');
csvwrite(outputcommpath_txt,[modularity,lowdensityopt,stepdensityopt,highdensityopt]); 

