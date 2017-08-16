#!/usr/bin/env perl
use strict;
use warnings;
use 5.010;

my $indir="/home/ouyang/ShortProject/ShortProject1_DeepRed_from_LiuFeng/DeepRed_Code_from_LiuFeng";
my $subdir='Sequence_Pooled_for_Input_Data_chr';
if(@ARGV)
{
	$subdir=$ARGV[0];#should be sub-directory of directory 'Raw_Data' with suffix '_for_Input_Data_chr'
}


## PBS参数
my $batch="batch2";	# batch1 or batch2 or bigmem2
my $ppn=1;	#ppn根据实际运行内存来设置，先测试一下看占多少资源。如果这里设置为4，那么刀片机每个节点最多跑6个任务。


## 利用PBS调用MATLAB函数C1_ensemble_score1的参数
# my @types=('Pooled','Separate');	# 两种类型数据
# my @training_cells=('BjCellLongnonpolya','Gm12878CytosolPap','Gm12878NucleusLongnonpolya','Helas3CytosolPap','Helas3NucleusPap','Hepg2CellPap','Hepg2CytosolLongnonpolya','MCF7CellPap','NhekNucleusLongnonpolya','NhekNucleusPap','SknshraCellLongnonpolya');	# 11个训练细胞
# my @ranges=(20,50);	# 2种分辨率，指-20bp~20bp 和 -50bp~50bp
# my $num_partition=20;	# 第一级ensemble中的DNN个数

my @test_cells;	#可以是11个训练细胞，也可以是21个测试细胞，还可以是其他任何待预测的细胞。
=cut;
opendir(DIR,"./Raw_Data/$subdir") or die($!);
my @files=sort grep { /^training_data\.\w+?.+\.mat$/ } readdir(DIR);
foreach (@files)
{
	push @test_cells,(split(/\./))[1];
}
=cut;
# @test_cells=('BjCellLongnonpolya','Gm12878CytosolPap','Gm12878NucleusLongnonpolya','Helas3CytosolPap','Helas3NucleusPap','Hepg2CellPap','Hepg2CytosolLongnonpolya','MCF7CellPap','NhekNucleusLongnonpolya','NhekNucleusPap','SknshraCellLongnonpolya');	# 手动指定为11个训练细胞

@test_cells=($ARGV[1]);
my $name=$ARGV[1];

my $dir_out="$indir/PBS";
mkdir $dir_out unless -e $dir_out;
$dir_out="$dir_out/prediction";
mkdir $dir_out unless -e $dir_out;

foreach my $test(@test_cells)
{
	# foreach my $type(@types)
	{
		# foreach my $training(@training_cells)
		{
			# foreach my $range(@ranges)
			{
				my $dir_out="$dir_out/combined.11cells.20_50bp.$batch";
				mkdir $dir_out unless -e $dir_out;
				# foreach my $idx_partition(1..$num_partition)
				{
					{
						my $command="qsub -N $name -o $dir_out -e $dir_out -q $batch -l nodes=1:ppn=$ppn,mem=8gb -v subdir=\"\'$subdir\'\",test_cell=\"\'$test\'\" $indir/C4_pbs_for_predicting4.sh";
						say $command;
						system($command);
					}
				}
			}
		}
	}
}
