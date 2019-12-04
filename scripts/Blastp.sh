#!/bin/bash
#SBATCH --partition=compute             # Queue selection
#SBATCH --job-name=BLASTp                # Job name
#SBATCH --mail-type=END                 # Mail events (BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=ngermolus@whoi.edu  # Where to send mail
#SBATCH --ntasks=1                      # Run on a single CPU
#SBATCH --cpus-per-task=36              # Use x cores on node
#SBATCH --mem=180gb                     # Job memory request
#SBATCH --time=24:00:00                 # Time limit hrs:min:sec
#SBATCH --output=BLAST_%j.log           # Standard output/error
#SBATCH --array=1-56

export LOG_DIR=/vortexfs1/omics/env-bio/collaboration/genome-streamlining/Genome-Streamline/logs
export INPUT_DIR=/vortexfs1/omics/env-bio/collaboration/genome-streamlining/data/Proteins
export OUTPUT_DIR=/vortexfs1/omics/env-bio/collaboration/genome-streamlining/data/SAG_Blastp
export OMP_NUM_THREADS=36

module load bio blast

dbase=/vortexfs1/apps/bio/blast-2.7.1/blastdb/nr

RUN_ID=$(( $SLURM_ARRAY_TASK_ID + 1 ))
QUERY_FILE=$( ls ${INPUT_DIR} | sed -n ${RUN_ID}p )
QUERY_NAME="${QUERY_FILE%.*}"

QUERY="${INPUT_DIR}/${QUERY_FILE}"
OUTPUT="${OUTPUT_DIR}/${QUERY_NAME}_blastp.txt"

echo -e "Command:\nblastp -query ${QUERY} -db $dbase -evalue 1e-10 -num_threads 8 -outfmt "6 qseqid sacc salltitles pident length mismatch gapopen qstart qend sstart send evalue bitscore sallgi" -out ${OUTPUT}"
blastp -query ${QUERY} -db $dbase -evalue 1e-10 -num_threads 35 -outfmt "6 qseqid sacc salltitles pident length mismatch gapopen qstart qend sstart send evalue bitscore sallgi" -out ${OUTPUT}
# done
