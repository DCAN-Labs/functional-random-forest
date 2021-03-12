function [modularity_max,lowdensityopt,stepdensityopt,highdensityopt] = GridSearchCommunityDetection(proxmat,outdir,command_file,nreps,varargin)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
slashies=filesep;
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
lowdensitymin = 0.01;
lowdensitymax = 0.2;
lowdensitystep = 0.01;
highdensitymin = 0.2;
highdensitymax = 1;
highdensitystep = 0.1;
stepdensitymin = 0.05;
stepdensitymax = 0.05;
stepdensitystep = 1;
if isempty(varargin) == 0
    for i = 1:size(varargin,2)
        if isstruct(varargin{i}) == 0
            switch(varargin{i})
                case('LowDensityMin')
                    lowdensitymin = varargin{i+1};
                case('LowDensityMax')
                    lowdensitymax = varargin{i+1};
                case('LowDensityStep')
                    lowdensitystep = varargin{i+1};
                case('HighDensityMin')
                    highdensitymin = varargin{i+1};
                case('HIghDensityMax')
                    highdensitymax = varargin{i+1};
                case('HighDensityStep')
                    highdensitystep = varargin{i+1};
                case('StepDensityMin')
                    stepdensitymin = varargin{i+1};
                case('StepDensityMax')
                    stepdensitymax = varargin{i+1};
                case('StepDensityStep')
                    stepdensitystep = varargin{i+1};                    
                case('InfomapFile')
					infomapfile = varargin{i+1};
            end
        end
    end
end
modularity_max = 0;
lowdensityopt = lowdensitymin;
stepdensityopt = stepdensitymin;
highdensityopt = highdensitymin;
for lowdensity = lowdensitymin:lowdensitystep:lowdensitymax
    for stepdensity = stepdensitymin:stepdensitystep:stepdensitymax
        for highdensity = highdensitymin:highdensitystep:highdensitymax
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
                    errmsg = strcat('error: infomap command not found, command_file variable not valid, quitting...',command_file);
                    error('TB:comfilechk',errmsg);
                end
            catch
                errmsg = strcat('error: infomap command not found, command_file variable not valid, quitting...',command_file);
                error('TB:comfilechk',errmsg);
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
            ncomps = nreps*ncomps_per_rep;
            outdirpath = strcat(outdir,slashies);
            proxmat_sum = zeros(size(proxmat{1}));
            for i = 1:max(size(proxmat))
                proxmat_sum = proxmat_sum + proxmat{i};
            end
            proxmatpath = strcat(outdirpath,'proxmat_sum.mat');
            save(proxmatpath,'proxmat_sum');
            optionm = ' -m ';
            optiono = ' -o ';
            optionp = ' -p ';
            optionu = ' -u ';
            optioni = ' -i ';
            commproxmat = zeros(max(size(proxmat_sum)),max(size(proxmat_sum)));
            for density = lowdensity:stepdensity:highdensity
                try
                    for i = 1:nreps
                        outfoldname = strcat(outdirpath,'community0p',num2str(density*100));
                        mkdir(outfoldname); 
                        command = [command_file optionu optionm proxmatpath optiono outfoldname optionp num2str(density) optioni infomapfile];
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
                        commfile=dir(strcat(outdirpath,'community0p',density_dir,slashies,'community_detection',slashies,'*.txt'));
                        commdirplusfile=strcat(outdirpath,'community0p',density_dir,slashies,'community_detection',slashies,commfile.name);
                        temp_community_matrix = dlmread(commdirplusfile);
                        ncomms_temp = unique(temp_community_matrix);
                        for j = 1:max(size(ncomms_temp))
                            ROIs_in_comm = find(temp_community_matrix == ncomms_temp(j));
                            commproxmat(ROIs_in_comm,ROIs_in_comm) = commproxmat(ROIs_in_comm,ROIs_in_comm) + 1;
                        end
                    end
                catch
                    warning(strcat('Error in running infomap. This typically occurs because the edge density used:',num2str(density*100),' does not contain a sufficiently connected graph. Please consult the file to be sure. The program will now skip this specific edge density.'));
                    ncomps = ncomps - nreps;
                end
            end
            commproxmat = commproxmat./ncomps;
            commproxpath = strcat(outdirpath,'commproxmat.mat');
            save(commproxpath,'commproxmat','-v7.3');
            outfoldname = strcat(outdirpath,'combined_infomap');
            mkdir(outfoldname);
            command = [command_file optionu optionm commproxpath optiono outfoldname optionp num2str(1) optioni infomapfile];
            system(command);
            commfile=dir(strcat(outfoldname,slashies,'community_detection',slashies,'*.txt'));
            commdirplusfile=strcat(outfoldname,slashies,'community_detection',slashies,commfile.name);
            community = dlmread(commdirplusfile);
            modularity_obs = CalculateModularityPerGroup(commproxmat,community);
            if modularity_obs > modularity_max
                lowdensityopt = lowdensity;
                stepdensityopt = stepdensity;
                highdensityopt = highdensity;
            end
        end
    end
end
outputcommpath = strcat(outdirpath,'optimal_parameters.mat');
outputcommpath_txt = strcat(outdirpath,'optimal_parameters.csv');
save(outputcommpath,'modularity_max','lowdensityopt','stepdensityopt','highdensityopt');
csvwrite(outputcommpath_txt,[modularity_max,lowdensityopt,stepdensityopt,highdensityopt]); 

