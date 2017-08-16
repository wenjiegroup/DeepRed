use strict;

my $time_start=$^T;


my $script="/home/ouyang/ShortProject/ShortProject1_DeepRed_from_LiuFeng/DeepRed_Code_from_LiuFeng";
#my $inputdata=$ARGV[0];#*.gatk.vcf
#my $preprocessData=$ARGV[0];#Raw_Data/Population_seq/ERR$ARGV[0].gatk.raw.seq
my $inputName=$ARGV[0];#Population_seq


#system("perl 0-Feature_Sequence_520.pl $inputdata $preprocessData");
system("perl A1_check_and_extract_input_data_chr.pl $inputName");
system("matlab -nodesktop -nosplash -nodisplay -r \"A2_load_data_chr(100,'$inputName\_for_Input_Data_chr');exit\"");

my $time_end=time();
my $time=$time_end-$time_start;
print "start:$time_start\n";
print "end:$time_end\n"; 
print "use_time:$time\n";
#=cut;

