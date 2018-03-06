function [group_data, subject_exclusion_list] = PrepExcelSheetForTreeBagging(excel_file,output_mat,header,string_cols,type,varargin)
%PrepExcelSheetForTreeBagging will produce a matrix with data ready for
%using ConstructModelTreebag
%   USAGE: [group_data, subject_exclusion_list] = 
%   PrepExcelSheetForTreeBagging('/path/to/excel/file.xlsx',...
%   .../path/to/output/file.mat',header,string_cols,type)
%
%   INPUTS:
%           excel_file -- a string that represents the path and full
%           filename for the excel file to read in
%
%           output_mat -- a string that represents the path and full
%           filename for the matlab file to output
%
%           header -- setting this to anything but 0 will remove the first
%           row, useful for when you want to get rid of a header
%
%           string_cols -- a vector of numbers, where each number indicates
%           a column that should be represented as a string (and not as a
%           number)
%
%           type -- a character string; either “surrogate” if missing data 
%           cases are to be included. “no_surrogate” if one wants to exclude 
%           any cases with missing data.
%
%   *OPTIONAL INPUTS*: All optional inputs are paired inputs (each item in
%   the pair is separated by a comma). The first item represents a string
%   naming the parameter, and the second item represents the value of the
%   named parameter.
%
%           'DataName','group_data' -- 'DataName' is the parameter that
%           represents the name of the variable saved in the .mat file. The
%           default is set to 'group_data'.
%
%   OUTPUTS:
%           group_data -- an output cell matrix that contains the data to
%           be used in RFAnalysis.
%
%           subject_exclusion_list -- a numerical array of length N, where 
%           N is the number of subjects. Each item denotes whether the 
%           given row of the original data is excluded (0) or included (1)
% Example:
% PrepExcelSheetForTreeBagging(...
% ...'C:\Users\feczko\Documents\test_data_for_running_RF.xlsx',...
% ...'testing_siemens_data.mat',1,[2 10 11 12],'surrogate')

data_name='group_data';
if exist('type','var') == 0
    type = 'no_surrogate';
end
if exist('header','var') == 0
    header = 0;
else
    if isempty(header)
        header = 0;
    else
        if header == 0
            header = 0;
        else
            header = 1;
        end
    end
end
if isempty(varargin) == 0
    for i = 1:size(varargin,2)
        if isstruct(varargin{i}) == 0
            switch(varargin{i})
                case('DataName')
                    data_name = varargin{i+1};
            end
        end
    end
end
[~,~,rawdata] = xlsread(excel_file);
if (header)
    rawdata = rawdata(2:end,:);
end
switch(type)
    case ('surrogate')
        group_data = cellfun(@ReplaceWhiteWithNaN,rawdata,'UniformOutput',false);
        subject_exclusion_list = NaN;
    case ('no_surrogate')
        subject_exclusion_list = zeros(1,size(rawdata,1));
        temp_data = rawdata;
        count = 0;
        for i = 1:size(temp_data,1);
            notempty = 0;
            if isempty(find(cellfun(@isempty, temp_data(i,:)) == 1))
                if isempty(find(cell2mat((cellfun(@(x) strcmp(' ',x), temp_data(i,:),'UniformOutput',false))) == 1))
                    notempty = 1;
                end
            end               
            if isempty(find(cellfun(@(x) strcmp(char(num2str((x))),'NaN'),temp_data(i,:)) == 1)) && notempty
                count = count + 1;
                subject_exclusion_list(i) = 1;
                group_data(count,:) = temp_data(i,:);                
            end
        end
        subject_exclusion_list = logical(subject_exclusion_list);
end
if nargin > 3 && isempty(string_cols) == 0
    for i = 1:max(size(string_cols))
        group_data(:,string_cols(i)) = cellfun(@num2str,group_data(:,string_cols(i)),'UniformOutput',0);
    end
end
S.(data_name) = group_data;
save(output_mat,'-struct','S');
end


