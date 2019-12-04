#!/bin/bash

#SBATCH --partition=compute         # Queue selection
#SBATCH --job-name=HF10_download	 # Job name
#SBATCH --mail-type=END             # Mail events (BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=ztobias@whoi.edu  # Where to send mail
#SBATCH --ntasks=1                  # Run on a single CPU
#SBATCH --mem=5gb                   # Job memory request
#SBATCH --time=2:00:00             # Time limit hrs:min:sec
#SBATCH --output=HF10_download_%j.log  # Standard output/error

module load anaconda
source activate downloading

input="/vortexfs1/omics/env-bio/collaboration/genome-streamlining/Genome-Streamline/wrangling/HF10_acc.txt" #input is HF10 acc
while IFS='\n' read -r line #read lines
do
	efetch -db nucleotide -format fasta -id $line >> /vortexfs1/omics/env-bio/collaboration/genome-streamlining/data/metagenomes/HOT/fosmid/HF10.fa #download and append fasta files from GenBank
done < "$input"
