function [community, sorting_order,commproxmat,unsorted_community,reverse_sorting_order,lowdensity,stepdensity,highdensity] = RunAndVisualizeCommunityDetection(proxmat,outdir,command_file,nreps,varargin)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
blah = version;
matlab_version = blah(strfind(version,'(')+1:strfind(version,'(')+5);
clear blah
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
bctpath='/home/faird/shared/code/external/utilities/BCT/BCT/2019_03_03_BCT';
lowdensity = 0.2;
highdensity = 1;
stepdensity = 0.05;
use_search_params=0;
connectedness_thresh = 0.5;
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
                case('GridSearchDir')
                    use_search_params=1;
                    gridsearchdir = varargin{i+1};
                case('BCTPath')
                    bctpath=varargin{i+1};
                case('ConnectednessThreshold')
                    connectedness_thresh = varargin{i+1};
            end
        end
    end
end
addpath(genpath(bctpath))
ncomps_per_rep = length(lowdensity:stepdensity:highdensity);
if size(dir(outdir),1) == 0
    try
        mkdir(outdir);
    catch
        errmsg = strcat('error: directory path is invalid, qutting...',outdir);
        error('TB:dirchk',errmsg);
    end
end
try
    if isempty(dir(command_file))
        errmsg = strcat('error: infomap command not found, command_file variable not valid, but unused as of latest update',command_file);
        warning(errmsg);
    end
catch
    errmsg = strcat('error: infomap command not found, command_file variable not valid, but unused as of latest update',command_file);
    warning(errmsg);
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
ncomps = ncomps_per_rep;
outdirpath = strcat(outdir,filesep);
proxmat_sum = zeros(size(proxmat{1}));
for i = 1:max(size(proxmat))
    proxmat_sum = proxmat_sum + proxmat{i};
end
proxmatpath = strcat(outdirpath,'proxmat_sum.mat');
save(proxmatpath,'proxmat_sum');
commproxmat = zeros(max(size(proxmat_sum)),max(size(proxmat_sum)));
nnodes=size(proxmat_sum,1);
for iter=1:nnodes
    proxmat_sum(iter,iter) = 0;
end
if use_search_params
    modularitygridmax=0;
    grid_folders = dir(strcat(gridsearchdir,'/GS*Low*p*Step*p*High*p*'));
    ngrid_cells  = length(grid_folders);
    count = 0;
    for curr_cell=1:ngrid_cells
        grid_file = dir(strcat(gridsearchdir,'/',grid_folders(curr_cell).name,'/optimal_parameters.csv'));
        if isempty(grid_file) == 0
            count = count + 1;
            grid_data = csvread(strcat(gridsearchdir,'/',grid_folders(curr_cell).name,'/',grid_file.name));
            modularity_data(count,1) = grid_data(1);
            modularity_data(count,2) = grid_data(2);
            modularity_data(count,3) = grid_data(3);
            modularity_data(count,4) = grid_data(4);
            if grid_data(1) > modularitygridmax
                grid_mat = dir(strcat(gridsearchdir,'/',grid_folders(curr_cell).name,'/commproxmat.mat'));
                load(strcat(grid_mat.folder,'/',grid_mat.name))
                binary_matrix = double(abs(commproxmat) > 0);
                [~,comp_sizes] = get_components(binary_matrix);
                max_comp_size = max(comp_sizes);
                proxmat_connectedness = max_comp_size/nnodes;
                if proxmat_connectedness > connectedness_thresh    
                    modularitygridmax=grid_data(1);
                    lowdensity=grid_data(2);
                    stepdensity=grid_data(3);
                    highdensity=grid_data(4);
                end
            end
        end
    end
    %plot low vs high grid for edge density
    figure(1)
    comparison_graph=gramm('x',modularity_data(:,2),'y',modularity_data(:,4),'lightness',round(modularity_data(:,1),4));
    comparison_graph.geom_point();
    comparison_graph.set_names('x','low edge density','y','high edge density','lightness','modularity');
    comparison_graph.set_title('low/high edge density grid');
    comparison_graph.set_text_options('font','Courier',...
        'base_size',14,...
        'label_scaling',1,...
        'legend_scaling',1.5,...
        'legend_title_scaling',1.5,...
        'facet_scaling',1,...
        'title_scaling',1.3);
    comparison_graph.draw();
    comparison_graph.export('file_name',strcat(outdirpath,filesep,'low_vs_high_edge_density'));

    %plot modularity by low edge density
    figure(2)
    comparison_graph=gramm('x',modularity_data(:,2),'y',modularity_data(:,1),'lightness',round(modularity_data(:,1),4));
    comparison_graph.geom_point();
    comparison_graph.set_names('x','low edge density','y','modularity');
    comparison_graph.set_title('modularity by low edge density');
    comparison_graph.set_text_options('font','Courier',...
        'base_size',14,...
        'label_scaling',1,...
        'legend_scaling',1.5,...
        'legend_title_scaling',1.5,...
        'facet_scaling',1,...
        'title_scaling',1.3);
    comparison_graph.no_legend();
    comparison_graph.draw();
    comparison_graph.export('file_name',strcat(outdirpath,filesep,'low_edge_density_by_modularity'));

    %plot modularity by step edge density
    figure(3)
    comparison_graph=gramm('x',modularity_data(:,3),'y',modularity_data(:,1),'lightness',round(modularity_data(:,1),4));
    comparison_graph.geom_point();
    comparison_graph.set_names('x','step edge density','y','modularity');
    comparison_graph.set_title('modularity by step edge density');
    comparison_graph.set_text_options('font','Courier',...
        'base_size',14,...
        'label_scaling',1,...
        'legend_scaling',1.5,...
        'legend_title_scaling',1.5,...
        'facet_scaling',1,...
        'title_scaling',1.3);
    comparison_graph.no_legend();
    comparison_graph.draw();
    comparison_graph.export('file_name',strcat(outdirpath,filesep,'step_edge_density_by_modularity'));


    %plot modularity by high edge density
    figure(4)
    comparison_graph=gramm('x',modularity_data(:,4),'y',modularity_data(:,1),'lightness',round(modularity_data(:,1),4));
    comparison_graph.geom_point();
    comparison_graph.set_names('x','high edge density','y','modularity');
    comparison_graph.set_title('modularity by high edge density');
    comparison_graph.set_text_options('font','Courier',...
        'base_size',14,...
        'label_scaling',1,...
        'legend_scaling',1.5,...
        'legend_title_scaling',1.5,...
        'facet_scaling',1,...
        'title_scaling',1.3);
    comparison_graph.no_legend();
    comparison_graph.draw();
    comparison_graph.export('file_name',strcat(outdirpath,filesep,'high_edge_density_by_modularity'));

    close all
commproxmat = zeros(max(size(proxmat_sum)),max(size(proxmat_sum)));
end
rng('Shuffle');
for density = lowdensity:stepdensity:highdensity
    try
        for iter = 1:5 % EF 2/23/22 adding back in repetitions for stability
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
            dlmwrite(strcat(outdirpath,'community0p',density_dir,filesep,'community0p',density_dir,'_communities.txt'),temp_unsorted_communities);
            ncomms_temp = unique(temp_unsorted_communities);
            for j = 1:max(size(ncomms_temp))
                ROIs_in_comm = find(temp_unsorted_communities == ncomms_temp(j));
                commproxmat(ROIs_in_comm,ROIs_in_comm) = commproxmat(ROIs_in_comm,ROIs_in_comm) + 1;
            end
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
dlmwrite(strcat(outfoldname,filesep,'combined_infomap_communities.txt'),unsorted_community);
outputcommpath = strcat(outdirpath,'final_community_assignments.mat');
save(outputcommpath,'community','sorting_order','unsorted_community','reverse_sorting_order');

