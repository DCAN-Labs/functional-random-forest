function [new_value] = ReplaceEmptyWithNaN(value)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
if isempty(value)
    new_value = NaN;
else
    new_value = value;
end

end

