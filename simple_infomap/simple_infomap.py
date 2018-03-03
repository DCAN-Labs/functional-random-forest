#!/usr/bin/env python2.7
#
# See help option for usage
# Originally written by Damion Demeter, 09.03.2015
#
# Infomap Community Detection from Matrix (last revision's modified date)

import argparse
import datetime
import math
import os
import random
import re
import subprocess
import sys
import time

import numpy
import scipy.io as sio

last_modified = '03.02.2017'


class Timer(object):
    def __init__(self):
        pass

    def __enter__(self):
        self.start = time.clock()
        return self

    def __exit__(self, *args):
        self.end = time.clock()
        self.duration = datetime.timedelta(seconds=self.end - self.start)
        print >> sys.stderr, 'Full Script Runtime:', self.duration


def natural_key(string):
    return [int(s) if s.isdigit() else s for s in re.split(r'(\d+)', string)]


def infomap(Corr_mat, mat_name, out_dir, mat_type_string, mat_command,
            attempts, perc_thresh_str, infomap):
    print '\n----------= STEP 2 # RUNNING INFOMAP ON MATRIX =----------------'

    # 1. INFOMAP_UNDIR/ADJ.NET FILE CREATION/COMMUNITY #
    # CREATING adj.net FILE for infomap_undir #
    print 'Creating adjacency list for infomap...'
    output_dir = os.path.join(out_dir, 'community_detection')
    if os.path.isdir(output_dir):
        pass
    else:
        os.mkdir(output_dir)

    dst_file = 'adj.net'
    dst_file = os.path.join(output_dir, mat_name + '_' + dst_file)

    with open(dst_file, 'w') as f:
        f.write('*Vertices ' + str(len(Corr_mat)) + '\n')
        for i in range(1, len(Corr_mat)+1):
            f.write(' ' + str(i) + ' "v' + str(i) + '"\n')

        f.write('*Edges\n')

        for i in range(0, len(Corr_mat)):
            for j in range(i+1, len(Corr_mat)):
                if Corr_mat[i, j] > 0:
                    f.write(' ' + str(i+1) + ' ' + str(j+1) + ' ' +
                            "{:1.6f}".format(Corr_mat[i, j]) + '\n')

    print 'Running infomap community detection on your ' + \
        mat_type_string + ' matrix...'

    rand_num = random.randint(1, 9999)

    infomap_comm = ' '.join([
        infomap, dst_file, output_dir,
        '--clu --map --tree --bftree -i pajek',
        mat_command, '-s', str(rand_num), '-N',
        str(attempts)])

    subprocess.call(infomap_comm, shell=True)

    # OPEN CLU FILE, MAKE LIST, AND SAVE COPY #
    clu_path = dst_file.replace('net', 'clu')

    group_comm_vect = os.path.join(
        output_dir, mat_name + '_' + perc_thresh_str + '_thresh_comms.txt')

    clu_tuples = []
    f = open(clu_path, 'r')
    for line in f:
        split_line = line.split(' ')
        if len(split_line) == 3:
            line_tuple = (int(split_line[0]), split_line[1])
            clu_tuples.append(line_tuple)

    with open(group_comm_vect, 'w') as vect_out:
        for c in sorted(clu_tuples):
            vect_out.write(str(c[1]) + '\n')


def matrix_prep(Corr_mat_path, perc_thresh):
    print '\n------------= STEP 1 # PREPARING MATRIX =------------------'

    # 1. LOAD GROUP CORR/SORT DESCENDING & INDEX/CALCULATE PERC
    # OF CONN/REPLACE BELOW THRESH WITH ZERO'S #
    print 'Finding number of connections that pass threshold of ' + str(perc_thresh) + '...'

    mat_file = os.path.basename(Corr_mat_path)
    mat_name = mat_file.split('.')[0]
    mat_file = sio.loadmat(Corr_mat_path)

    for key in mat_file.keys():
        if '__' not in key:
            matrix_key = str(key)

    Corr_mat = mat_file[matrix_key]

    voxel_count = numpy.shape(Corr_mat)[0]
    num_of_conn = int(math.ceil(perc_thresh*((voxel_count*(voxel_count-1))/2)))

    Id = Corr_mat.ravel().argsort()
    zero_indices = Id[:(-1*num_of_conn)]
    del(num_of_conn)
    del(Id)
    flat_corr = Corr_mat.ravel()
    time.sleep(1)
    flat_corr[zero_indices] = 0.0
    Corr_mat = numpy.reshape(flat_corr, (voxel_count, voxel_count))
    del(flat_corr)

    print 'Finished. Passing matrix to infomap...'
    return Corr_mat, mat_name


def args_defaults_and_validator(args):
    # Script Argument Verification and Assignment #

    # verify infomap exists and is executable
    if not os.access(args.infomap, os.EX_OK):
        print "Infomap not executable"
        sys.exit()

    # VERIFY MATRIX/PATH EXISTS #
    if os.path.isfile(args.corr_matrix):
        Corr_mat_path = args.corr_matrix
        print 'Running infomap_undir community detection on the following matrix:'
        print Corr_mat_path
    else:
        print 'The matrix path you specified is not a file. Exiting...'
        sys.exit()
    # VERIFY OUTPUT DIRECTORY EXISTS #
    if os.path.isdir(args.out_dir):
        out_dir = args.out_dir
        print 'Output directory ("community_detection") will be created here:'
        print out_dir
    else:
        print 'The output directory you specified does not exist. Exiting...'
        sys.exit()
    # VERIFY MATRIX DIRECTION #
    if args.dir_mat and args.undir_mat:
        print '\nYou have marked your matrix as BOTH directed AND undirected. '\
            'Cannot be both. Exiting...'
        sys.exit()
    elif not args.dir_mat and not args.undir_mat:
        print '\nYou must use either the undirected or directed matrix flag. '\
            'See help for more info. Exiting...'
        sys.exit()
    elif args.dir_mat:
        print 'Processing matrix as DIRECTED.'
        mat_type = 'dir'
        mat_type_string = 'DIRECTED'
        mat_command = '-d'
    elif args.undir_mat:
        print 'Processing matrix as UNDIRECTED.'
        mat_type = 'undir'
        mat_type_string = 'UNDIRECTED'
        mat_command = '-u'
    # THRESHOLD PERCENTAGE #
    if args.perc_thresh == 1.0:
        print 'Using default PERCENT THRESHOLD of 1.0 (100% of connections)'
        perc_thresh = float(args.perc_thresh)
        perc_thresh_str = '100'
    else:
        perc_thresh = float(args.perc_thresh)
        perc_thresh_str = str(perc_thresh)[-2:]
        print 'Using user input PERCENT THRESHOLD of ' + perc_thresh_str

    return \
        Corr_mat_path, \
        out_dir, \
        mat_type, mat_type_string, mat_command, \
        perc_thresh, perc_thresh_str, \
        args.attempts, infomap


def generate_parser(arg_parser):
    arg_parser.add_argument(
        '-i', type=os.path.abspath, required=True,
        help=('Full path to infomap')
    )

    arg_parser.add_argument(
        '-a', metavar='INFOMAP_ATTEMPTS', action='store', required=False,
        type=int, default=5,
        help=('Infomap attempts. This will re-run infomap for precision.'
              ' NOT Required. Default = 5'),
        dest='attempts'
    )

    arg_parser.add_argument(
        '-d', action='store_true', required=False, default=False,
        help=('Flag for using a DIRECTED Matrix.'),
        dest='dir_mat'
    )

    arg_parser.add_argument(
        '-m', metavar='MATRIX_PATH', action='store', required=True,
        type=os.path.abspath,
        help=('Full path to your correlation matrix. Required.'),
        dest='corr_matrix'
    )

    arg_parser.add_argument(
        '-o', metavar='OUT_DIR', action='store', required=False,
        type=os.path.abspath, default='.',
        help=('Output Directory ("community_detection" folder will '
              'be created here). Default=PWD'),
        dest='out_dir'
    )

    arg_parser.add_argument(
        '-p', metavar='PERCENT_THRESHOLD', nargs='?', action='store',
        required=False, type=float, default=1.0,
        help=('Percent Threshold (Top Connections) Use 0.0X format '
              '(Example top 3 percent is 0.03). :: Default is 1.0 '
              'assuming thresholding already performed (100 percent '
              'of conns).'),
        dest='perc_thresh'
    )

    arg_parser.add_argument(
        '-u', action='store_true', required=False, default=True,
        help=('Flag for using an UNDIRECTED Matrix.'),
        dest='undir_mat'
    )

    return arg_parser


def main(argv=sys.argv):
    prog_descrip = '""%(prog)s: Infomap Community Detection from '\
                   'Matrix Script. Use -h option for usage.""' \
                   + last_modified

    arg_parser = generate_parser(
        argparse.ArgumentParser(description=prog_descrip))

    args = arg_parser.parse_args()

    Corr_mat_path, out_dir, mat_type, mat_type_string, \
        mat_command, perc_thresh, perc_thresh_str, \
        attempts, infomap \
        = args_defaults_and_validator(args)

    with Timer() as t:
        Corr_mat, mat_name = matrix_prep(Corr_mat_path, perc_thresh)
        infomap(Corr_mat, mat_name, out_dir, mat_type_string, mat_command,
                attempts, perc_thresh_str, infomap)


if __name__ == '__main__':
    sys.exit(main())
