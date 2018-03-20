DeepRed is tool to identify RNA editing sites from candidates SNVs.

The necessary columns as input for DeepRed are:
##CHROM	POS	REF	ALT

####  Start DeepRed
##please change the directory to the location in your system
#$subdirName = the_prefix_of_output_dir
#$sampleName = the_prefix_name_of_vcf_file

perl Preprocess_input_data_for_DeepRed.pl $subdirName $sampleName
perl Run_DeepRed.pl $subdirName $sampleName
