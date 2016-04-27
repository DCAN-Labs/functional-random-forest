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
 - **-a** _Infomap attempts. This will re-run infomap for precision. NOT Required. Default=5_
 - **-d** _Flag for using a DIRECTED matrix._
 - **-m** _Full **path** to your correlation matrix. Required._
 - **-o** _Output Directory ("community_detection" folder will be created here). Default=PWD_
 - **-p** _Percent Threshold (Top Connections) Use 0.0X format. Default is 1.0 assuming thresholding already performed._
 - **-u** _Flag for using an UNDIRECTED matrix._

## Outputs:
 - Within the “community_detection” folder the script creates, you will see a bunch of files. 
 - The .net, .tree, .bftree, and .map, files are all files you can use on the infomap website to visualize your data (I’ve never tried...but that's what they say). 
 - The .clu file is the cluster file. It shows the unorganized node cluster (community) assignment list.
 - **The important file you will see is the “xxxxx_thresh_comms.txt” file. This is your vector of community assignments for each roi/subject/voxel/etc.**
   THEY HAVE BEEN PUT IN ORDER IN THIS FILE. Meaning, line one's value is the community assignment for voxel, subject, etc #1. 

** Important Notes:**
- Your .mat file name must be a single matrix. Your mat file cannot contain multiple matrices or it will 