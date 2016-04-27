# Simple Infomap v0.1.0 (?) #

**I want to get community assignments from my correlation matrix! Can you do that?**
*It's dangerous to Infomap alone...take this: *

## Script Location:
- /group_shares/PSYCH/code/release/utilities/simple_infomap/simple_infomap.py

## Requirements:
 - A square matrix. It currently will not take matrices with uneven rows/columns. This runs the **undirected** (older) version of infomap.
  - _This will **eventually** be updated to the newest version of infomap and will work with undirected matrices as well._
  
## Arguments:
 - **-h** _shows the help menu_
 - **-m** _Full **path** to your correlation matrix. Required._
 - **-o** _Output Directory ("community_detection" folder will be created here). Default=PWD_
 - **-p** _Percent Threshold (Top Connections) Use 0.0X format. Default is 1.0 assuming thresholding already performed._

## Outputs:
 - Within the “community_detection” folder the script creates, you will see a bunch of files. 
 - The adjacency, .tree, .map, etc files are all files you can use in the infomap website to visualize your data (I’ve never tried it). 
 - **The important file you will see is the “xxxxx_thresh_comms.txt” file. This is your vector of community assignments for each roi/subject/voxel/etc.**

** Important Notes:**
- Your .mat file name must be the same as the internal matlab matrix name. I couldn’t quickly figure out how to make this more flexible, so for now, if your matrix is called “Mat_F” your matrix file should be called “Mat_F.mat”.