function [resampled_mat] = Convert3dConnMatTo2dCaseMat(connmat)
%Convert3dConnMatTo2dCaseMat will convert a 3d connectivity symmetric
%matrix to a 2d matrix, excluding all symmetric connections. Rows represent
%cases and columns represent connections. Values cannot be zeros in the
%upper triangular part, but can be negative numbers.
%   Detailed explanation goes here
nsubs = size(connmat,3);
nrois = size(connmat,2);
bin_mask = abs(triu(connmat(:,:,1),1)) > 0;
resampled_mat = zeros(nsubs,nrois*(nrois-1)/2);
for iter = 1:nsubs
    temp_sub = connmat(:,:,iter);
    resampled_mat(iter,:) = temp_sub(bin_mask);
end

end

