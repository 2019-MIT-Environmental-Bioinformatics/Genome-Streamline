#!/bin/bash

#SBATCH --partition=compute         # Queue selection
#SBATCH --job-name=SRA_download	 # Job name
#SBATCH --mail-type=END             # Mail events (BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=ztobias@whoi.edu  # Where to send mail
#SBATCH --ntasks=1                  # Run on a single CPU
#SBATCH --mem=5gb                   # Job memory request
#SBATCH --time=12:00:00             # Time limit hrs:min:sec
#SBATCH --output=SRA_download_%j.log  # Standard output/error

module load anaconda 
source activate downloading

input="/vortexfs1/omics/env-bio/collaboration/genome-streamlining/Genome-Streamline/wrangling/acc_dict.txt"
while IFS='\t' read -r line #loop over lines in acc_dict
do
    station=$(echo $line | awk '{print $1}')  #get station name
    for acc_list in $(echo $line | awk '{print $2}') #get list of associated accessions
    do
        for acc in $(echo $acc_list | sed "s/,/ /g") #loop over each element in comma separated list
        do
            fastq-dump --split-files --readids  --gzip -O /vortexfs1/omics/env-bio/collaboration/genome-streamlining/data/metagenomes/$station $acc #download that SRA accession and place in folder corresponding to its station
            done
    done
done < "$input"
