#!/bin/bash
#SBATCH --partition=compute         	# Queue selection
#SBATCH --job-name=barrnap       	# Job name
#SBATCH --mail-type=END             	# Mail events (BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=ztobias@whoi.edu  # Where to send mail
#SBATCH --ntasks=1                  	# Run on a single CPU
#SBATCH --cpus-per-task=1		# Use x cores on node
#SBATCH --mem=10gb                   	# Job memory request
#SBATCH --time=00:15:00             	# Time limit hrs:min:sec
#SBATCH --output=/vortexfs1/omics/env-bio/collaboration/genome-streamlining/Genome-Streamline/logs/barrnap_%j.log  	# Standard output/error

module load anaconda
conda activate rRNA_prediction

export INPUT_DIR=/vortexfs1/omics/env-bio/collaboration/genome-streamlining/data/SAGs #save input directory path to variable
export OUTPUT_DIR=/vortexfs1/omics/env-bio/collaboration/genome-streamlining/data/rRNAs #save output directory path to variable
 
for file in `find ${INPUT_DIR} -name *.fna.gz` #loop through all of the files that end with fna.gz throughout SAG directory tree
do
	filename=`basename ${file} .fna.gz` #get last element of path and remove extension
	zcat ${file} > ${INPUT_DIR}/${filename}.fna #unzip SAG genome sequence and save to file
	barrnap -k bac --lencutoff 0.2 --reject 0.1 --evalue 1e-03 -o ${OUTPUT_DIR}/${filename}_rrna.fna < ${INPUT_DIR}/${filename}.fna > ${OUTPUT_DIR}/${filename}_rrna.gff #predict rDNA sequences using bacterial models and liberal thresholds and save sequences and coordinates to file
	rm ${INPUT_DIR}/${filename}.fna #delete unzipped SAG sequence
done 
	 



