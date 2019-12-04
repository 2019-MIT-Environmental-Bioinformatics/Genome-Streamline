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

##This is actually well-documented in the methods.
## You need to set e-value cutoff within config file (clust_config.txt) because I guess the -e flag means something different in the command line?

export BLASTMAT=/vortexfs1/apps/bio/blast-2.2.22/data/

## For SAG predicted proteins (Prodigal output)
for file in /vortexfs1/omics/env-bio/collaboration/genome-streamlining/data/Proteins/*.faa; do
	name=$(basename $file .faa)

	# This clusters proteins that are at least 30% identical over at least 50% of their length, with an e-value cutoff of 1e-6
	blastclust -L 0.5 -S 30.0 -i $file -a 32 -c clust_config.txt -o ../output/blastclust/${name}_blastclust.out
done

## For cultures
for file in /vortexfs1/omics/env-bio/collaboration/genome-streamlining/data/Proteins/cultures/*.faa; do
	name=$(basename $file .faa)

	# This clusters proteins that are at least 30% identical over at least 50% of their length, with an e-value cutoff of 1e-6
	blastclust -L 0.5 -S 30.0 -i $file -a 32 -c clust_config.txt -o ../output/blastclust/cultures/${name}_blastclust.out
done

## For additional cultures not included in the original paper
for file in /vortexfs1/omics/env-bio/collaboration/genome-streamlining/data/Proteins/cultures/cory_cult/*.faa; do
	name=$(basename $file .faa)

	# This clusters proteins that are at least 30% identical over at least 50% of their length, with an e-value cutoff of 1e-6
	blastclust -L 0.5 -S 30.0 -i $file -a 32 -c clust_config.txt -o ../output/blastclust/cultures/cory_cult/${name}_blastclust.out
done