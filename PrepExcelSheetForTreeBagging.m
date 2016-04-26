function [group_data] = PrepExcelSheetForTreeBagging(excel_file,output_mat,header,string_cols)
%PrepExcelSheetForTreeBagging will produce a matrix with data ready for
%using ConstructModelTreebag
%   USAGE: group_data =
%   PrepExcelSheetForTreeBagging('/path/to/excel/file.xlsx',/path/to/output/file.mat',header,string_cols)
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
[~,~,rawdata] = xlsread(excel_file);
if (header)
    rawdata = rawdata(2:end,:);
end
group_data = cellfun(@ReplaceWhiteWithNaN,rawdata,'UniformOutput',0);
if nargin > 3
    for i = 1:max(size(string_cols))
        group_data(:,string_cols(i)) = cellfun(@num2str,group_data(:,string_cols(i)),'UniformOutput',0);
    end
end
save(output_mat,'group_data');
end

