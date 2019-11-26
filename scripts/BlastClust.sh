#!/bin/bash
#SBATCH --partition=compute             # Queue selection
#SBATCH --job-name=Blastclust           # Job name
#SBATCH --mail-type=END                 # Mail events (BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=cberger@whoi.edu  # Where to send mail
#SBATCH --ntasks=1                      # Run on a single CPU
#SBATCH --cpus-per-task=32              # Use x cores on node
#SBATCH --mem=10gb                     # Job memory request
#SBATCH --time=10:00:00                 # Time limit hrs:min:sec
#SBATCH --output=Blastclust_%j.log           # Standard output/error

export OMP_NUM_THREADS=32

module load bio blast/2.2.22

##This is actually well-documented in the methods, except the flags for blastclust have changed.
##need to set e-value cutoff within config file because they use the -e flag twice?? dumb

export BLASTMAT=/vortexfs1/apps/bio/blast-2.2.22/data/

for file in /vortexfs1/omics/env-bio/collaboration/genome-streamlining/data/Proteins/cultures/cory_cult/*.faa; do
name=$(basename $file .faa)

blastclust -L 0.5 -S 30.0 -i $file -a 32 -c clust_config.txt -o ../output/blastclust/cultures/cory_cult/${name}_blastclust.out
done