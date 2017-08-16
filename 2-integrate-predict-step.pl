use strict;

my $time_start=$^T;


my $script="/home/ouyang/ShortProject/ShortProject1_DeepRed_from_LiuFeng/DeepRed_Code_from_LiuFeng";
my $inputName=$ARGV[0];#"Population_seq";
#my $sample=$ARGV[1];

#for(my$sample=388227;$sample<388230;$sample++)
foreach my $sample(qw(188214 188427))
{
	#system("perl $script/C1_run_pbs_of_predicting1_repeatedly.pl $inputName\_for_Input_Data_chr ERR$sample");
	#system("perl $script/C2_run_pbs_of_predicting2_repeatedly.pl $inputName\_for_Input_Data_chr ERR$sample");
	system("perl $script/C3_run_pbs_of_predicting3_repeatedly.pl $inputName\_for_Input_Data_chr ERR$sample");
	system("perl $script/C4_run_pbs_of_predicting4_repeatedly.pl $inputName\_for_Input_Data_chr ERR$sample");
}

my $time_end=time();
my $time=$time_end-$time_start;
print "start:$time_start\n";
print "end:$time_end\n"; 
print "use_time:$time\n";

