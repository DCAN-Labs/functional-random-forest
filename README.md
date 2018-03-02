# Functional Random Forest (FRF) Manual

This manual documents how to use the RFAnalysis package written by Eric
Feczko. The manual is split into two main sections. The first section
covers how to analyze cross-sectional data with the Random forest
subgroup detection (RFSD) tool. The second covers how to analyze
longitudinal trajectories with the Function Random Forest (FRF) tool. A
brief introduction will walk the user through installing the software.

## Installation

### Getting the package

The FRF code can be found on the github
[repository](https://github.com/DCAN-Labs/functional-random-forest).
This repository
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
matlab IDE to run the data. If one is planning to use any of the
matlab functions themselves, one will need to add the package to the
MATLAB path. After starting matlab type:

```matlab
addpath(genpath('/destination/path/for/Repository/'))
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

It is important to note that empty cells in your data set are expected to 
be represented by `NaN`s before being passed into the `RFSD` algorithm.
If you have empty cells, or cells with only whitespace, in an excel spreadsheet,
the provided function `PrepExcelSheetForTreeBagging` will create a matlab struct
with correctly formatted data.

##### Excel

For excel spreadsheets, a function, PrepExcelSheetForTreeBagging can be
used. In a MATLAB environment, add the package to your MATLAB path (see:
“Using the package in the matlab environment" under “Installation")
type:

```matlab
help PrepExcelSheetForTreeBagging
```

for documentation on usage.

On a command line, the PrepExcelSheetForTreeBagging_wrapper.sh can be
used to prepare your data from an excel sheet. The wrapper requires you
to create a parameter file, which can be modified from the existing
`PrepExcelSheetForTreeBagging_example.bash` file. The contents of the
file are reprinted below. Each parameter precedes its definition; all
definitions are noted by hashmarks, excluding the first line:

```bash
#!/bin/bash

# path and filename where the excel spreadsheet is located
excelfile=/path/to/excelfile/.xls

# the name of the output (.mat) file.
output_matfile=/path/to/dataset.mat

# if set to anything but 0 or blank, the first row of the excel file is
#   a header and will be ignored
exists_header=0

# a numeric vector encapsulated by square brackets, where each number
#   denotes a column that represents a categorical variable, set to 0 if
#   no such variable exists
string_cols=[2 3 4]

# sets whether the output contains rows with missing data ('surrogate')
#   or excludes the rows ('no_surrogate')
type='surrogate'

# the name of the variable saved to the .mat file
varname=group_data

# the full path to the repository containing the RFAnalysis code.
repopath=/destination/path/for/FRF

# the name of the matlab command line executable, can include arguments
#   additional options, etc. SingleCompThread is enabled by default.
matlab_command=matlab
```

After generating a parameter file, one can prepare their data using the
wrapper. From a bash terminal, one can execute the wrapper on his or her
parameter file:

```bash
./RFSD/PrepExcelSheetForTreeBagging_wrapper.sh parameterfile.bash
```

*NOTE* that parameter files in the `RFSD` directory end with the file
extension `.bash`. This is to help discern if a file is intended to be
an executable (ending in `.sh`) or a parameters file.

The output from PrepExcelSheetForTreebagging will be a .mat file
containing your named variable. Both the variable name and path must be
modified in the ConstructModelTreeBag wrapper below (see: “Running the
analysis").

##### R

If your data exists within an R data frame, R packages can be used to
export the data frame as a .mat file explicitly (e.g. R.matlab:
<https://cran.r-project.org/web/packages/R.matlab/index.html>). Since
FRF accepts cell or numeric matrices, one can export a data frame as a
cell matrix:

```R
writeMat(con="…filepath",x=data)
```

or as a numeric matrix:

```R
writeMat(con="…filepath",x=as.matrix(data))
```

R.matlab also enables one to load outputs into R for inspection (see:
“Stored outputs" under “Interpreting the Outputs").

##### CSV

CSVs (comma separated value files) can be implicitly handled by the FRF
package. To use a CSV as an input, the following steps have to be taken:

1)  The CSV must be organized as a table (i.e. 2D matrix) with rows
    representing cases and columns representing features.

2)  The delimiter used by the CSV

3)  The CSV cannot contain any header information (i.e. a top row
    depicting the column headers).

4)  Missing or blank cells (see: “How to deal with missing data") must
    be represented by NaNs.

<!-- end list -->

#### How to deal with missing data

Our RF approach can handle missing data via use of “surrogate splits".
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
parameter file").

#### Generating your parameter file

The `RFSD` and `FRF` packages contain `bash` wrappers for executing the algorithm
from the command line. Parameter files are used to store the
configuration for the analysis. Below are the parameters available for
running the `RFSD` using the `ConstructModelTreeBag_wrapper.sh`. These
parameters can be found in the `TreeBagParamFile_example.bash`. We use this
configuration file in order to support the many user tuned parameters.

In order to understand the layout of this *Parameters File*, we provide some
intuition. Comments precede parameter definitions for clarity. Variable assigment
(in `bash`), requires no space around the `=` character.


File sections that follow the pattern below, describe a conditional relationshi
This relationship dictates that under a condition of `variable_name`,
`subvariable_name_one` and `subvariable_name_two` will be used and must be
defined. Otherwise, then these values will be ignored.

```bash
variable_name=false
    subvariable_name_one=monkey
    subvariable_name_two=7
```

Additionally, the use of `0` as an index denotes a false state. These tools
are written in matlab, and therefore assumes a `1` index of colunmns and arrays

Comments of the form below, are used to designate categories of defined variable

```bash
# =====================
# == Sectional Title
# =====================
```

Our example config file is found [here](./RFSD/TreeBagParamFile_example.bash).

### Running the analysis

### Interpreting the outputs

#### Stored outputs

##### Description of outputs

##### Loading outputs in R

##### Converting outputs to text

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
