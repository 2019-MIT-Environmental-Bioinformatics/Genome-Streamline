#!/bin/bash
#SBATCH --partition=compute         	# Queue selection
#SBATCH --job-name=prodigal-1       	# Job name
#SBATCH --mail-type=END             	# Mail events (BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=ngermolus@whoi.edu  # Where to send mail
#SBATCH --ntasks=1                  	# Run on a single CPU
#SBATCH --cpus-per-task=36		# Use x cores on node
#SBATCH --mem=1gb                   	# Job memory request
#SBATCH --time=06:00:00             	# Time limit hrs:min:sec
#SBATCH --output=prodigal_%j.log  	# Standard output/error

export OMP_NUM_THREADS=36
module load bio prodigal

for file in $(find /vortexfs1/omics/env-bio/collaboration/genome-streamlining/data/SAGs/ -name *fna.gz)
do

filename=$(basename ${file} .fna.gz)
prodigal -i ${file} -o ${filename}_coords.gbk -a ${filename}_proteins.faa

done



