#!/bin/bash

#PBS -N Pop_test
#PBS -l nodes=1:ppn=1
#PBS -l walltime=240:00:00
#PBS -q batch2	#  batch2 or bigmem2 or batch1
#PBS -k oe

########### INIT ###########
# enable module tool 
# source /etc/profile.d/*.sh    

# set workdir
WORKDIR=/home/ouyang/ShortProject/ShortProject1_DeepRed_from_LiuFeng/DeepRed_Code_from_LiuFeng/
########### RUN ###########
cd $WORKDIR
#start application and log output using 'tee' in myapp_mpi.log

matlab -nodisplay -nosplash  -r 'C2_ensemble_score2( $type, $training_cell, $subdir, $test_cell, [20 50], [1000 100], 50, 20, 250000  );exit'

########### CLEAN UP ###########
# rm -rf *.tmp
