# Functional Random Forest (FRF) Manual

This manual documents how to use the RFAnalysis package written by Eric
Feczko. The manual is split into two main sections. The first section
covers how to analyze cross-sectional data with the Random forest
subgroup detection (RFSD) tool. The second covers how to analyze
longitudinal trajectories with the Function Random Forest (FRF) tool. A
brief introduction will walk the user through installing the software.

## Installation

### Getting the package

The FRF code can be found on the github repository (). This repository
is intended for public release as a stable build. For the developmental
builds please contact Eric Feczko (<feczko@ohsu.edu>) or the Fair Lab.
The repository itself can be installed at any location through use of
git:

```bash
git clone https://gitlab.com/feczko/Analysis /destination/path/for/FRF
```

### Dependencies

There are two versions of the FRF, the source version and the compiled
version. The source FRF has two external dependencies:

1)  MATLAB version 2016 or higher

2)  MATLAB Machine learning and statistical toolbox

<!-- end list -->

The compiled FRF has one external dependency:

1)  The MATLAB compiler engine which should be provided by the Fair Lab.

<!-- end list -->
    
Both the source and compiled versions also require that Infomap
(http://mapequation.org) is installed on your system.

### Using the package in the matlab environment

FRF was designed such that an individual does not need to access the
matlab environment to run the data. If one is planning to use any of the
matlab functions themselves, one will need to add the package to the
MATLAB path. After starting matlab type:  

```matlab  
addpath(genpath(‘/destination/path/for/FRF/’))  
```
  
and the matlab functions will be available within a matlab session.

## Random forest subgroup detection (RFSD)

### Preparing your data

#### Generating your data file

The FRF package requires input data represented as a 2D numeric or 2D
cell matrix stored in a .mat format. Each row contains an independent
case and each column contains a feature (e.g. a predictor variable or
the outcome measure). Usually, the source of the input data is external
to matlab and will need to be represented as a variable and stored in
the .mat format. Depending on the type of source, different steps can be
taken to prepare the data properly.

##### Excel

For excel spreadsheets, a function, PrepExcelSheetForTreeBagging can be
used. In a MATLAB environment, add the package to your MATLAB path (see:
“Using the package in the matlab environment” under “Installation”)
type:  

```matlab  
help PrepExcelSheetForTreeBagging  
```
  
for documentation on usage.

On a command line, the PrepExcelSheetForTreeBagging_wrapper.sh can be
used to prepare your data from an excel sheet. The wrapper requires you
to create a parameter file, which can be modified from the existing
PrepExcelSheetForTreeBagging_example.bash file. The contents of the
file are reprinted below. Each parameter precedes its definition; all
definitions are noted by hashmarks, excluding the first line:

```bash
#! /bin/bash

excelfile=/path/to/excelfile/.xls
#path and filename where the excel spreadsheet is located

output_matfile=/path/to/dataset.mat
#the name of the output (.mat) file.

exists_header=0
#if set to anything but 0 or blank, the first row of the excel file is
a header and will be ignored

string_cols=[2 3 4]
#a numeric vector encapsulated by square brackets, where each number
denotes a column that represents a categorical variable, set to 0 if
no such variable exists

type='surrogate'
#sets whether the output contains rows with missing data ('surrogate')
or excludes the rows ('no surrogate')

varname=group_data
#the name of the variable saved to the .mat file

repopath=/destination/path/for/FRF
#the full path to the repository containing the RFAnalysis code.

matlab_command=matlab
#the name of the matlab command line executable, can include arguments
additional options, etc. SingleCompThread is enabled by default.
```

After generating a parameter file, one can prepare their data using the
wrapper. From a bash terminal, one can execute the wrapper on his or her
parameter file:  

```bash  
/path/to/RFAnalysis/PrepExcelSheetForTreeBagging_wrapper.sh
parameterfile.bash
```

The output from PrepExcelSheetForTreebagging will be a .mat file
containing your named variable. Both the variable name and path must be
modified in the ConstructModelTreeBag wrapper below (see: “Running the
analysis”).

##### R

If your data exists within an R data frame, R packages can be used to
export the data frame as a .mat file explicitly (e.g. R.matlab:
<https://cran.r-project.org/web/packages/R.matlab/index.html>). Since
FRF accepts cell or numeric matrices, one can export a data frame as a
cell matrix:  

```R  
writeMat(con=”…filepath”,x=data)  
```
  
or as a numeric matrix:  

```R  
writeMat(con=”…filepath”,x=as.matrix(data))  
```
  
R.matlab also enables one to load outputs into R for inspection (see:
“Stored outputs” under “Interpreting the Outputs”).

##### CSV

CSVs (comma separated value files) can be implicitly handled by the FRF
package. To use a CSV as an input, the following steps have to be taken:

1)  The CSV must be organized as a table (i.e. 2D matrix) with rows
    representing cases and columns representing features.

2)  The delimiter used by the CSV

3)  The CSV cannot contain any header information (i.e. a top row
    depicting the column headers).

4)  Missing or blank cells (see: “How to deal with missing data”) must
    be represented by NaNs.

<!-- end list -->
	
#### How to deal with missing data

Our RF approach can handle missing data via use of “surrogate splits”.
Specifically, when the RF model encounters missing data in the training
data set, it will generate a small RF **from the bootstrapped training
data only** that attempts to fill that missing value. For sets of
cases/variables where data is missing, the actions taken depends on
whether the variable is categorical or continuous. For continuous
variables, one should either the leave the cell blank (unless using
CSVs) or replace all missing values with the value NaN (not a number).
In the case where the variable is categorical, the variable must be left
blank.

Surrogate splits are not a panacea. For example, consider the extreme
situation where 95 percent of cases are missing the given feature. Even
if one could successfully predict the feature value for the 95 percent
of cases using other data, such a relationship would imply that the
feature is derived from other features. Therefore, such a feature would
not contribute anything unique to the model. In our experience, it is
critical for the user to perform exploratory data analysis (EDA) on
their own datasets. **If more than 15 percent of a given case or a given
variable is missing data, one should remove the given case or
variable.** One can toggle whether surrogate splits are used in the
approach by modifying the parameter file (see: “Generating your
parameter file”).

#### Generating your parameter file

The RFSD and FRF package contains wrappers for executing the algorithm
from the command line. Parameter files are used to store the
configuration for the analysis. Below are the parameters available for
running the RFSD using the ConstructModelTreeBag_wrapper.sh. These
parameters can be found in the TreeBagParamFile_example.bash:

```bash
#! /bin/bash

##required inputs

group1path=/path/to/group1_data.mat
#path and filename where group1's data is located, usually the input
data for the RF

group1var=X_CC
#the name of the variable within group1's matrix (.mat) file. This
should represent a 2D matrix

use_group2_data=true
#if set to true, the dataset for the second group will be specified in
a separate file, often used as an independent validation of the model.

group2path=/path/to/group2_data.mat
#path and filename where group2's data is located, generally used for
independent validation

group2var=U_CC
#the name of the variable within group2's matrix (.mat) file

fisher_z_transform=false
#if set to true, the data will be fisher Z transformed before running
the classification algorithm. May be useful when working with 
correlations as inputs (e.g. from a correlation matrix).

repopath=/destination/path/for/FRF
#the full path to the repository containing the RFAnalysis code.

matlab_command=matlab
#the name of the matlab command line executable, can include arguments
additional options, etc. SingleCompThread is enabled by default.

##required outputs and parameters

filename=FRF_study
#the name of the output matrix (.mat) file

disable_treebag=true
#if set to true, the random forests will not be saved. Setting it to
false will require a lot of RAM (~20-40 GB).

proxsublimit_num=500 
#an upper limit to control the size of the proximity matrices. Set 
when you are a) only interested in group 1, and b) the number of cases
in group 2 is too large to hold in RAM.

outcome_variable=false 
#if set to true, the program will look for the outcome variable based
on the preferences set by the user below

outcome_is_struct=true 
#if set to true, the input for the outcome variable will be matrix 
(.mat) files. If set to fa lse, the outcome measure will be acquired 
from the data files themselves.

group1outcome_path='blah' 
#path and filename where group1's outcome measure is located

group1outcome_var='blahvar' 
#the name of the variable that represents group1's outcome in the 
matrix (.mat) file.

group2outcome_path='blah2' 
#path and filename where group2's outcome measure is located

group2outcome_var='blah2var' 
#the name of the variable that represents group2's outcome in the 
matrix (.mat) file.

group1outcome_num=0 
#the column number in group1's data matrix to use as an outcome
measure

group2outcome_num=0 
#the column number in group2's data matrix to use as an outcome
measure

##RF validation procedure options

cross_validate=true 
#if set to true, will perform cross-validation

nfolds=10 
#the number of folds to run under the cross validation procedure

holdout=false 
#if set to true, the data will not be split randomly. Instead, 
a series of subject holdouts will be performed on one of the groups.
Useful when trying to perform classification with families.

holdout_data=/path/to/holdout_matrix.mat 
#the matrix which contains the information for what data is held per
holdout iteration

group_holdout=1 
#which group (group1 or group2) has the data held?

nreps=3 
#the number of iterations to run the random forest algorithm.
Useful for calculating confidience intervals for accuracy and testing
against the null model

nperms=0 
#the number of permutation tests to run if using cross-validation,
permutation is done within the runs.

use_unsupervised=false 
#if set to true, RF algorithm will generate unstructured data,
instead of using group2_data, and use this to validate subgroups 
identified using a supervised approach.

group2_validate_only=false 
#if set to true, group2 will be used as an independent validation 
data set.

##randomized holdout parameters (if cross_validate=false,
use_unsupervised=false,group2_validate_only=false and hold out=false)

datasplit=0.9 
#the proportion of data to use for training the random forest

##RF hyper-parameter options

ntrees=1000 
#the number of trees per random forest iteration; larger numbers 
will require more RAM and processing time

trim_features=false 
#if set to true, the number of features will be trimmed according 
to a KS test for differences between distributions

nfeatures=0 
#the number of features to use when trim_features is turned on

npredictors=false 
#if set to true, the number of predictors (features) per tree can be
specified using num_predictors. Default is 20 features per tree. 
If unset, the default will be the square root of the total number of
features for classification and one third for regression.

num_predictors=0
#the number of predictors (features) per tree

regression=false 
#if set to true, the algorithm will model a regression forest for a
selected outcome variable.

uniform_priors=true 
#if set to true, RF algorithm will assume that the number of cases 
per class are the same in the population (i.e. 50% of the population 
is group1 and 50% is group2). If set to false, RF algorithm will
estimate this probability from the inputs. Only impacts
classification.

matchgroups=false 
#if set to true, the groups will be matched when performing
assessments. Use when uniform_priors s till produces a biased model.
Please note that the model will be constructed with less data.

surrogate=false 
#if set to true, missing data will be approximated using a surrogate
split procedure (Brieman, 1984) . Simply put, an unsupervised
random forest will be modeled to determine the missing data values, a
subsequent random forest will then run on the real and surrogate data.
WARNING missing data may lead to overfitting. Data values that are 
truly independent will not aid in classification, unfortunately.

##RF error estimation options

estimate_predictors=false 
#if set to true, the algorithm will produce out of bag estimates for 
variable importance and error by the number of trees (outofbag_error)

OOB_error=false 
#if set to true the out of bag error will be recorded per run, will 
increase ram and time dramatically

##Legacy options should not be used and are disabled by default

estimate_trees=false 
#if set to true, the random forest algorithm will attempt to estimate
the number of trees to us e for classification per iteration using
out-of-bag classification accuracy for optimization.

weight_trees=false 
#if set to true, the random forest algorithm will weight each tree in 
the random forest by the variance of its within-sample accuracy

estimate_treepred=false 
#if set to true, the algorithm will estimate the number of predictors
per tree

##community detection parameters

lowdensity=0.2 
#used for community detection -- the lowest edge density to examine
community structure

stepdensity=0.05 
#used for community detection -- the increment value for each edge
density examined

highdensity=1 
#used for community detection -- highest edge density to examine community
structure

infomapfile=path/to/infomap/Infomap
#the full path and filename for the Infomap executable, must be
installed from http://mapequation.org
```

### Running the analysis
RFSD allows for multiple different workflows to analyze your data.
The manual will cover two standard and two optional workflows:
1) RFSD analysis
2) RFSD power analysis
3*) Rerun subgroup analysis
4*) Perform community detection on a proximity matrix

#### RFSD analysis
Once you have prepared the parameter file, you can run the RFSD analysis 
using the ConstructModelTreeBag_wrapper.sh command.
```bash
/path/to/RFAnalysis/PrepExcelSheetForTreeBagging_wrapper.sh paramfile.bash
```
The runtime for ConstructModelTreeBag varies by multiple factors.
Individual forests are affected by the complexity of the data, the number
of trees, and model construction parameters like the number of variables
examined per branch. Total runtime is affected by factors like the number
of participants, and the type of validation performed. With OOB turned on
each RF model increases in runtime as the number of subjects increases.
With variable importance turned on, the runtime will increase by the
number of variables.

Currently, we have not performed a rigorous analysis of how each factor
affects runtime. For a 10-fold cross-validation with 3 repetitions on 
1000 trees, the RF validation should take no more than an hour to
complete, if out of bag (OOB) error and variable importance are turned off.
It is recommended to perform a single large model (10 times as many trees)
on one repetition when evaluating OOB error or variable importance; a 
single RF model may take 1-4 hours if these options are enabled.

Subgroup detection runtime depends on the type of classifer, and the
number of edge densities explored, as set by the parameter file. With
the defaults enabled, subgroup detection will take 4 hours on unsupervised
or regression models, and up to 12 hours on supervised classifiation
models.
#### RFSD power analysis
RFSD power analysis requires preparation of the RFSD parameter file. 
Because the power analysis is computationally intensive, we recommended
using a computing cluster to enable parallelization of the simulations.


### Interpreting the outputs
Outputs are stored as .mat files. Although there are multiple intermediate
outputs, only two contain the final outputs from the analysis:
1) filename.mat -- contains relevant outputs from the RF models
2) filename_output/subgroup_community_assignments.mat --  contains relevant outputs from the subgroup
detection
*If a supervised classifier is selected, additional intermediate outputs will
be saved in:
3*) filename_output_groupX/ -- contains relevant outputs from group (class)
number X
#### Stored outputs
Data dictionaries for output files are specified below.
##### filename.mat data dictionary

| variable name    | matlab datatype                   | R datatype            | python datatype      | dimensions | minimum value     | maximum value     | null value     | description                                                                                                                                                                                                                                    |
|------------------|-----------------------------------|-----------------------|----------------------|------------|-------------------|-------------------|----------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| accuracy         | numeric matrix                    | data matrix           | numpy array          | 2-3        | -1                | 1                 | cannot be null | model performance: first dimension reflects statistic type (e.g. group accuracy, total performance, error, or correlation), second dimension reflects repetition/fold index, third dimension reflects repetition index (if CV is enabled).     |
| features         | numeric matrix                    | data matrix           | numpy array          | 1          | 0                 | +inf              | cannot be null | #times each predictor is used                                                                                                                                                                                                                  |
| final_data       | numeric matrix                    | data matrix           | numpy array          | 2          | depends on dataset| depends on dataset           | cannot be null | data excluding the outcome variable, can be used with "subgroup_community_assignments" to evaluate features used                                                                                                                                                                                                                  |
| final_outcomes   | numeric matrix                    | data matrix           | numpy array          | 1          | depends on dataset| depends on dataset           | cannot be null | outcome_variable, can be used with "subgroup_community_assignments" to evaluate outcomes by subgroup                                                                                                                                                                                                              |
| features         | numeric matrix                    | data matrix           | numpy array          | 1          | 0                 | +inf              | cannot be null | #times each predictor is used                                                                                                                                                                                                                  |
| group1class      | numeric matrix                    | data matrix           | numpy array          | 1          | -1                | 1                 | cannot be null | individual performance for first dataset                                                                                                                                                                                                       |
| group1predict    | numeric matrix                    | data matrix           | numpy array          | 1          | outcome dependent | outcome dependent | cannot be null | model prediction for first dataset                                                                                                                                                                                                             |
| group1scores     | numeric matrix                    | data matrix           | numpy array          | 1          | outcome dependent | outcome dependent | cannot be null | model score for first dataset                                                                                                                                                                                                                  |
| group2class      | numeric matrix                    | data matrix           | numpy array          | 1          | -1                | 1                 | NaN            | individual performance for second dataset                                                                                                                                                                                                      |
| group2predict    | numeric matrix                    | data matrix           | numpy array          | 1          | outcome dependent | outcome dependent | NaN            | model prediction for second dataset                                                                                                                                                                                                            |
| group2scores     | numeric matrix                    | data matrix           | numpy array          | 1          | outcome dependent | outcome dependent | NaN            | model score for second dataset                                                                                                                                                                                                                 |
| npredictors      | numeric                           | int32                 | int32                | scalar     | 1                 | # of features     | NaN            | number of predictors used to grow each branch                                                                                                                                                                                                  |
| outofbag_error   | numeric matrix                    | data matrix           | numpy array          | 2          | 0                 | 1                 | NaN            | Cumulative OOB error: first dimension reflects repetition index, second dimension reflects # of trees                                                                                                                                          |
| outofbag_varimp  | numeric matrix                    | data matrix           | numpy array          | 2          | -1                | 1                 | NaN            | OOB measured variable importance: first dimension reflects repetition index, second dimension reflects feature index                                                                                                                           |
| permute_accuracy | numeric matrix                    | data matrix           | numpy array          | 2-3        | -1                | 1                 | NaN            | Null model performance. See "accuracy" for format.                                                                                                                                                                                             |
| proxmat          | cell matrix                       | list of data matrices | list of numpy arrays | 1          | 0                 | 1                 | cannot be null | NxN proximity matrices generated from the RF, one per forest is saved to limit space. N refers to the number of subjects. If group2_validate_only is set to true, then the proximity matrix will only reflect the independent testing dataset. |
| treebag          | cell matrix containing RF objects | N/A                   | N/A                  | 1          | N/A               | N/A               | NaN            | this variable contains each model generated from the RF validation. The size of the matrix depends on the number of forests generated. Each model is stored as a TreeBagger class object, and cannot be loaded yet in R or python.             |
| trimmed_features | numeric_matrix                    | data matrix           | numpy array          | 2-3        | 1                 | # of features     | NaN            | If features were trimmed using the legacy "estimate_features" option, this variable contains an index of which features were used. We do not advise using this feature.                                                                        |
#####filename_output/subgroup_community_assignments.mat data dictionary

| variable name                  | matlab datatype | R datatype            | python datatype      | dimensions | minimum value | maximum value | null value     | description                                                                                                                                                                                                                                              |
|--------------------------------|-----------------|-----------------------|----------------------|------------|---------------|---------------|----------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| community_subgroup_performance | cell matrix     | list of lists         | list of numpy arrays | 1          | -1            | 1             | cannot be null | Contains the model performance for each individual, split first by class, then by subgroup within class. Each subgroup list contains a matrix of number reflecting performance. Mean absolute error is used for regression, accuracy for classification. |
| subgroup_community_assignments | cell matrix     | list                  | list                 | 1          | G1_1          | GX_Xs         | cannot be null | list of subgroups identified by the RFSD, X refers to the class, Xs refers to the subgroup within the class                                                                                                                                              |
| subgroup_community_num         | numeric matrix  | data matrix           | numpy array          | 2          | 1             | +inf          | cannot be null | numeric representation of subgroup_community_assignments: first column represents the class index, second column represents the subgroup index for that subject                                                                                          |
| subgroup_communities           | cell matrix     | list of data matrices | list of numpy arrays | 1          | 1             | +inf          | cannot be null | list of subgroup communities for each class                                                                                                                                                                                                              |
| subgroup_sorting_orders        | cell matrix     | list of data matrices | list of numpy arrays | 1          | 1             | # of cases    | cannot be null | list of order of subjects in the other variables split by subgroup, can be used to query "filename_output.mat"                                                                                                                                           |
| proxmat_subgroup_sorted        | numeric_matrix  | data matrix           | numpy array          | 2          | 0             | 1             | cannot be null | The mean proximity matrix (NxN where N is the number of cases) sorted first by class and then by subgroup.                                                                                                                                               |
Data dictionaries will be expanded for non-critical outputs in 
upcoming releases. Please contact the development team via github
for questions and requests. 

#### Loading outputs in R

#### Converting outputs to text

#### Data visualizations

#### Guide to determine community detection parameters

#### Post-hoc strategies for validating subgroups

## Functional Random Forest (FRF)

### Preparing your data

#### Generating your data file

#### How to deal with wave/non-anchored data

#### Generating your parameter file

#### How to determine optimal function parameters

### Running the analysis

#### Correlation trajectory approach

#### Random forest approach

### Interpreting the outputs

#### Stored outputs

#### Data visualizations

#### Post-hoc strategies for validating subgroups
