#!/bin/bash
#SBATCH --partition=compute         	# Queue selection
#SBATCH --job-name=BLAST-1       	# Job name
#SBATCH --mail-type=END             	# Mail events (BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=ngermolus@whoi.edu  # Where to send mail
#SBATCH --ntasks=1                  	# Run on a single CPU
#SBATCH --cpus-per-task=35		# Use x cores on node
#SBATCH --mem=100gb                   	# Job memory request
#SBATCH --time=2:00:00             	# Time limit hrs:min:sec
#SBATCH --output=BLAST_%j.log  		# Standard output/error

export OMP_NUM_THREADS=35
module load bio blast
# dbase=$(/vortexfs1/apps/bio/blast-2.7.1/blastdb/) # Trying the "nr" command

for file in $(find /vortexfs1/omics/env-bio/collaboration/genome-streamlining/data/Proteins/ -name *.faa)
do

filename=$(basename ${file})
# I commented out the line below because we have a BLAST database on file, so I will use that one. 
# makeblastdb -in ${file} -title ${filename} -dbtype prot -out ${filename}

blastp -query ${file} -db nr -evalue 1e-10 -num_threads 35 -outfmt "6 qseqid salltitles pident length mismatch gapopen qstart qend sstart send evalue bitscore" -out /vortexfs1/omics/env-bio/collaboration/genome-streamlining/data/SAG_Blastp/${filename}_blastp.txt

done



