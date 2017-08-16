#!/usr/bin/env perl
use strict;
use warnings;
use 5.010;


## PBS参数
my $batch="batch2";	# batch1 or batch2 or bigmem2
my $ppn=7;	#ppn根据实际运行内存来设置，先测试一下看占多少资源。如果这里设置为7，那么刀片机每个节点最多跑3个任务。


## 利用PBS调用MATLAB函数B1_train_individual_classifier的参数
my @types=('Pooled','Separate');	# 两种类型数据
my @cells=('BjCellLongnonpolya','Gm12878CytosolPap','Gm12878NucleusLongnonpolya','Helas3CytosolPap','Helas3NucleusPap','Hepg2CellPap','Hepg2CytosolLongnonpolya','MCF7CellPap','NhekNucleusLongnonpolya','NhekNucleusPap','SknshraCellLongnonpolya');	# 11个训练细胞
my @ranges=(20,50);	# 2种分辨率，指-20bp~20bp 和 -50bp~50bp
my $num_partition=20;	# 第一级ensemble中的DNN个数


my $dir_out="PBS";
mkdir $dir_out unless -e $dir_out;
$dir_out="$dir_out/training";
mkdir $dir_out unless -e $dir_out;

foreach my $type(@types)
{
	foreach my $cell(@cells)
	{
		foreach my $range(@ranges)
		{
			my $dir_out="$dir_out/$type.$cell.${range}bp.$batch";
			mkdir $dir_out unless -e $dir_out;
			foreach my $idx_partition(1..$num_partition)
			{
				{
					my $command="qsub -o $dir_out -e $dir_out -q $batch -l nodes=1:ppn=$ppn,mem=10gb -v type=\"\'$type\'\",cell=\"\'$cell\'\",range=$range,idx_partition=$idx_partition B1_pbs_for_training.sh";
					say $command;
					system($command);
				}
			}
		}
	}
}
