function [accuracy,permute_accuracy,treebag,proxmat,features,trimmed_features,npredictors,group1class,group2class,outofbag_error,outofbag_varimp,final_data,final_outcomes,group1predict,group2predict,group1scores,group2scores] = ConstructModelTreeBag(group1_data,group2_data,datasplit,nrepsCI,ntrees,nrepsPM,filename,proximity_sub_limit,varargin)
%ConstructModelTreeBag generates a model comprising ensembles of trees and 
%examines the accuracy on data left out of the sample. One can select a
%number of permutations to generate permuted accuracy under the assumptions
%of the null hypothesis (e.g. sets of null distributions of accuracy).
%%%%INPUTS:%%%%%
%       group1_data -- A NxM two-dimensional matrix where N represents the
%       subjects and M respresents the variables (e.g. features). The
%       matrix can be a cell matrix if one has categorical variables.
%       group2_data -- A NxM two-dimensional matrix where N represents the
%       subjects and M respresents the variables (e.g. features). The
%       matrix can be a cell matrix if one has categorical variables.
%       datasplit -- a positive value greater than 0 and less than 1 that indicates
%       the number of subjects to isolate as test cases. This fraction is
%       calculated per group, so the same number of subjects will be selected
%       per group.
%       nrepsCI -- a whole number that indicates the number of repetitions
%       for calculating accuracy confidence intervals.
%       ntrees -- a whole number that indicates the maximum number of trees
%       that the algorithm will use. Please note that not all forests will
%       have the same number of trees. 
%       nrepsPM -- a whole number that indicates the number of null
%       distribution sets to generate. Setting this value to 0 will disable
%       the permutations.
%       filename -- the prefix for a .mat file that will store the outputs
%       (see below).
%%%%OPTIONAL INPUTS%%%%
%   Each optional input is a string separated by a comma, below are
%   currently available options:
%       'EstimateTree' -- this setting will turn on tree estimation to
%       reduce CPU/RAM usage. When on, the number of trees will be
%       estimated via out of bag error estimation. The final model will
%       then include all training data. If off, the final model will
%       provide out of bag error estimates, but only 2/3 of all data will be used.
%       'WeightForest' -- this setting will turn on weight estimation of the final model using
%       in-sample estimates of accuracy per tree. Weight estimation is the
%       final step before making predictions from the full model.
%
%%%%OUTPUTS:%%%%%
%       accuracy -- a G+1xNrepsCI matrix of accuracy where each row is a
%       group and each column is a random forest. The first row represents
%       the mean accuracy across all groups.
%       permute_accuracy -- a G+1xNrepsCIxNrepsPM matrix of accuracy under
%       the null distribution. Each sheet represents a different
%       permutation of the underlying data.
%       treebag -- a cell matrix containing NrepsCI TreeBagger objects
%       proxmat -- a cell matrix with NrepsCI cells where each cell
%       contains a NxN double matrix, where N represents the number of
%       subjects. If the number of subjects is too large, each cell will
%       contain a sample of the total number.
%       outofbag_error -- a NrepsCIxntrees matrix that represents the out
%       of bag error.
%%%%USAGE:%%%%%
% [accuracy,permute_accuracy,treebag,proxmat,outofbag_error] = ConstructModelTreeBag(group1_data,group2_data,datasplit,nrepsCI,ntrees,nrepsPM,filename,*'EstimateTree'*,'*WeightForest*')
%
%
%See also: TestTreeBags
if exist('group2_data','var')
    if isempty(group2_data)
        group2_data = 0;
    end
else
    group2_data = 0;
end
if isstruct(group1_data)
    group1_data = struct2array(load(group1_data.path,group1_data.variable));
end
if isstruct(group2_data)
    group2_data = struct2array(load(group2_data.path,group2_data.variable));
end
if ischar(group2_data) && strcmp(group2_data,'0')
    group2_data = 0;
end
if ischar(group2_data) && strcmp(group2_data(end-3:end),'.csv')
    loaded_data = importdata(group2_data);
    if size(loaded_data.data,2) > size(loaded_data.textdata,2)
        group2_data = loaded_data.data;
    else
        group2_data = loaded_data.textdata;
    end
    clear loaded_data
end
if ischar(group1_data) && strcmp(group1_data(end-3:end),'.csv')
    loaded_data = importdata(group1_data);
    if size(loaded_data.data,2) > size(loaded_data.textdata,2)
        group1_data = loaded_data.data;
    else
        group1_data = loaded_data.textdata;
    end
    clear loaded_data
end  
holdout = 0;
if exist('proximity_sub_limit','var') == 0
    proximity_sub_limit = 500;
end
if isempty(proximity_sub_limit)
    proximity_sub_limit = 500;
end
regression = 0;
unsupervised = 0;
classification_method='classification';
lowdensity = 0.01;
highdensity = 0.05;
stepdensity = 0.01;
cross_validation = 0;
write_file = logical(1);
data_reduce = 0;
infomapnreps = 200;
use_search_params = 0;
grammpath='/home/faird/shared/code/external/utilities/gramm/';
showmpath='/home/faird/shared/code/internal/utilities/plotting-tools/showM/';
bctpath='/home/faird/shared/code/external/utilities/BCT/BCT/2019_03_03_BCT';
connectedness_thresh = 0.5;
if isempty(varargin) == 0
    for i = 1:size(varargin,2)
        if isstruct(varargin{i}) == 0
            switch(varargin{i})
                case('Holdout')
                    holdout = 1;
                    holdout_data = varargin{i+1};
                case('Regression')
                    regression = 1;
                    classification_method='regression';
                case('unsupervised')
                    unsupervised = 1;
                case('LowDensity')
                    lowdensity = varargin{i+1};
                    if ischar(lowdensity)
                        lowdensity = str2num(lowdensity);
                    end
                case('HighDensity')
                    highdensity = varargin{i+1};
                    if ischar(lowdensity)
                        highdensity = str2num(highdensity);
                    end                    
                case('StepDensity')
                    stepdensity = varargin{i+1};
                    if ischar(stepdensity)
                        stepdensity = str2num(stepdensity);
                    end
                case('CrossValidate')
                    cross_validation = 1;
                case('InfomapFile')
					infomapfile = varargin{i+1};
                case('NoSave')
                    write_file = logical(0);
                case('CommandFile')
                    command_file = varargin{i+1};
                case('DimReduce')
                    data_reduce = true;
                case('GraphReduce')
                    data_reduce = true;
                case('ConnMatReduce')
                    data_reduce = true;
                case('group1_varname')
                    group1_varname = varargin{i+1};
                case('group2_varname')
                    group2_varname = varargin{i+1};
                case('InfomapNreps')
                    infomapnreps = varargin{i+1};
                case('GridSearchDir')
                    gridsearchdir = varargin{i+1};
                    use_search_params = 1;
                case('GrammPath')
                    grammpath = varargin{i+1};
                case('ShowMPath')
                    showmpath = varargin{i+1};    
                case('BCTPath')
                    bctpath=varargin{i+1};
                case('ConnectednessThreshold')
                    connectedness_thresh = varargin{i+1};    
            end
        end
    end
end
if ischar(group1_data) && strcmp(group1_data(end-3:end),'.mat')
    group1_data = struct2array(load(group1_data,group1_varname));
end
if ischar(group2_data) && strcmp(group2_data(end-3:end),'.mat')
    group2_data = struct2array(load(group2_data,group2_varname));
end
if exist('command_file','var') == 0
    warning('command file does not exist, subgroup detection will error at the end...')
else
    if isempty(dir(command_file))
        warning(strcat('error: infomap command not found, command_file variable not valid, subgroup detection will error at the end...',command_file));
    end
end
if exist('infomapfile','var') == 0
    warning('infomap_file does not exist, subgroup detection will error at the end...')
else
    if isempty(dir(infomapfile))
        warning(strcat('error: infomap repo not found, infomapfile variable not valid, subgroup detection will error at the end...',infomapfile));
    end
end
[accuracy,treebag,outofbag_error,proxmat,features,trimmed_features,npredictors,group1class,group2class,outofbag_varimp,final_data,dim_data,final_outcomes,group1predict,group2predict,group1scores,group2scores,group1_data_reduced,group2_data_reduced] = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,varargin{:});
if nrepsPM > 0
    tic
    for i = 1:nrepsPM
        permute_accuracy_temp = CalculateConfidenceIntervalforTreeBagging(group1_data,group2_data,datasplit,ntrees,nrepsCI,proximity_sub_limit,'Permute',varargin{:});               
        if i == 1
            if (holdout)
                permute_accuracy = zeros(size(permute_accuracy_temp,1),nrepsCI,max(size(struct2array(load(holdout_data)))),nrepsPM);
            else
                permute_accuracy = zeros(size(permute_accuracy_temp,1),nrepsCI,nrepsPM);
            end
        end
        if (holdout)
            permute_accuracy(:,:,:,i) = permute_accuracy_temp;
        else
            permute_accuracy(:,:,i) = permute_accuracy_temp;
        end
    end
    toc
else
    permute_accuracy = NaN;
end
if cross_validation
    permute_accuracy = accuracy(:,:,:,2);
    accuracy = accuracy(:,:,:,1);
end
tic
if unsupervised
    proxmat_new = cell(length(proxmat),1);
    nsubs = size(proxmat{1},1)/2;
    for i = 1:length(proxmat)
        proxmat_new{i} = proxmat{i}(1:nsubs,1:nsubs);
    end
    clear proxmat
    proxmat = proxmat_new;
    clear proxmat_new
end
toc
if write_file
    save(strcat(filename,'.mat'),'group1_data_reduced','group2_data_reduced','dim_data','accuracy','permute_accuracy','treebag','proxmat','features','trimmed_features','npredictors','group1class','group2class','outofbag_error','outofbag_varimp','final_data','final_outcomes','group1predict','group2predict','group1scores','group2scores','-v7.3');
    sprintf('%s','Calculating confidence intervals for Treebagging completed! Computing community detection using simple_infomap.py')
    if exist('command_file','var') == 0
        errmsg = 'command_file does not exist, quitting...';
        error('TB:comfilechk',errmsg);
    end
    if exist('infomapfile','var') == 0
        errmsg = 'command_file does not exist, quitting...';
        error('TB:comfilechk',errmsg);
    end    
    if isempty(dir(command_file))
        errmsg = strcat('error: infomap command not found, command_file variable not valid, but unused as of latest code changes...ignoring',command_file);
        warning('TB:comfilechk',errmsg);
    end
    if isempty(dir(infomapfile))
        errmsg = strcat('error: infomap repo not found, infomapfile variable not valid, quitting...',infomapfile);
        error('TB:comfilechk',errmsg);
    end
    if use_search_params
        VisualizeTreeBaggingResults(strcat(filename,'.mat'),strcat(filename,'_output'),classification_method,command_file,'LowDensity',lowdensity,'StepDensity',stepdensity,'HighDensity',highdensity,'InfomapFile',infomapfile,'InfomapNreps',infomapnreps,'GrammPath',grammpath,'ShowMPath',showmpath,'GridSearchDir',gridsearchdir,'BCTPath',bctpath,'ConnectednessThreshold',connectedness_thresh);
    else
        VisualizeTreeBaggingResults(strcat(filename,'.mat'),strcat(filename,'_output'),classification_method,command_file,'LowDensity',lowdensity,'StepDensity',stepdensity,'HighDensity',highdensity,'InfomapFile',infomapfile,'InfomapNreps',infomapnreps,'GrammPath',grammpath,'ShowMPath',showmpath,'BCTPath',bctpath,'ConnectednessThreshold',connectedness_thresh);
    end
end
end