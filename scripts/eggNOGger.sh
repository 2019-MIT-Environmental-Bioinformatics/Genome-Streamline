#!/bin/bash
#SBATCH --partition=compute             # Queue selection
#SBATCH --job-name=eggNOG               # Job name
#SBATCH --mail-type=END                 # Mail events (BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=ngermolus@whoi.edu  # Where to send mail
#SBATCH --ntasks=1                      # Run on a single CPU
#SBATCH --cpus-per-task=35              # Use x cores on node
#SBATCH --mem=180gb                     # Job memory request
#SBATCH --time=06:00:00                 # Time limit hrs:min:sec
#SBATCH --output=/vortexfs1/omics/env-bio/collaboration/genome-streamlining/Genome-Streamline/logs/eggNOG_%j.log           # Standard output/error
#SBATCH --array=1-56

# This script should parallelize functional annotation with eggNOG Mapper v2. 
# ---Notes---
# -The creators note that the Diamond phase is more efficient if you split FASTA file into chunks less 
#  than 1,000,000 sequences. None of our files have more than 100,000 sequences, so we're going straight in. 
# -Update: you can get eggNOG with conda, but it straigh-up doesn't work. So, I cloned the git repository 
#  for the program into my personal HPC /home dir. 
# -

export INPUT_DIR=/vortexfs1/omics/env-bio/collaboration/genome-streamlining/data/Proteins
export OUTPUT_DIR=/vortexfs1/omics/env-bio/collaboration/genome-streamlining/data/eggNOGged
export DB_DIR=/vortexfs1/home/ngermolus/eggnog-mapper/data
export OMP_NUM_THREADS=35

RUN_ID=$(( $SLURM_ARRAY_TASK_ID + 1 ))
QUERY_FILE=$( ls ${INPUT_DIR} | sed -n ${RUN_ID}p )
QUERY_NAME="${QUERY_FILE%.*}"

QUERY="${INPUT_DIR}/${QUERY_FILE}"
OUTPUT="${OUTPUT_DIR}/${QUERY_NAME}_maNOG.txt"

echo -e "Query name: ${QUERY}\n Outfile: ${OUTPUT}\n"

python2.7 /vortexfs1/home/ngermolus/eggnog-mapper/emapper.py -i ${QUERY} --output ${OUTPUT} \
-m diamond #--dmnd_db 

# done