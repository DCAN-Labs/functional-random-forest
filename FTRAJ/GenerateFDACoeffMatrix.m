function fdacoeffmat = GenerateFDACoeffMatrix(datamat,agecol,idcol,varargin)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
tic
roundfactor = 0;
norder_data = 6;
norder_err = 3;
nknots = 4;
save_data = 0;
EDA = 0;
timemulti = 5;
time_range = [NaN NaN];
time_range_flex = 0;
piecewise_sampling = 0;
if ischar(datamat)
    if strcmp(datamat(end-3:end),'xlsx')
        datamat = xlsread(datamat);
    elseif strcmp(datamat(end-2:end),'xls')
        datamat = xlsread(datamat);
    elseif strcmp(datamat(end-2:end),'mat')
        datamat = struct2array(load(datamat));
    end
end
datamat(1,1)
if isempty(varargin) == 0
    for i = 1:size(varargin,2)
        if size(varargin{i},1) <= 1
            if ischar(varargin{i})
            switch(varargin{i})
                case('roundfactor')
                    roundfactor = varargin{i+1};
                case('norder_data')
                    norder_data = varargin{i+1};
                case('norder_error')
                    norder_err = varargin{i+1};
                case('number_knots')
                    nknots = varargin{i+1};
                case('save_data')
                    output_file = varargin{i+1};
                    save_data = 1;
                case('EDA')
                    data_rangevector = varargin{i+1};
                    EDA = 1;
                case('time_multiplier')
                    timemulti = varargin{i+1};
                case('time_range')
                    time_range = varargin{i+1};
                case('time_range_flex')
                    time_range_flex = varargin{i+1};
                case('piecewise_sampling')
                    piecewise_sampling = 1;
            end
            end
        end
    end
end
size(datamat)
data_vector = 1:size(datamat,2);
data_vector = data_vector(data_vector ~= idcol);
data_vector = data_vector(data_vector ~= agecol);
count = 0;
if (save_data)
    sparsedatamat = cell(length(data_vector),1);
    timemat = sparsedatamat;
    timebinmat = sparsedatamat;
end
if EDA
	size(data_rangevector,1)
	if length(data_vector) > size(data_rangevector,1)
		for i = 1:length(data_vector)
			data_rangevector(i,1) = data_rangevector(1,1);
			data_rangevector(i,2) = data_rangevector(1,2);
		end
	end
end
if (piecewise_sampling)
    if (save_data)
        for i = data_vector
            i
            count = count + 1;
            [sparsedatamat{count},timemat{count},timebinmat{count},subjects,anchor_subjects] = CreateSparseMatrices(datamat,idcol,agecol,i,roundfactor);
            timebins = unique(timebinmat{count});
            timebins_index = find(isnan(timebins) == 0) + round((norder_data-3)/2);
            timebins = timebins(timebins_index - round((norder_data-3)/2));
            ncoeffs = norder_data+length(timebins)-2;
            if i == data_vector(1)
                functional_data_group = cell(size(sparsedatamat{1},2),length(data_vector));
                functional_data_ind = functional_data_group;
                fdacoeffmat = nan(size(sparsedatamat{1},2),length(data_vector)*ncoeffs);
                subject_use_flag = zeros(size(sparsedatamat{1},2),length(data_vector));
            end
            [functional_data_group(:,count),functional_data_ind(:,count),subject_use_flag(:,count)] = FDAfitMatrix(sparsedatamat{count},timebinmat{count},norder_data,norder_err,'individual',nknots,[],timemulti);
            if EDA
                for subjectnum = 1:size(subject_use_flag,1)
                    if subject_use_flag(subjectnum,count) == 1
                        if min(functional_data_group{subjectnum,count}.datafine) < data_rangevector(count,1) || max(functional_data_group{subjectnum,count}.datafine) > data_rangevector(count,2)
                            subject_use_flag(subjectnum,count) = 0;
                        end
                        if range(functional_data_group{subjectnum,count}.datafine) == 0
                            subject_use_flag(subjectnum,count) = 0;
                        end
                    end
                end
            end
            functional_cellmat = struct2cell(cell2mat(functional_data_group(subject_use_flag(:,count) == 1,count)));
            count_subj = 0;
            for currsubj = 1:size(subject_use_flag,1)
                if subject_use_flag(currsubj,count) == 1
                    count_subj = count_subj + 1;
                    set_vector = ncoeffs*(count-1) + timebins_index(ismember(timebins,functional_cellmat{12,count_subj}));
                    if norder_data > 3
                        prefix_vector = ncoeffs*(count-1) + 1 ;
                        suffix_vector = ncoeffs*(count);            
                        for vector_iteration = 1:floor((norder_data-4)/2)
                            prefix_vector = [prefix_vector ; prefix_vector + vector_iteration];
                            suffix_vector = [suffix_vector - vector_iteration; suffix_vector];
                        end
                        set_vector = [prefix_vector ; set_vector ; suffix_vector];
                    end
                    fdacoeffmat(currsubj,set_vector) = functional_cellmat{10,count_subj};
                end
            end
        end
        save(output_file,'functional_data_group','functional_data_ind','fdacoeffmat','datamat','sparsedatamat','timemat','timebinmat','subject_use_flag','subjects','anchor_subjects');
    else
        for i = data_vector
            count = count + 1;
            [sparsedatamat,~,timebinmat] = CreateSparseMatrices(datamat,idcol,agecol,i,roundfactor,'time_range',time_range,'time_range_flex',time_range_flex);
            timebins = unique(timebinmat);
            timebins_index = find(isnan(timebins) == 0) + round((norder_data-3)/2);
            timebins = timebins(timebins_index - round((norder_data-3)/2));
            ncoeffs = norder_data+length(timebins)-1;
            if i == data_vector(1)
                fdacoeffmat = nan(size(sparsedatamat,2),length(data_vector)*ncoeffs);
            end
            [functional_data_group,~,subject_use_flag] = FDAfitMatrix(sparsedatamat,timebinmat,norder_data,norder_err,'individual',nknots,[],timemulti);
            functional_cellmat = struct2cell(cell2mat(functional_data_group(cellfun(@(x) isempty(x) == 0,functional_data_group))));
            count_subj = 0;
            for currsubj = 1:size(subject_use_flag,1)
                if subject_use_flag(currsubj,count) == 1
                    count_subj = count_subj + 1;
                    set_vector = ncoeffs*(count-1) + timebins_index(ismember(timebins,functional_cellmat{12,count_subj}));
                    if norder_data > 3
                        prefix_vector = ncoeffs*(count-1) + 1 ;
                        suffix_vector = ncoeffs*(count);            
                        for vector_iteration = 1:floor((norder_data-4)/2)
                            prefix_vector = [prefix_vector ; prefix_vector + vector_iteration];
                            suffix_vector = [suffix_vector - vector_iteration; suffix_vector];
                        end
                        set_vector = [prefix_vector ; set_vector ; suffix_vector];
                    end
                    fdacoeffmat(currsubj,set_vector) = functional_cellmat{10,count_subj};
                end
            end
        end
    end
else
    ncoeffs = norder_data+nknots-2;
    if (save_data)
        for i = data_vector
            count = count + 1;
            [sparsedatamat{count},timemat{count},timebinmat{count},subjects,anchor_subjects] = CreateSparseMatrices(datamat,idcol,agecol,i,roundfactor,'time_range',time_range,'time_range_flex',time_range_flex);
            if i == data_vector(1)
                functional_data_group = cell(size(sparsedatamat{1},2),length(data_vector));
                functional_data_ind = functional_data_group;
                fdacoeffmat = nan(size(sparsedatamat{1},2),length(data_vector)*ncoeffs);
                subject_use_flag = zeros(size(sparsedatamat{1},2),length(data_vector));
            end
            [functional_data_group(:,count),functional_data_ind(:,count),subject_use_flag(:,count)] = FDAfitMatrix(sparsedatamat{count},timebinmat{count},norder_data,norder_err,'cardinal',nknots,[],timemulti);
            if EDA
                for subjectnum = 1:size(subject_use_flag,1)
                    if subject_use_flag(subjectnum,count) == 1
                        if min(functional_data_group{subjectnum,count}.datafine) < data_rangevector(count,1) || max(functional_data_group{subjectnum,count}.datafine) > data_rangevector(count,2)
                            subject_use_flag(subjectnum,count) = 0;
                        end
                        if range(functional_data_group{subjectnum,count}.datafine) == 0
                            subject_use_flag(subjectnum,count) = 0;
                        end
                    end
                end
            end
            functional_cellmat = struct2cell(cell2mat(functional_data_group(subject_use_flag(:,count) == 1,count)));
            fdacoeffmat(subject_use_flag(:,count)==1,1+(ncoeffs*(count-1)):ncoeffs*count) = cell2mat(functional_cellmat(10,:)).';
        end
        save(output_file,'functional_data_group','functional_data_ind','fdacoeffmat','datamat','sparsedatamat','timemat','timebinmat','subject_use_flag','subjects','anchor_subjects');
    else
        for i = data_vector
            count = count + 1;
            [sparsedatamat,~,timebinmat] = CreateSparseMatrices(datamat,idcol,agecol,i,roundfactor,'time_range',time_range,'time_range_flex',time_range_flex);
            if i == data_vector(1)
                fdacoeffmat = nan(size(sparsedatamat,2),length(data_vector)*ncoeffs);
            end
            [functional_data_group,~,subject_use_flag] = FDAfitMatrix(sparsedatamat,timebinmat,norder_data,norder_err,'cardinal',nknots,[],timemulti);
            functional_cellmat = struct2cell(cell2mat(functional_data_group(cellfun(@(x) isempty(x) == 0,functional_data_group))));
            fdacoeffmat(subject_use_flag==1,1+(ncoeffs*(count-1)):ncoeffs*count) = cell2mat(functional_cellmat(10,:)).';
        end
    end  
end
toc
end

