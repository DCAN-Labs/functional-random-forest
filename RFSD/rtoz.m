function [ outmat] = rtoz( inmat )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
outmat = 0.5.*log((1+inmat)./(1-inmat));

end

