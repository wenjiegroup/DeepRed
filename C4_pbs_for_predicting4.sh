#!/bin/bash

#PBS -N Pop_test
#PBS -l nodes=1:ppn=4
#PBS -l walltime=240:00:00
#PBS -q batch2	#  batch2 or bigmem2 or batch1
#PBS -k oe

########### INIT ###########
# enable module tool 
# source /etc/profile.d/*.sh    

# set workdir
#please change the directory to the location in your system
WORKDIR=Workdir_of_DeepRed
########### RUN ###########
cd $WORKDIR
#start application and log output using 'tee' in myapp_mpi.log

/opt/software/bin/matlab -nodisplay -nosplash  -r 'C4_ensemble_score4( $subdir, $test_cell, [20 50], [1000 100], 50, 20, 250000  );exit'

########### CLEAN UP ###########
# rm -rf *.tmp
