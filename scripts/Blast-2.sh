#!/bin/bash
#SBATCH --partition=compute             # Queue selection
#SBATCH --job-name=BLAST-test           # Job name
#SBATCH --mail-type=END                 # Mail events (BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=ngermolus@whoi.edu  # Where to send mail
#SBATCH --ntasks=1                      # Run on a single CPU
#SBATCH --cpus-per-task=35               # Use x cores on node
#SBATCH --mem=180gb                     # Job memory request
#SBATCH --time=24:00:00                  # Time limit hrs:min:sec
#SBATCH --output=BLAST_%j.log           # Standard output/error
#SBATCH --array=1-56

export LOG_DIR=/vortexfs1/omics/env-bio/collaboration/genome-streamlining/Genome-Streamline/logs
export INPUT_DIR=/vortexfs1/omics/env-bio/collaboration/genome-streamlining/data/Proteins
export OUTPUT_DIR=/vortexfs1/omics/env-bio/collaboration/genome-streamlining/data/SAG_Blastp
export OMP_NUM_THREADS=35

module load bio blast

dbase=/vortexfs1/apps/bio/blast-2.7.1/blastdb/nr
# for file in $(find /vortexfs1/omics/env-bio/collaboration/genome-streamlining/data/Proteins/ -name *.faa)
# do

# filename=$(basename ${file} .faa)
# I commented out the line below because we have a BLAST database on file, so I will use that one.
# makeblastdb -in ${file} -title ${filename} -dbtype prot -out ${filename}
RUN_ID=$(( $SLURM_ARRAY_TASK_ID + 1 ))
QUERY_FILE=$( ls ${INPUT_DIR} | sed -n ${RUN_ID}p )
QUERY_NAME="${QUERY_FILE%.*}"

QUERY="${INPUT_DIR}/${QUERY_FILE}"
OUTPUT="${OUTPUT_DIR}/${QUERY_NAME}_blastp.txt"

#makeblastdb -in /vortexfs1/apps/bio/blast-2.7.1/blastdb/nr -title nr -dbtype prot -out DBASE
echo -e "dbase finished"
echo -e "Command:\nblastp -query ${QUERY} -db $dbase -evalue 1e-10 -num_threads 8 -outfmt "6 qseqid sacc salltitles pident length mismatch gapopen qstart qend sstart send evalue bitscore sallgi" -out ${OUTPUT}"
blastp -query ${QUERY} -db $dbase -evalue 1e-10 -num_threads 35 -outfmt "6 qseqid sacc salltitles pident length mismatch gapopen qstart qend sstart send evalue bitscore sallgi" -out ${OUTPUT}
# done
