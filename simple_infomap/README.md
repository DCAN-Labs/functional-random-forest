I want to get community assignments from my correlation matrix! Can you do that?
No problem, run this script:

Location: /group_shares/PSYCH/code/testing/utilities/simple_infomap/infomap_comm_detection.py

Requirements: A square matrix. It currently will not take matrices with uneven rows/columns. This runs the undirected version of infomap. This will eventually be wtweaked to work with informap_dir as well.


Toggle line numbers
   1 infomap_comm_detection.py: Infomap Community Detection from Matrix Script.
   2 Use -h option for usage.""Last Modified by Damion Demeter, 09.03.15
   3 
   4 optional arguments:
   5   -h, --help            show this help message and exit
   6   -m MATRIX_PATH        Full path to your correlation matrix. Required.
   7   -o OUT_DIR            Output Directory ("community_detection" folder will be
   8                         created here). Default=PWD
   9   -p [PERCENT_THRESHOLD]
  10                         Percent Threshold (Top Connections) Use 0.0X format.
  11                         :: Default is 1.0 assuming thresholding already
  12                         performed.
  13 
Outputs: Within the “community_detection” folder the script creates, you will see a bunch of files. The adjacency, .tree, .map, etc files are all files you can use in the infomap website to visualize your data (I’ve never tried it). The important file you will see is the “xxxxx_thresh_comms.txt” file. This is your vector of community assignments for each roi/subject/voxel/etc.

Important Notes: Your .mat file name must be the same as the internal matlab matrix name. I couldn’t quickly figure out how to make this more flexible, so for now, if your matrix is called “Mat_F” your matrix file should be called “Mat_F.mat”.