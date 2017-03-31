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
if ischar(datamat)
    datamat = xlsread(datamat);
end
if isempty(varargin) == 0
    for i = 1:size(varargin,2)
        if size(varargin{i},1) <= 1 && isstr(varargin{i})
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
                    output_file = varargin{i+1}
                    save_data = 1;
                case('EDA')
                    data_rangevector = varargin{i+1};
                    EDA = 1;
            end
        end
    end
end
data_vector = 1:size(datamat,2);
data_vector = data_vector(data_vector ~= idcol);
data_vector = data_vector(data_vector ~= agecol);
count = 0;
ncoeffs = norder_data+nknots-2;
if (save_data)
    sparsedatamat = cell(length(data_vector),1);
    timemat = sparsedatamat;
    timebinmat = sparsedatamat;
end
if (save_data)
    for i = data_vector
        count = count + 1;
        [sparsedatamat{count},timemat{count},timebinmat{count},subjects] = CreateSparseMatrices(datamat,idcol,agecol,i,roundfactor);
        if i == data_vector(1)
            functional_data_group = cell(size(sparsedatamat{1},2),length(data_vector));
            functional_data_ind = functional_data_group;
            fdacoeffmat = nan(size(sparsedatamat{1},2),length(data_vector)*ncoeffs);
            subject_use_flag = zeros(size(sparsedatamat{1},2),length(data_vector));
        end
        [functional_data_group(:,count),functional_data_ind(:,count),subject_use_flag(:,count)] = FDAfitMatrix(sparsedatamat{count},timebinmat{count},norder_data,norder_err,'cardinal',nknots);
        if EDA
            for subjectnum = 1:size(subject_use_flag,1)
                if subject_use_flag(subjectnum,count) == 1
                    if min(functional_data_group{subjectnum,count}.datafine) < data_rangevector(count,1) || max(functional_data_group{subjectnum,count}.datafine) > data_rangevector(count,2)
                        subject_use_flag(subjectnum,count) = 0;
                    end
                end
            end
        end
        functional_cellmat = struct2cell(cell2mat(functional_data_group(subject_use_flag(:,count) == 1,count)));
        fdacoeffmat(subject_use_flag(:,count)==1,1+(ncoeffs*(count-1)):ncoeffs*count) = cell2mat(functional_cellmat(10,:)).';
    end
    save(output_file,'functional_data_group','functional_data_ind','fdacoeffmat','datamat','sparsedatamat','timemat','timebinmat','subject_use_flag','subjects');
else
    for i = data_vector
        count = count + 1;
        [sparsedatamat,~,timebinmat] = CreateSparseMatrices(datamat,idcol,agecol,i,roundfactor);
        if i == data_vector(1)
            fdacoeffmat = nan(size(sparsedatamat,2),length(data_vector)*ncoeffs);
        end
        [functional_data_group,~,subject_use_flag] = FDAfitMatrix(sparsedatamat,timebinmat,norder_data,norder_err,'cardinal',nknots);
        functional_cellmat = struct2cell(cell2mat(functional_data_group(cellfun(@(x) isempty(x) == 0,functional_data_group))));
        fdacoeffmat(subject_use_flag==1,1+(ncoeffs*(count-1)):ncoeffs*count) = cell2mat(functional_cellmat(10,:)).';
    end
end    
toc
end

