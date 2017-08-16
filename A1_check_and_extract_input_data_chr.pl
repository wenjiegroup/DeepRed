#!/usr/bin/env perl
use strict;
use warnings;
use 5.010;


my $directory='Sequence_Pooled';
if(@ARGV>0)
{
	$directory=$ARGV[0];#should be sub-directory of directory 'Raw_Data'
}

my $dir_in="Raw_Data/$directory";
my $dir_out=$dir_in."_for_Input_Data_chr";
say "--Input directory: $dir_in";
say "--Output directory: $dir_out";
mkdir $dir_out unless -e $dir_out;


opendir(DIR,$dir_in) or die "error open $dir_in\n";#($!);
my @files=grep { /\.seq$/ } readdir(DIR);##文件结尾符.seq
my %cell_uni;

foreach (@files)
{
	my @temp=split(/\./);
	$cell_uni{$temp[0]}++;
	#print "$temp[0]\n";
}


open(OUT3,">","$dir_out/summary.txt");
say OUT3 "cell\tRNA_Editing\tSNP\tOthers";
foreach my $cell(sort keys %cell_uni)
{
	# next unless $cell eq "Helas3CytosolPap";
	
	say $cell;
	open(IN,"<","$dir_in/${cell}.gatk.raw.seq") or die($!);###每个文件结尾的符号
	open(OUT,">","$dir_out/header.$cell.txt");

	$_=<IN>;
	print OUT;
	close(OUT);
	my $d=split(/\t/,$_);
	say "Dimensionality of features:".($d-3);

	open(OUT1,">","$dir_out/order_of_location.$cell.txt");
	open(OUT2,">","$dir_out/input_data.$cell.txt");
	open(OUT4,">","$dir_out/chr_ind.$cell.txt");

	my $i=0;
	my %n_of_kind;
	my %n_of_chr_and_kind;
	foreach my $i(1..23)
	{
		my $chr="chr$i";
		$chr="chrX" if $i==23;
		$n_of_chr_and_kind{$chr}{'p'}=0;
		$n_of_chr_and_kind{$chr}{'n'}=0;
		$n_of_chr_and_kind{$chr}{'o'}=0;
	}
	
	while(<IN>)
	{
		$i++;
		
		next if /^Chr	Pos	/;
		my @temp=split;
		unless(@temp==$d)
		{
			die("Row $i of ${cell}.800Seq.txt does not match!");
		}
		
		my $chr=$temp[0];
		next if $chr=~/^chr(Y|M)/;
		my $chr_ind=(split(/chr/,$chr))[1];
		$chr_ind=23 if $chr_ind eq 'X';
		
		say OUT1 "$temp[0]\t$temp[1]";
		say OUT4 $chr_ind;
		s/^$temp[0]\t$temp[1]\t//;
		print OUT2;
		if($temp[-1]==1)
		{
			$n_of_kind{'p'}++;
			$n_of_chr_and_kind{$chr}{'p'}++;
		}
		elsif($temp[-1]==-1)
		{
			$n_of_kind{'n'}++;
			$n_of_chr_and_kind{$chr}{'n'}++;
		}
		elsif($temp[-1]==0 || $temp[-1]==2 || $temp[-1]==3 || $temp[-1]==4)
		{
			$n_of_kind{'o'}++;
			$n_of_chr_and_kind{$chr}{'o'}++;
		}
		else
		{
			die("$temp[-1]");
		}
	}
	say $cell."\t".$n_of_kind{'p'}."\t".$n_of_kind{'n'}."\t".$n_of_kind{'o'};
	say OUT3 $cell."\t".$n_of_kind{'p'}."\t".$n_of_kind{'n'}."\t".$n_of_kind{'o'};
	foreach my $chr(sort by_chr_index keys %n_of_chr_and_kind)
	{
		say $chr."\t".$n_of_chr_and_kind{$chr}{'p'}."\t".$n_of_chr_and_kind{$chr}{'n'}."\t".$n_of_chr_and_kind{$chr}{'o'};
		say OUT3 $chr."\t".$n_of_chr_and_kind{$chr}{'p'}."\t".$n_of_chr_and_kind{$chr}{'n'}."\t".$n_of_chr_and_kind{$chr}{'o'};
	}
}

sub by_chr_index
{
	my $tempa=$a;
	my $tempb=$b;
	$tempa='chr23' if $tempa eq 'chrX';
	$tempb='chr23' if $tempb eq 'chrX';
	(split(/chr/,$tempa))[1] <=> (split(/chr/,$tempb))[1];
}
#=cut;