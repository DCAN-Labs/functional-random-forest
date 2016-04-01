#!/usr/global/bin/python
#
# See help option for usage
# Originally written by Damion Demeter, 09.03.2015
#
# Infomap Community Detection from Matrix (last revision's modified date)
last_modified = 'Last Modified by Damion Demeter, 09.03.15'

import argparse,datetime,getpass,math,numpy,os,random,subprocess,sys,time
import scipy.io as sio

here = os.path.dirname(os.path.abspath(os.path.realpath(__file__)))
pwd = os.getcwd()

#############
prog_descrip = '""%(prog)s: Infomap Community Detection from Matrix Script. Use -h option for usage.""' + last_modified
def main(argv=sys.argv):
    arg_parser = argparse.ArgumentParser(description=prog_descrip)

    arg_parser.add_argument('-m', metavar='MATRIX_PATH', action='store', required=True, type=os.path.abspath,
                            help=('Full path to your correlation matrix. Required.'),
                            dest='corr_matrix'
                           )
    arg_parser.add_argument('-o', metavar='OUT_DIR', action='store', required=False, type=os.path.abspath, default=pwd,
                            help=('Output Directory ("community_detection" folder will be created here). Default=PWD'),
                            dest='out_dir'
                           )                           
    arg_parser.add_argument('-p', metavar='PERCENT_THRESHOLD', nargs='?', action='store', required=False, type=float, default=1.0,
                            help=('Percent Threshold (Top Connections) Use 0.0X format. :: Default is 1.0 assuming thresholding already performed.'),
                            dest='perc_thresh'
                           )                                              
    args = arg_parser.parse_args()
    #################################################
    ## Script Argument Verification and Assignment ##
    #################################################
    print '\n--------------------- setup info ---------------------------------'

    if os.path.isfile(args.corr_matrix):
        Corr_mat_path = args.corr_matrix
        print 'Running infomap_undir community detection on the following matrix:'
        print Corr_mat_path
    else:
        print 'The matrix path you specified is not a file. Exiting...'
        sys.exit()
    ###
    if os.path.isdir(args.out_dir):
        out_dir = args.out_dir
        print 'Output directory ("community_detection") will be created here:'
        print out_dir
    else:
        print 'The output directory you specified does not exist. Exiting...'
        sys.exit()
    ###        
    if args.perc_thresh == 1.0:
        print 'Using default PERCENT THRESHOLD of 1.0 (100% of connections)'
        perc_thresh = float(args.perc_thresh)
        perc_thresh_str = '100'
    else:       
        perc_thresh = float(args.perc_thresh)
        perc_thresh_str = str(perc_thresh)[-2:]
        print 'Using user input PERCENT THRESHOLD of ' + perc_thresh_str    
        
    ###############################################################
    print '--------------------------- end ---------------------------------\n'

    #################################################
    ##          Global Variable Assignment         ##
    #################################################    
    start_time=time.time()
    time.sleep(1)
    today_date = datetime.datetime.now().strftime('%m%d%Y')
    curr_user = getpass.getuser()
    
#####################
    def matrix_prep():
        print '\n------------= STEP 1 # PREPARING MATRIX =------------------'

        ### 1. LOAD GROUP CORR/SORT DESCENDING & INDEX/CALCULATE PERC # OF CONN/REPLACE BELOW THRESH WITH ZERO'S ###
        print 'Finding number of connections that pass threshold of ' + str(perc_thresh) + '...'
        
        mat_file = os.path.basename(Corr_mat_path)
        mat_name = mat_file.split('.')[0]
        mat_file = sio.loadmat(Corr_mat_path)

        Corr_mat = mat_file[mat_name]
        
        voxel_count = numpy.shape(Corr_mat)[0]
        num_of_conn = int(math.ceil(perc_thresh*((voxel_count*(voxel_count-1))/2)))
        
        Id = Corr_mat.ravel().argsort()
        zero_indices = Id[:(-1*num_of_conn)]
        del(num_of_conn)
        del(Id)
        flat_corr = Corr_mat.ravel()
        time.sleep(1)
        flat_corr[zero_indices] = 0.0
        Corr_mat = numpy.reshape(flat_corr, (voxel_count,voxel_count))
        del(flat_corr)
        
        print 'Finished. Passing matrix to infomap...'
        
        return Corr_mat,mat_name

##################       
    def infomap(Corr_mat,mat_name):
        print '\n------------= STEP 2 # RUNNING INFOMAP ON MATRIX =------------------'
        
        ### 1. INFOMAP_UNDIR/ADJ.NET FILE CREATION/COMMUNITY ###
        ## CREATING adj.net FILE for infomap_undir ##
        print 'Creating adjacency list for infomap...'
        output_dir = os.path.join( out_dir,'community_detection')
        if os.path.isdir(output_dir):
            pass
        else:
            os.mkdir(output_dir)
            
        dst_file = 'adj.net'
        dst_file = os.path.join( output_dir,mat_name + '_' + dst_file )
        
        with open(dst_file,'w') as f:
            f.write('*Vertices ' + str(len(Corr_mat)) + '\n')
            for i in range(1,len(Corr_mat)+1):
                f.write(' ' + str(i) + ' "v' + str(i) + '"\n')
            f.write('*Arcs\n')
            f.write('*Edges\n')
            
            for i in range(0,len(Corr_mat)):
                for j in range(i+1,len(Corr_mat)):
                    if Corr_mat[i,j] > 0:
                        f.write(' ' + str(i+1) + ' ' + str(j+1) + ' ' + "{:1.6f}".format(Corr_mat[i,j]) + '\n')
        f.close()
        
        ## RUNNING infomap_undir USING adj.net file created ##
        print 'Running infomap community detection...'
        command = 'infomap_undir'    
        random_num = random.randint(0,100000000)
        comm = command + ' ' + str(random_num) + ' ' + dst_file + ' 1'
    
        subprocess.call(comm, shell=True)   
    
        ## OPEN CLU FILE, MAKE LIST, AND SAVE COPY ##
        clu_path = dst_file.replace('net','clu')
        
        group_comm_vect = os.path.join( output_dir, mat_name + '_' + perc_thresh_str + '_thresh_comms.txt' )
        
        f = open(clu_path,'r')
        comm_lines = [line.rstrip('\r\n') for line in f]
        comms_list = comm_lines[1:]
        f.close()
        
        with open(group_comm_vect, 'w') as vect_out:
            for c in comm_lines[1:]:
                vect_out.write(str(c) + '\n')            
        vect_out.close()

################# RUNNING FUNCTIONS #################

    Corr_mat,mat_name = matrix_prep()
    
    infomap(Corr_mat,mat_name)
    
    
    
    
    
    full_runtime = time.time() - start_time
    print 'Full Script Runtime: ', datetime.timedelta(seconds=full_runtime), '\n'
if __name__ == '__main__':
    sys.exit(main())
