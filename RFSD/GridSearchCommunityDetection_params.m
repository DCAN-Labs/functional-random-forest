% N.B. if you are using correlation matrices with non-positive values, one
%   should determine beforehand what is the maximum density that only includes
%   positive values. It would not make sense to go above this in your
%   highdensity parameter below
% N.B. the variable within the .mat file must be a cell array. If you only
%   have a single 2D matrix variable, you should encapsulate it in a 1x1 cell
%   (e.g. corrmat={corrmat}) and resave your .mat file

% path and filename where the correlation/adjacency/proximity matrix is
% stored
corrmatpath='/example_XCCvsUCC.mat';

% the name of the variable within the  .mat file. This should
%   represent a (cell array that contains a) 2D matrix
corrmatvar='proxmat';

% the name of the output directory
output_directory='/home/faird/shared/code/internal/analytics/FRF/GridSearch_example/{OUTPUT}';

% used for community detection -- the lowest edge density to examine
%   community structure, min is the smallest value, max is the highest, and step is the increment for searching

lowdensitymin=0.01;
lowdensitystep=0.01;
lowdensitymax=0.05;

% used for community detection -- the increment value for each edge
%   density examined, see above for "min","max",and,"step" descriptions.

stepdensitymin=0.01;
stepdensitystep=0.01;
stepdensitymax=0.05;

% used for community detection -- highest edge density to examine
%  community structure

highdensitymin=0.05;
highdensitystep=0.01;
highdensitymax=0.2;

% used for community detection -- the lowest edge density to examine
%   community structure

lowdensity={LOWDENSITY};

% used for community detection -- the increment value for each edge
%   density examined

stepdensity={STEPDENSITY};

% used for community detection -- highest edge density to examine
%   community structure

highdensity={HIGHDENSITY};

% used for community detection -- number of infomap iterations
infomap_nreps=25;

% the full path and filename for the Infomap executable, must be installed
%  from http://mapequation.org
infomapfile='/home/faird/shared/code/external/utilities/infomap/Infomap';

% the full path to the repository containing the RFAnalysis code.
repopath='/home/faird/shared/code/internal/analytics/FRF';

% command to run for parameter file
addpath(genpath(repopath))
proxmat_input = struct2array(load(corrmatpath,corrmatvar));
GridSearchCommunityDetection(proxmat_input,output_directory,infomap_nreps,...
    'LowDensity',lowdensity,'StepDensity',stepdensity,'HighDensity',...
    highdensity,'InfomapFile',infomapfile);