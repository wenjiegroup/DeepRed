use strict;
#WorkDir="/home/ouyang/ShortProject/ShortProject1_DeepRed_from_LiuFeng/DeepRed_Code_from_LiuFeng";
my $output="./Predict_result/Population_seq_for_Input_Data_chr/predict_result_of_ERR$ARGV[0]";
my $order="./Raw_Data/Population_seq_for_Input_Data_chr/order_of_location.ERR$ARGV[0].txt";
my $score="./Score/Score_combined/Population_seq_for_Input_Data_chr/Score_predicted.ERR$ARGV[0].txt";
my $GATK="/home/ouyang/data/GEUV/ERR$ARGV[0].con.vcf";
my $cutoff=$ARGV[1];
my @a;
my %site;

=cut;
system("cat /home/ouyang/data/GEUV/ERR$ARGV[0].Alu.vcf  /home/ouyang/data/GEUV/ERR$ARGV[0].RepAlu.vcf /home/ouyang/data/GEUV/ERR$ARGV[0].nonRep.vcf > ./Predict_result/Population_seq_for_Input_Data_chr/ERR$ARGV[0].All.vcf");



system("paste $order $score > $output.temp");

open(f,$GATK)||die"error $GATK\n";
while(<f>)
{
	@a=split/\s+/,$_;
	if(!exists $site{$a[0]."\t".$a[1]})
	{
		$site{$a[0]."\t".$a[1]}=$a[2]."\t".$a[3]."\t".$a[4];
	}
}
close f;

open(o,">$output.txt")||die "error $output.txt\n";
print o "#CHR\tPOS\tDeepRed_value\tCoverage_depth,altering_reads,mapq\tRef\tAlt\n";
open(f,"$output.temp")||die"error $output.temp\n";
while(<f>)
{
	@a=split/\s+/,$_;
	if(exists $site{$a[0]."\t".$a[1]})
	{
		print o $a[0]."\t".$a[1]."\t".$site{$a[0]."\t".$a[1]}."\t".$a[2]."\n";
	}
	#else{
	#	print "error\t$a[0]\t$a[1]\n";
	#}
}
close f;
close o;


###--------------choose a cutoff to extract RNA editing-------------------###

open(o,">$output.cutoff$cutoff.txt")||die"error open $output.cutoff$cutoff.txt\n";
open(f,"$output.txt")||die "error $output.txt\n";
while(<f>)
{
	@a=split/\s+/,$_;
	if($a[5] > $cutoff){print o $_;}
}
close f;
close o;
=cut;
system("wc -l $output.cutoff$cutoff.txt");
system("wc -l ./Predict_result/Population_seq_for_Input_Data_chr/ERR$ARGV[0].All.vcf");


###----------------overlap-of-DeepRed-and JinBilly-------------###
my %overlap;
my $num_of_AtoG_DeepRed=0;
my $num_of_AtoG_Billy=0;
my $num_of_AtoG_overlap=0;


open(f,"$output.cutoff$cutoff.txt")||die"error open $output.cutoff$cutoff.txt\n";
while(<f>)
{
	@a=split/\s+/,$_;
	if(!exists $overlap{$a[0]."\t".$a[1]})
	{
		$overlap{$a[0]."\t".$a[1]}=$a[3]."\t".$a[4];
		if(($a[3]."\t".$a[4] eq "A\tG") or ($a[3]."\t".$a[4] eq "T\tC"))
		{
			$num_of_AtoG_DeepRed ++;
		}
	}
}
close f;

open(o,">./Predict_result/Population_seq_for_Input_Data_chr/overlap_of_Billy_and_DeepRed.ERR$ARGV[0].cutoff$cutoff.txt")||die"error open overlap\n";
open(f,"./Predict_result/Population_seq_for_Input_Data_chr/ERR$ARGV[0].All.vcf")||die"error open ERR$ARGV[0].All.vcf\n";
while(<f>)
{
	@a=split/\s+/,$_;
	if(($a[3]."\t".$a[4] eq "A\tG") or ($a[3]."\t".$a[4] eq "T\tC"))
	{
		$num_of_AtoG_Billy ++;
	}
	if(exists $overlap{$a[0]."\t".$a[1]})
	{
		print o $a[0]."\t".$a[1]."\t".$overlap{$a[0]."\t".$a[1]}."\n";
		if(($overlap{$a[0]."\t".$a[1]} eq "A\tG") or ($overlap{$a[0]."\t".$a[1]} eq "T\tC"))
		{
			$num_of_AtoG_overlap ++;
		}
	}
}
close f;
close o;

system("wc -l ./Predict_result/Population_seq_for_Input_Data_chr/overlap_of_Billy_and_DeepRed.ERR$ARGV[0].cutoff$cutoff.txt");

print "#of_A_to_I\tDeepRed\tBilly\toverlap\n";
print "$num_of_AtoG_DeepRed\t$num_of_AtoG_Billy\t$num_of_AtoG_overlap\n";