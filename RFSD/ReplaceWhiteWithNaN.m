function [new_value] = ReplaceWhiteWithNaN(value)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
if strcmp(value,' ')
    new_value = NaN;
else
    new_value = value;
end

end

