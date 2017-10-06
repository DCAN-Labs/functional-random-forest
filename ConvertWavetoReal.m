function [datamat] = ConvertWavetoReal(xlsfile,id_col,gender_col,age_cols,data_perage_cols,outputfilename)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
[~,~,rawdata] = xlsread(xlsfile);
numeric_data_mat = cell2mat(rawdata(2:end,:));
header = rawdata(1,:);
nsubs = size(numeric_data_mat,1);
datamat = zeros(nsubs*length(age_cols),3+data_perage_cols);
rawdatamat = cell(1+(nsubs*length(age_cols)),3+data_perage_cols);
index = 1;
for i = 1:nsubs
    datamat(index:index-1+length(age_cols),1) = numeric_data_mat(i,id_col);
    datamat(index:index-1+length(age_cols),2) = numeric_data_mat(i,gender_col);
    datamat(index:index-1+length(age_cols),3) = numeric_data_mat(i,age_cols);
    for j = 1:length(age_cols)
        datamat(index+j-1,4:3+data_perage_cols) = numeric_data_mat(i,3+length(age_cols)+((j-1)*data_perage_cols):2+length(age_cols)+(j*data_perage_cols));
    end
    index = index + length(age_cols);
end
rawdatamat(1,:) = header([id_col gender_col 3 length(age_cols)+3:length(age_cols)+2+data_perage_cols]);
rawdatamat(2:end,:) = num2cell(datamat);
try
xlswrite(outputfilename,rawdatamat);
catch
    sprintf('error: could not write file');
end
end

