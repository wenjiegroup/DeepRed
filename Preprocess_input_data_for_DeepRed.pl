use strict;

my $time_start=$^T;


my $dir="./DeepRed";
my $inputName=$ARGV[0];#name of test project
my $sample=$ARGV[1];#name of test sample
system("perl $dir/Sequence_feature_for_DeepRed.pl $sample");
system("perl $dir/A1_check_and_extract_input_data_chr.pl $inputName");
system("matlab -nodesktop -nosplash -nodisplay -r \"$dir/A2_load_data_chr(100,'$inputName\_for_Input_Data_chr');exit\"");

my $time_end=time();
my $time=$time_end-$time_start;
print "start:$time_start\n";
print "end:$time_end\n"; 
print "use_time:$time\n";
#=cut;

