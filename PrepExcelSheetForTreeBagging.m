

function [group_data, subject_exclusion_list] = PrepExcelSheetForTreeBagging(excel_file,output_mat,header,string_cols,type)
%PrepExcelSheetForTreeBagging will produce a matrix with data ready for
%using ConstructModelTreebag
%   USAGE: group_data =
%   PrepExcelSheetForTreeBagging('/path/to/excel/file.xlsx',/path/to/output/file.maccuracyat',header,string_cols)
%
%   INPUTS:
%           excel_file -- a string that represents the path and full/Treebagger/Treebagger_UCI/01_SandmanMatch/UCI_MatchSand_
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
                notempty = 1;
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
save(output_mat,'group_data');
end


