use strict;
#foreach my$i(qw(188107 188214 188427))
for(my$i=188021;$i<188483;$i++)
{
	print "ERR$i\n";
	my $order="./Raw_Data/Population_seq_for_Input_Data_chr/order_of_location.ERR$i.txt";
	my $score="./Score/Score_combined/Population_seq_for_Input_Data_chr/Score_predicted.ERR$i.txt";
	my $output="./Predict_result/Population_seq_for_Input_Data_chr/predict_of_result_ERR$i.txt";
	my $con="/home/ouyang/Project1-Global_human_analysis/0224_STAR_identifying_mRNA_editings/STAR_mapping_dir/ERR$i/ERR$i.con.vcf";
	my $result="./Predict_result/Population_seq_for_Input_Data_chr/ERR$i.DeepRed.txt";
	my @a;
	my %site;
	my $key;

	system("paste $order $score > $output");

	open(f,$con)||die"error $con\n";
	while(<f>)
	{
		@a = split/\s+/,$_;
		$site{$a[0]."\t".$a[1]}=join"\t",@a[2..@a-1];
	}
	close f;

	open(o,">$result")||die"error $result\n";
	open(f,$output)||die"error open $output\n";
	while(<f>)
	{
		@a = split/\s+/,$_;
		$key=$a[0]."\t".$a[1];
		if(exists $site{$key})
		{
			print o $a[0]."\t".$a[1]."\t".$site{$key}."\t".$a[2]."\n";
		}
	}
	close f;
	close o;
}






