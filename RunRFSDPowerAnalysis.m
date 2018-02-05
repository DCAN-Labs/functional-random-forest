function [ observed_performance,null_performance,sample_size,statistical_power,false_positive,performance_thresholds] = RunRFSDPowerAnalysis(varargin)
%RUNRFSDPowerAnalysis will perform a power analysis on the Random Forest
%subgroup detector (RFSD) algorithm.
%   Detailed explanation goes here
filename='thenamelessone';
categorical_vector = 0;
sample_size = 1;
group_column = 0;
ngroups = 0;
data_range = 0;
performance_thresholds = 0.7;
forest_type = 'classification';
learning_type = 'supervised';
parallel_processing = false;
numpools = 2;
nsims = 10;
outcol = 1;
infomapfile='/group_shares/fnl/bulk/code/external/infomap/Infomap';
commandfile = '/group_shares/fnl/bulk/code/internal/utilities/simple_infomap/simple_infomap.py';
for i = 1:size(varargin,2)
    if ischar(varargin{i})
        if isstruct(varargin{i}) == 0
            switch(varargin{i})
                case('InputData')
                    input_data = varargin{i+1};
                    if isstruct(input_data)
                        input_data_struct = input_data;
                        input_data = struct2array(input_data_struct.path,input_data_struct.variable);
                    end
                case('GroupBy')
                    group_column = varargin{i+1};
                    if isstruct(group_column)
                        group_column_struct = group_column;
                        group_column = struct2array(group_column_struct.path,group_column_struct.variable);
                    end
                    ngroups = length(unique(group_column));
                case('Categorical')
                    categorical_vector = varargin{i+1};
                case('NumSimCases')
                    sample_size = varargin{i+1};
                case('DataRange')
                    data_range = varargin{i+1};
                case('OutputDirectory')
                    filename = varargin{i+1};
                case('PerformanceThresholds')
                    performance_thresholds = varargin{i+1};
                case('ForestType')
                    forest_type = varargin{i+1};
                case('NumCores')
                    numpools = varargin{i+1};
                    if numpools > 1
                        parallel_processing = true;
                    end
                case('LearningType')
                    learning_type = varargin{i+1};
                case('NumSimulations')
                    nsims = varargin{i+1};
                case('OutcomeColumnForRegression')
                    outcol = varargin{i+1};
                case('InfomapFile')
                    infomapfile = varargin{i+1};
                case('CommandFile')
                    commandfile = varargin{i+1};
            end
        end
    end
end
%load pool
if parallel_processing
    cluster_env = parcluster();
    processingpool = parpool(cluster_env,numpools);
end
%declare outputs for RFSD simulations
if strcmp(forest_type,'Regression')
    observed_performance = zeros(2,nsims);
    statistical_power = zeros(2,length(performance_thresholds));
else
    observed_performance = zeros(ngroups+1,nsims);
    statistical_power = zeros(ngroups+1,length(performance_thresholds));    
end
if strcmp(learning_type,'unsupervised')
    observed_performance = zeros(1,length(performance_thresholds));
    statistical_power = zeros(1,length(performance_thresholds));
end
null_performance = observed_performance;
false_positive = statistical_power;
%run a PARFOR loop on the simulations
parfor curr_sim = 1:nsims
    [observed_performance(:,curr_sim),null_performance(:,curr_sim)] = PerformRFSDSimulations('InputData',input_data,'GroupBy',group_column,'Categorical',categorical_vector,'NumSimCases',sample_size,'DataRange',data_range,'ForestType',forest_type,'LearningType',learning_type,'OutcomeColumnForRegression',outcol,'InfomapFile',infomapfile,'CommandFile',commandfile);
end
%close the pool all other operations only need one core after
if parallel_processing
    delete(processingpool);
end
%if multiple thresholds were selected, let us calculate power over the
%range
for curr_thresh = 1:length(performance_thresholds)
%now that we have performance metrics, let us calculate observed power as
%the percentage of H=1 tests confirmed as H=1 divided by the total H
    statistical_power(:,curr_thresh) = sum(observed_performance >= performance_thresholds(curr_thresh),2)/nsims;
%now let us calculate the false positive rate as the percentage of H=0
%tests found to be H=1 divided by the total H
    false_positive(:,curr_thresh) = sum(null_performance >= performance_thresholds(curr_thresh),2)/nsims;
end
save(strcat(filename,'.mat'),'statistical_power','observed_performance','null_performance','sample_size','false_positive','performance_thresholds');
end

