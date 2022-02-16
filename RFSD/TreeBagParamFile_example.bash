#!/bin/bash

# =====================
# == required inputs
# =====================
# path and filename where group1's data is located
group1path=./ExcelExampleOutput.mat

# the name of the variable within group1's matrix (.mat) file. This
#   should represent a 2D matrix
group1var=group_data

# if set to true, the dataset for the second group will be specified
#   in a separate file, if set to false, the first group's dataset will
#   be randomly split into two groups. Set to false when doing regression
use_group2_data=false
    # path and filename where group2's data is located
    group2path=./ExcelExampleOutput.mat
    # the name of the variable within group2's matrix (.mat) file
    group2var=group_data

# if set to true, the data will be fisher Z transformed before running
#   the classification algorithm. May be useful when working with
#   correlations as inputs (e.g. from a correlation matrix)
fisher_z_transform=false

# the full path to the repository containing the RFAnalysis code.
repopath=/mnt/max/home/robinsph/git/Analysis/RFSD

# the name of the matlab command line executable, can include arguments
#   additional options, etc. SingleCompThread is enabled by default.
matlab_command=matlab

# if set to true, the program will look for the outcome variable based
#   on the preferences of set by the user
outcome_variable=true
    # the column number in group1's data matrix to use as an outcome measure
    group1outcome_num=1
    # the column number in group2's data matrix to use as an outcome measure
    group2outcome_num=0

# if set to true, the input for the outcome variable will be matrix (.mat)
#   files. If set to false, the outcome measure will be acquired from the
#   data files themselves.
outcome_is_struct=false
    # path and filename where group1's outcome measure is located
    group1outcome_path='blah'
    # the name of the variable that represents group1's outcome in the
    #   matrix (.mat) file.
    group1outcome_var='blahvar'
    # path and filename where group2's outcome measure is located
    group2outcome_path='blah2'
    # the name of the variable that represents group2's outcome in the
    #   matrix (.mat) file.
    group2outcome_var='blah2var'

# =====================
# == required outputs and parameters
# =====================
#the name of the output matrix (.mat) file
filename=example_XCCvsUCC
# if set to true, the random forests will not be saved. Setting it to
#   false will require a lot of RAM (~20-40 GB).
disable_treebag=true
# an upper limit to control the size of the proximity matrices. Set when
#   you are a) only interested in group 1, and b) the number of cases in
#   group 2 is too large to hold in RAM.
proxsublimit_num=500

# =====================
# == connectivity matrix reduction options
# =====================
#if set to true, connectivity matrices are the assumed input and will
#be converted to 2d matrices, excluding symmetric connections 
#If set to false, this will be ignored.
connmat_reduce=false

# =====================
# == dimensionality reduction options
# =====================
#if set to true, dimensionality reduction will be performed on training
# and testing datasets separately. If set to false, other options can
# be ignored
dim_reduce=false
#the type of dimensionality reduction, current options supported: PCA
dim_type='PCA'
#the number of components, used by: PCA
num_components=1
#the path to the .mat file that contains the modules for dimensionality reduction
modpath='/this/mod.mat'
#the variable name within the .mat file that contains the modules for dimensionality reduction
modvar='modulevariable'

# =====================
# == graph reduction options
# =====================
#if set to true, dimensionality reduction will be performed using graph theory
#because this operates on each individual subject, reduction will be performed
#prior to any further steps
graph_reduce=false
#the path to the .mat file that contains the systems for calculating participation coefficient
systempath='/this/system.mat'
#the variable name within the systems.mat file for calculating participation coefficient
systemvar='systems'
#the edge density to use for thresholding -- for Evan Gordon's 353 ROIs, a lattice 
#network would have 2.841 percent edge density
edgedensity=0.03
#the path to the .mat file that contains the modules for dimensionality reduction
grphmodpath='/this/mod.mat'
#the variable name within the .mat file that contains the modules for dimensionality reduction
grphmodvar='modulevariable'
#the path to the brain connectivity toolbox for performing graph extraction
bctpath='/this/bct/path'

# =====================
# == RF validation procedure options
# =====================
# if set to true, will perform cross-validation
cross_validate=true
    # the number of folds to run under the cross validation procedure
    nfolds=3

# if set to true, the data will not be split according to datasplit.
#   Instead, a series of subject holdouts will be performed on one of the
#   groups. Useful when trying to perform classification with families.
holdout=false
    # the matrix which contains the information for what data is held per
    #    holdout iteration
    holdout_data=/group_shares/FAIR_LAB2/Projects/FAIR_users/Feczko/projects/Long_ADHD_OHSU/families_CC_ix_1_to_23.mat
    # which group (group1 or group2) has the data held?
    group_holdout=1

# the number of iterations to run the random forest algorithm. Useful for
#   calculating confidience intervals for accuracy and testing against the
#   null model
nreps=3

# the number of permutation tests to run if using cross-validation,
#   permutation is done within the runs
nperms=0

# use_unsupervised
# if set to true, RF algorithm will generated unstructured data instead
#   of using group2_data, use this to validate subgroups identified using
#   a supervised approach
# group2_validate_only
# if set to true, and regression is enabled, group2 will be used as an
#   independent validation data set. Use the holdouts group if you want
#   to specify an independent dataset for classification
use_unsupervised=false; group2_validate_only=false
    # randomized holdout parameters
    #   (if cross_validate=false,
    #       use_unsupervised=false,
    #       group2_validate_only=false,
    #       and holdout=false)
    # the proportion of data to use for training the random forest
    datasplit=0.9

# =====================
# == RF hyper-parameter options
# =====================
# the number of trees per random forest iteration; larger numbers will
#   require more RAM and processing time
ntrees=100
# if set to true, the number of features will be trimmed according to a
#   KS test for differences between distributions
trim_features=false
    # the number of features to use when trim_features is turned on
    nfeatures=0

# if set to true, the number of predictors (features) per tree can be
#   specified using num_predictors. Default is 20 features per tree. If
#   unset, the default will be the square root of the total number of
#   features for classification and one third for regression.
npredictors=false
    num_predictors=0 #the number of predictors (features) per tree

# if set to true, the algorithm will model a regression forest for a
#   selected outcome variable. When performing regression, please make
#   sure to set outcome_variable to "true".
regression=false

# if set to true, RF algorithm will assume that the number of cases per
#   class are the same in the population (i.e. 50% of the population is
#   group1 and 50% is group2). If set to false, RF algorithm will estimate
#   this probability from the inputs. Only impacts classification.
uniform_priors=true

# if set to true, the groups will be matched when performing assessments.
#   Use when uniform_priors still produces a biased model. Please note
#   that the model will be constructed with less data.
matchgroups=false

# if set to true, missing data will be approximated using Brieman's
#   surrogate split procedure. Simply put, an unsupervised random forest
#   will be modeled to determine the missing data values, a subsequent
#   random forest will then run on the real and surrogate data. WARNING
#   missing data may lead to overfitting. Data values that are truly
#   independent will not aid in classification, unfortunately.
surrogate=false

# =====================
# == RF error estimation options
# =====================
# if set to true, the algorithm will produce out of bag estimates for
#   variable importance and error by the number of trees (outofbag_error)
estimate_predictors=false

# if set to true the out of bag error will be recorded per run, will increase
#   ram and time dramatically
OOB_error=false

# =====================
# == Visualization options
# =====================

# set to the path where the matlab gramm toolbox is located
gramm_path=/home/faird/shared/code/external/utilities/gramm/

#set to the path where Oscar's showm toolbox is located
showm_path=/home/faird/shared/code/internal/utilities/plotting-tools/showM/

# =====================
# == Legacy options should not be used and are disabled by default
# =====================
# if set to true, the random forest algorithm will attempt to estimate the
#   number of trees to use for classification per iteration using out-of-bag
#   classification accuracy for optimization.
estimate_trees=false

# if set to true, the random forest algorithm will weight each tree in the
#   random forest by the variance of its within-sample accuracy
weight_trees=false

# if set to true, the algorithm will estimate the number of predictors per tree
estimate_treepred=false

# =====================
# == community detection parameters
# =====================
# used for community detection -- the lowest edge density to examine community structure
lowdensity=0.4

# used for community detection -- the increment value for each edge density examined
stepdensity=0.6

# used for community detection -- highest edge density to examine community structure
highdensity=1

# used for community detection -- the number of iterations to run infomap per edge density
infomap_nreps=10

# the full path and filename for the Infomap executable, must be installed
#   from http://mapequation.org
infomapfile=/mnt/max/home/robinsph/git/infomap/Infomap

# The full path and filename of simple_infomap.py
infomap_command_file=/mnt/max/home/robinsph/git/Analysis/simple_infomap/simple_infomap.py

# if a gridsearch has been run, set this flag to 1
use_gridsearch=true
  #set this path to the gridsearch parent directory
gridsearch=/path/to/gridsearch
#set this path to the Brain Connectivity Toolbox
bct_path=/home/faird/shared/code/external/utilities/BCT/BCT/2019_03_03_BCT
#choose the graph connectedness threshold
connectedness_thresh=0.7

