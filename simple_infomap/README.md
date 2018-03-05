# Simple Infomap v1.0.0 #

# Installation
`simple_infomap` is a `python2.7` dependency in this project, to support a simpler
interface to `Infomap`. In order to install this dependency you must install

- `python2.7`
- `numpy`
- `scipy`

To install this with `virtualenv`

```bash
$ virtualenv venv
$ source venv/bin/activate
(venv) $ pip install -r ./requirements.txt
(venv) $ ./simple_infomap.py -h
```

In order to use `simple_infomap.py` for the `RFSD` with your `virtualenv`, you will
need to `source` the `virtualenv` before running your `*_wrapper.sh` commands.

# Story

**I want to get community assignments from my correlation matrix! Can you do that?**
*It's dangerous to Infomap alone...take this: *

## Requirements:
 - A matlab matrix.
  - _Script has been updated to run infomap with a directed matrix, but **this has not been tested**_
  - _This also now uses the newest version of infomap, rather than the AIRC's old undirected only version_

## Arguments:
 - **-h** _shows the help menu_
 - **-i** Infomap Path
 - **-a** _Infomap attempts. This will re-run infomap for precision. NOT Required. Default=5_
 - **-d** _Flag for using a DIRECTED matrix._
 - **-m** _Full **path** to your correlation matrix. Required._
 - **-o** _Output Directory ("community_detection" folder will be created here). Default=PWD_
 - **-p** _Percent Threshold (Top Connections) Use 0.0X format (Example top 3% is 0.03). :: Default is 1.0 assuming thresholding already performed (100% of conns)._
 - **-u** _Flag for using an UNDIRECTED matrix._

## Outputs:
 - Within the “community_detection” folder the script creates, you will see a bunch of files.
 - The .net, .tree, .bftree, and .map, files are all files you can use on the infomap website to visualize your data (I’ve never tried...but that's what they say).
 - The .clu file is the cluster file. It shows the unorganized node cluster (community) assignment list.
 - **The important file you will see is the “xxxxx_thresh_comms.txt” file. This is your vector of community assignments for each roi/subject/voxel/etc.**
   THEY HAVE BEEN PUT IN ORDER IN THIS FILE. Meaning, line one's value is the community assignment for voxel, subject, etc #1.

** Important Notes:**
- Your .mat file name must be a single matrix. Your mat file cannot contain multiple matrices or it will
