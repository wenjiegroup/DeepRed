use strict;

my $time_start=$^T;


my $dir="./DeepRed";#Dir of DeepRed code
my $inputName=$ARGV[0];#name of test project
my $sample=$ARGV[1];#name of test sample


system("perl $dir/C1_run_pbs_of_predicting1_repeatedly.pl $inputName\_for_Input_Data_chr $sample");
system("perl $dir/C2_run_pbs_of_predicting2_repeatedly.pl $inputName\_for_Input_Data_chr $sample");
system("perl $dir/C3_run_pbs_of_predicting3_repeatedly.pl $inputName\_for_Input_Data_chr $sample");
system("perl $dir/C4_run_pbs_of_predicting4_repeatedly.pl $inputName\_for_Input_Data_chr $sample");

my $time_end=time();
my $time=$time_end-$time_start;
print "start:$time_start\n";
print "end:$time_end\n"; 
print "use_time:$time\n";

