#!/bin/bash

#PBS -N lf3426_MATLAB 
#PBS -l nodes=1:ppn=1
#PBS -l walltime=240:00:00
#PBS -q batch2	#  batch2 or bigmem2 or batch1
#PBS -k oe

########### INIT ###########
# enable module tool 
# source /etc/profile.d/*.sh    

# set workdir
#please change the directory to the location in your system
WORKDIR=WorkDir_of_DeepRed
########### RUN ###########
cd $WORKDIR
#start application and log output using 'tee' in myapp_mpi.log

/opt/software/matlab/bin/matlab -nodisplay -nosplash  -r 'B1_train_individual_classifier( $type, $cell, $range, [1000 100], 50, idx_partition, 250000  );exit'

########### CLEAN UP ###########
# rm -rf *.tmp
