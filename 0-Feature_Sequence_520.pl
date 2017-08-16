use strict;

use lib qw(BioPerl-1.6.923); # NEEDS BIOPERL
$| = 1;
use strict;
use Getopt::Long;
use File::Spec;
use File::Basename;
use Bio::DB::Fasta;
#********* dir **********
my $database = "/home/ouyang/Reference_data/HumanReference/hg19/SplicingJunction/";
#my $number = $ARGV[0];
#********* file **********
my $reference = "ucsc.hg19.fasta";

#********* General variable **********
my @ATCG = ("A","T","C","G");
#************************* 

#*************************************************************************************** Start **************************************************
my $seqs;
#print STDERR "reading genome file...\n";
my $GENOMEFILE = "$database$reference";
my $seqDb =  Bio::DB::Fasta->new($GENOMEFILE);
#***************************************************************

###读取文件名称###
=cut;
open (f1,"./fileList.txt") || die "Erorr";
my @file;
while (<f1>)
{
	$_=~s/\s+$//;
	#if ($_ =~ /Generalization/){next;}
	push (@file,$_);
}
close f1;
=cut;

###对某一个文件进行转换操作###
for(my$j=629969;$j<629971;$j++)
{
	my $input = "/home/ouyang/Project1-Global_human_analysis/0224_STAR_identifying_mRNA_editings/STAR_mapping_dir/ERR$j/ERR$j.gatk.raw.vcf";
	my $output = "./Raw_Data/Population_seq/ERR$j.gatk.raw.seq";
#	$output =~ s/vcf/seq/; # 将vcf文件转换成seq文件
	print "$input\n";
	open (f1,"$input") || die "Error";
	open (o1,">$output") || die "Error";
	print o1 "Chr\tPos";
	for (my $i = -100;$i < 101;$i++){foreach my $m(@ATCG){print o1 "\t$i.$m";}}
	print o1 "\tType";
	print o1 "\n";

	my $number = 0;
	while (<f1>)
	{
		if($_ =~ /#/){next;}
		#if($_ !~ /^chr[1-9]+/){next;}
		$_=~s/\s+$//; # 去掉末尾的空格
		my @a = split /\t/,$_;
		my ($chr,$pos) = ($a[0],$a[1]);
		if ($chr eq "chrM" || length($chr) > 5){next;}
		my $Seq = uc($seqDb->get_Seq_by_id($chr)->subseq($pos-100=>$pos+100)); # 获取该位点上下游100bq的序列
		if (length($Seq) < 201) #应该刚好等于201，小于201说明没有获取完全该段序列，可能在染色体的开头或者末尾100bq内
		{
			print "$chr\t$pos\n";
			next;
		}
		my @BaseSurr = getSurroundingBase($chr,$Seq);
		print o1 "$chr\t$pos";
		foreach (@BaseSurr){print o1 "\t$_";}
		if ($number < 10){print o1 "\t1\n";}
		elsif ($number < 20){print o1 "\t-1\n";}
		else {print o1 "\t0\n";}
		$number++;
	}
	close f1;
	close o1;
}


sub getSurroundingBase{
	my ($chr,$Seq) = @_;
	my @result;
	my $n = 0;
	for (my $i = 0;$i < length($Seq);$i++){
		my $base = substr($Seq,$i,1);
		foreach my $m(@ATCG)
		{	if ($base eq $m){$result[$n] = 1;}
			else {$result[$n] = 0;}
			$n++;
		}
	}
	return(@result);
}
