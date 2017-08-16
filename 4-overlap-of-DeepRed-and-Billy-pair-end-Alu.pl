use strict;
#WorkDir="/home/ouyang/ShortProject/ShortProject1_DeepRed_from_LiuFeng/DeepRed_Code_from_LiuFeng";
my $output="./Predict_result/Population_seq_for_Input_Data_chr/predict_result_of_ERR$ARGV[0]";

my $cutoff=$ARGV[1];
my $Billy="/home/ouyang/project1-global_human/2-data-rnaEditing/merge-raw-data/AluMergeResults/ERR$ARGV[0].Alu.vcf";
my $Alu="/home/ouyang/Reference_data/HumanReference/hg19/Transcript/Alu.sort.txt";

my @a;
my %site;


###--------------extract RNA editing in Alu-------------------###
open(o,">$output.cutoff$cutoff.txt.temp")||die"error\n";
open(f,"$output.cutoff$cutoff.txt")||die"error\n";
while(<f>)
{
	@a=split/\s+/,$_;
	my $b=$a[1]+1;
	print o "$a[0]\t$a[1]\t$b\t$a[2]\t$a[3]\t$a[4]\t$a[5]\n";
}
close f;
close o;


system("bedtools intersect -u -a $output.cutoff$cutoff.txt.temp -b $Alu > $output.Alu.txt");

system("wc -l $output.Alu.txt");
system("wc -l $Billy");

#=cut;
###----------------overlap-of-DeepRed-and JinBilly-------------###
my %overlap;
my $num_of_AtoG_DeepRed=0;
my $num_of_AtoG_Billy=0;
my $num_of_AtoG_overlap=0;


open(f,"$output.Alu.txt")||die"error open $output.Alu.txt\n";
while(<f>)
{
	@a=split/\s+/,$_;
	if(!exists $overlap{$a[0]."\t".$a[1]})
	{
		$overlap{$a[0]."\t".$a[1]}=$a[4]."\t".$a[5];
		if(($a[4]."\t".$a[5] eq "A\tG") or ($a[4]."\t".$a[5] eq "T\tC"))
		{
			$num_of_AtoG_DeepRed ++;
		}
	}
}
close f;

open(o,">./Predict_result/Population_seq_for_Input_Data_chr/overlap_of_Billy_and_DeepRed_pair_end.ERR$ARGV[0].Alu.txt")||die"error open overlap\n";
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

system("wc -l ./Predict_result/Population_seq_for_Input_Data_chr/overlap_of_Billy_and_DeepRed_pair_end.ERR$ARGV[0].Alu.txt");

print "#of_A_to_I\tDeepRed\tBilly\toverlap\n";
print "$num_of_AtoG_DeepRed\t$num_of_AtoG_Billy\t$num_of_AtoG_overlap\n";