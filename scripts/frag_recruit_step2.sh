#!/bin/bash
#SBATCH --partition=compute         	# Queue selection
#SBATCH --job-name=frag_recruit_step2       	# Job name
#SBATCH --mail-type=END             	# Mail events (BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=ztobias@whoi.edu  # Where to send mail
#SBATCH --ntasks=1                  	# Run on a single CPU
#SBATCH --cpus-per-task=35		# Use x cores on node
#SBATCH --mem=186gb                   	# Job memory request
#SBATCH --time=24:00:00             	# Time limit hrs:min:sec
#SBATCH --output=../logs/frag_recruit_step2_%A-%a.log  	# Standard output/error
#SBATCH --array=1-41

date

export OMP_NUM_THREADS=35 #specify number of threads

export SAG_DIR=/vortexfs1/omics/env-bio/collaboration/genome-streamlining/data/SAGs #specify directory with filtered SAG sequences
export RNA_DIR=/vortexfs1/omics/env-bio/collaboration/genome-streamlining/data/rRNAs #specify directory with rRNA sequences
export MG_DIR=/vortexfs1/omics/env-bio/collaboration/genome-streamlining/data/metagenomes_filtered #specify directory with metagenome sequences
export FR_DIR=/vortexfs1/omics/env-bio/collaboration/genome-streamlining/data/frag_recruit #specify directory for fragment recruitment

module load anaconda
source activate blast_2.2.31

export BLASTDB=${FR_DIR} #tell blast where to look for blast databases

RUN_ID=$SLURM_ARRAY_TASK_ID #assign array task ID to new variable
REF_FILE=$( ls ${FR_DIR}/*_filtered.fna | sed -n ${RUN_ID}p ) #use RUN_ID to specify which SAG to use as reference in current array task

dbname=$(basename ${REF_FILE} _filtered.fna) #get filename
convert2blastmask -in ${REF_FILE} -masking_algorithm other -masking_options "rRNAs" -parse_seqids -outfmt maskinfo_asn1_bin -out ${FR_DIR}/${dbname}_maskinfo.asnb #take FASTA file with lowercase and use that info to create masking file
makeblastdb -in ${REF_FILE} -out ${FR_DIR}/${dbname} -mask_data ${FR_DIR}/${dbname}_maskinfo.asnb -dbtype nucl -parse_seqids -title "${dbname}" #make blast database using the masking file generated in previous step
for query in $(ls ${MG_DIR}) #loop through the filtered metagenomes
do
    query_name=$(basename ${query} _filtered.fa.gz) #get filename
    gzip -dc ${MG_DIR}/${query} | blastn -db ${dbname} -evalue 0.0001 -reward 1 -penalty -1 -gapopen 3 -gapextend 2 -db_hard_mask 100 -max_target_seqs 1 -max_hsps 1 -xdrop_gap 150 -outfmt 6 -num_threads 35 -out ${FR_DIR}/${query_name}.${dbname}.tsv #blast against SAG. gap open and extension defaults incompatible with reward/penalty. Set to 3/2. The -soft_masking and -lcase_masking flags are not necessary because they mask the query, not db
done
rm ${FR_DIR}/${dbname}.n* #remove any blastdb files
rm ${FR_DIR}/${dbname}.asnb #remove masking file
rm ${FR_DIR}/${REF_FILE} #remove the filtered SAG file

date