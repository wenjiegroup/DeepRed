use strict;
#WorkDir="/home/ouyang/ShortProject/ShortProject1_DeepRed_from_LiuFeng/DeepRed_Code_from_LiuFeng";
my $output="./Predict_result/Population_seq_for_Input_Data_chr/predict_result_of_All_region";
my @cutoff=(0.12,0,0.14,0.12,0.14);
my @a;



###--------------all RNA editings in Alu-------------------###
my %site;
open(o,">$output.DeepRed.txt")||die"error\n";
for(my$i=188021;$i<188026;$i++)
{
	my $input="./Predict_result/Population_seq_for_Input_Data_chr/predict_result_of_ERR$i.cutoff$cutoff[$i-188021].txt";
	if($i==188022){next;}
	open(f,$input)||die"error open $input\n";
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
}
close o;


my %site2;
open(o,">$output.Billy.txt")||die"error\n";
for(my$i=188021;$i<188026;$i++)
{
	my $Billy="/home/ouyang/project1-global_human/2-data-rnaEditing/merge-raw-data/AllMergeResults/ERR$i.All.vcf";
	if($i==188022){next;}
	open(f,$Billy)||die"error\n";
	while(<f>)
	{
		@a=split/\s+/,$_;
		if(!exists $site2{$a[0]."\t".$a[1]})
		{
			$site2{$a[0]."\t".$a[1]}=1;
			print o $_;
		}
	}
	close f;
}
close o;

system("wc -l $output.DeepRed.txt");
system("wc -l $output.Billy.txt");

#=cut;
###----------------overlap-of-DeepRed-and JinBilly-------------###
my %overlap;
my $num_of_AtoG_DeepRed=0;
my $num_of_AtoG_Billy=0;
my $num_of_AtoG_overlap=0;


open(f,"$output.DeepRed.txt")||die"error\n";
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

open(o,">./Predict_result/Population_seq_for_Input_Data_chr/overlap_of_Billy_and_DeepRed_merge_sample.AllRegion.txt")||die"error open overlap\n";
open(f,"$output.Billy.txt")||die"error open \n";
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

system("wc -l ./Predict_result/Population_seq_for_Input_Data_chr/overlap_of_Billy_and_DeepRed_merge_sample.AllRegion.txt");

print "#of_A_to_I\tDeepRed\tBilly\toverlap\n";
print "$num_of_AtoG_DeepRed\t$num_of_AtoG_Billy\t$num_of_AtoG_overlap\n";