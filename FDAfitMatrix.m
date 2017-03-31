function [ functional_data_group, functional_data_ind, subject_use_flag] = FDAfitMatrix(datamat,timemat,splinestructdata_norder,splinestructerr_norder,matrix_type,nsteps,filename)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
[max_timepoints,nsubjects]=size(datamat);
functional_data_ind = cell(nsubjects,1);
functional_data_group = cell(nsubjects,1);
subject_use_flag = ones(nsubjects,1);
if exist('nsteps','var') == 0
    nsteps = 5;
end
if strcmp(matrix_type,'cardinal')
    time_range = [min(min(timemat)) max(max(timemat))];
    splinestruct_data.knots = time_range(1):(time_range(2)-time_range(1))/(nsteps-1):time_range(2);
    splinestruct_data.norder = splinestructdata_norder;
    splinestruct_data.nbasis = length(splinestruct_data.knots)+splinestruct_data.norder-2;
end
for i = 1:nsubjects
    timevector_temp = timemat(isnan(datamat(:,i))==0,i);
    datavector_temp = datamat(isnan(datamat(:,i))==0,i);
    if strcmp(matrix_type,'individual')
        splinestruct_data.knots = timevector_temp;
        splinestruct_data.norder = splinestructdata_norder;
        splinestruct_data.nbasis = length(splinestruct_data.knots)+splinestruct_data.norder-2;
    end
    try
        FDAfit(datavector_temp,timevector_temp,splinestruct_data,'simple');
    catch
        sprintf(strcat('Subject #',num2str(i),': cannot be estimated'))
        subject_use_flag(i) = 0;
    end
end
datamat_new_temp = datamat(:,subject_use_flag==1);
timemat_new_temp = timemat(:,subject_use_flag==1);
count_timepoint = 1;
for i = 1:max_timepoints
    if length(find(isnan(datamat_new_temp(i,:))==0)) > 0
       datamat_new(count_timepoint,:) = datamat_new_temp(i,:);
       timemat_new(count_timepoint,:) = timemat_new_temp(i,:);
       count_timepoint = count_timepoint + 1;
    end
end
count_subject = 1;
residmat = nan(count_timepoint-1,nsubjects);
for i = 1:nsubjects
    if subject_use_flag(i)
        timevector_temp = timemat_new(isnan(datamat_new(:,count_subject))==0,count_subject);
        datavector_temp = datamat_new(isnan(datamat_new(:,count_subject))==0,count_subject);
        if strcmp(matrix_type,'individual')
            splinestruct_data.knots = timevector_temp;
            splinestruct_data.norder = splinestructdata_norder;
            splinestruct_data.nbasis = length(splinestruct_data.knots)+splinestruct_data.norder-2;
        end
        functional_data_ind{i} = FDAfit(datavector_temp,timevector_temp,splinestruct_data,'simple');
        residmat(isnan(datamat_new(:,count_subject))==0,count_subject) = functional_data_ind{i}.residuals.^2;
        count_subject = count_subject + 1;
    else
        functional_data_ind{i} = [];
    end
end
%calculate mean squared resiudals for timepoints
rmsq_vector = mean(residmat,2,'omitnan');
% set up smoothing function
rng = [min(min(timemat_new)),max(max(timemat_new))];
stderrbasis_functions = create_bspline_basis(rng,size(min(timemat_new,[],2),1)+splinestructerr_norder-2,splinestructerr_norder,min(timemat_new,[],2));
functional_data_initial_weight = fd(zeros(size(min(timemat_new,[],2),1)+splinestructerr_norder-2,1),stderrbasis_functions);
% smooth the mean squared residuals
L_functional_data_object = 1;
lambda = 1e-3;
functional_data_errorpar=fdPar(functional_data_initial_weight,L_functional_data_object,lambda);
functional_data_weight=smooth_pos(min(timemat_new,[],2),rmsq_vector,functional_data_errorpar);
%compute varirance and standard error of data
data_error_variance = eval_pos(min(timemat_new,[],2),functional_data_weight);
%update weight vector
weight_vector = 1./data_error_variance;
weight_vector = weight_vector./mean(weight_vector);
%use weight vector to resmooth the data above
lambda = 1e-2;
count_subject = 1;
for i = 1:nsubjects
    if subject_use_flag(i)
        try
            timevector_temp = timemat_new(isnan(datamat_new(:,count_subject))==0,count_subject);
            datavector_temp = datamat_new(isnan(datamat_new(:,count_subject))==0,count_subject);
            if strcmp(matrix_type,'individual')    
                splinestruct_data.knots = timevector_temp;
                splinestruct_data.norder = splinestructdata_norder;
                splinestruct_data.nbasis = length(splinestruct_data.knots)+splinestruct_data.norder-2;
            end
                weight_vector_temp = weight_vector(isnan(datamat_new(:,count_subject))==0);
                functional_data_group{i} = FDAfit(datavector_temp,timevector_temp,splinestruct_data,'simple',lambda,[],weight_vector_temp);
        catch
            sprintf(strcat('cannot estimate subject #',num2str(i)))
            functional_data_group{i} = [];
            subject_use_flag(i) = 0;
        end
            count_subject = count_subject + 1;
    else
        functional_data_group{i} = [];
    end
end
if exist('filename','var')
    save(filename,functional_data_group, functional_data_ind, subject_use_flag);
end
end
