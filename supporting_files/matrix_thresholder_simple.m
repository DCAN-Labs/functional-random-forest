function [indices,mask] = matrix_thresholder_simple(matrix,threshold)
%i = matrix_thresholder_simple(matrix,threshold)
%
% This script takes a 2D matrix and thresholds it at a given edge density,
% and returns the indices of the upper triangle of the original matrix that
% survive the threshold, in descending order by their original matrix
% value.
%
% NOTE:
% This script presumes an undirected (symmetric) matrix !!!!
% 
% It also ignores values on the diagonal (should be zero anyways) !!!!
% EMG 06/26/15
% DAF update to exlclude NaNs 12/29/17

d=size(matrix);
if size(d,1)>2
    error('Matrix_thresholder only works on 2D matrices (with reason!)');
end

numpossibleedges=d(1)*(d(1)-1)/2;


mask = true(size(matrix)); % Making a mask of all 1's to use later?
mask = triu(mask,1); % taking the upper triangle of the mask matrix
matrix_triu = matrix(mask); % applying the mask upper triangle to the matrix? Upper = mask, lower = values?
matrix_triu(isnan(matrix_triu))=-1;% DF Addition so that NaNs are not included in the top threshold values
[~, indices]=sort(matrix_triu(:),'descend'); % taking just the indices of the matrix with values and masked 1's? - does ~ dump the first variable?
indices = indices(1:(round(threshold*numpossibleedges)));
mask_matrix_triu = false(size(matrix_triu));
mask_matrix_triu(indices) = 1;
mask(mask) = mask_matrix_triu;
indices = find(mask);
[~,order] = sort(matrix(indices),'descend');
indices = indices(order);
mask=double(mask);




