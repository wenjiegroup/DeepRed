use strict;
#WorkDir="/home/ouyang/ShortProject/ShortProject1_DeepRed_from_LiuFeng/DeepRed_Code_from_LiuFeng";
my $output="./Predict_result/Population_seq_for_Input_Data_chr/predict_result_of_ERR$ARGV[0]";
my $cutoff=$ARGV[1];
my $Billy="/home/ouyang/project1-global_human/2-data-rnaEditing/merge-raw-data/AllMergeResults/ERR$ARGV[0].All.vcf";
my @a;
my %site;


###--------------merge RNA editing of pair_end data-------------------###

open(o,">$output.cutoff$cutoff.txt")||die"error open $output.cutoff$cutoff.txt\n";
open(f,"$output\_1.cutoff$cutoff.txt")||die "error $output\_1.cutoff$cutoff.txt\n";
while(<f>)
{
	@a=split/\s+/,$_;
	if(!exists $site{$a[0]."\t".$a[1]})
	{
		$site{$a[0]."\t".$a[1]}=1;
		print o $_;
	}
}
close f;

open(f,"$output\_2.cutoff$cutoff.txt")||die "error $output\_2.cutoff$cutoff.txt\n";
while(<f>)
{
	@a=split/\s+/,$_;
	if(!exists$site{$a[0]."\t".$a[1]})
	{
		print o $_;
	}
}
close f;
close o;

system("wc -l $output.cutoff$cutoff.txt");
system("wc -l $Billy");

#=cut;
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

open(o,">./Predict_result/Population_seq_for_Input_Data_chr/overlap_of_Billy_and_DeepRed_pair_end.ERR$ARGV[0].cutoff$cutoff.txt")||die"error open overlap\n";
open(f,$Billy)||die"error open $Billy\n";
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

system("wc -l ./Predict_result/Population_seq_for_Input_Data_chr/overlap_of_Billy_and_DeepRed_pair_end.ERR$ARGV[0].cutoff$cutoff.txt");

print "#of_A_to_I\tDeepRed\tBilly\toverlap\n";
print "$num_of_AtoG_DeepRed\t$num_of_AtoG_Billy\t$num_of_AtoG_overlap\n";