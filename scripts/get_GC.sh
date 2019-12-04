path_to_data='/vortexfs1/omics/env-bio/collaboration/genome-streamlining/data'


## Genomic GC content (from raw single-amplified genome assemblies)
for file in $(find ${path_to_data}/SAGs -name *fna.gz); do  ## Loops over every assembly fasta file within the SAGs directory
	name=$(basename ${file} .fna) 
	GC_num=$(grep -o '[GC]' $file | wc -l) ## Counts all G and C nucleotides
	nuc_num=$(grep -o '[ATGC]' $file | wc -l) ## Counts total number of ATGC nucleotides

	GC=$( bc <<< "scale=5; ${GC_num} / ${nuc_num}" ) ## This command performs arithemtic in bash, to 5 significant figures 

	echo $GC > ${path_to_data}/genome_stats/${name}_GC_genomic.txt ## Writes GC content to an output file specific to this input file
	echo $GC >> ALL_GC_genomic.txt ## Appends GC content of every input file to one file for downstream use
done


## Coding GC content (from CDS Prodigal output)
for file in $(find ${path_to_data}/cds -name *fna); do  ## Loops over every assembly fasta file within the cds directory
	name=$(basename ${file} .fna)
	GC_num=$(grep -o '[GC]' $file | wc -l) ## Counts all G and C nucleotides
	nuc_num=$(grep -o '[ATGC]' $file | wc -l) ## Counts total number of ATGC nucleotides

	GC=$( bc <<< "scale=5; ${GC_num} / ${nuc_num}" )

	echo $GC > ${path_to_data}/genome_stats/${name}_GC_coding.txt
	echo $GC >> ALL_GC_coding.txt
done

## Genomic GC content of cultures
for file in ${path_to_data}/cultures/ncbi-genomes-2019-11-15/*fna.gz; do  ## Loops over every gzipped culture fasta file
	name=$(basename ${file} .fna.gz)
	GC_num=$(zcat $file | grep -o '[GC]' | wc -l) ## Counts all G and C nucleotides
	nuc_num=$(zcat $file | grep -o '[ATGC]' | wc -l) ## Counts total number of ATGC nucleotides

	GC=$( bc <<< "scale=5; ${GC_num} / ${nuc_num}" )

	echo $GC > ${path_to_data}/genome_stats/cultures/${name}_genomic_GC_culture.txt
	echo $GC >> ALL_GC_cultures.txt
done

## GC content of coding regions of cultures
for file in $(find ${path_to_data}/cds/cultures -name *fna); do  ## Loops over every culture cds fasta file 	
	name=$(basename ${file} .fna)
	GC_num=$(grep -o '[GC]' $file | wc -l)
	nuc_num=$(grep -o '[ATGC]' $file | wc -l)

	GC=$( bc <<< "scale=5; ${GC_num} / ${nuc_num}" )

	echo $GC > ${path_to_data}/genome_stats/cultures/${name}_cds_GC_coding.txt
	echo $GC >> ALL_GC_cult_coding.txt
done

## Metagenomes
for file in {path_to_data}/metagenomes_filtered/*.fa.gz; do ## Loops over the gzipped filtered metagenome assemblies
	name=$(basename ${file} .fa.gz)
	GC_num=$(zcat $file | grep -o '[GC]' | wc -l)  ## Unzips the file and counts the total number of G and C nucleotides
	nuc_num=$(zcat $file | grep -o '[ATGC]' | wc -l) ## Counts the total number of ATGC nucleotides

	GC=$( bc <<< "scale=5; ${GC_num} / ${nuc_num}" ) ## This command performs arithmetic in bash, to 5 significant figures

	echo $GC > ${path_to_data}/genome_stats/metagenomes/${name}_GC_meta.txt 
	echo $GC >> ALL_GC_meta.txt	
done