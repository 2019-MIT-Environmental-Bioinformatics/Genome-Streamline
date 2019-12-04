#!/bin/bash
#SBATCH --partition=compute         	# Queue selection
#SBATCH --job-name=frag_recruit_step1       	# Job name
#SBATCH --mail-type=END             	# Mail events (BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=ztobias@whoi.edu  # Where to send mail
#SBATCH --ntasks=1                  	# Run on a single CPU
#SBATCH --cpus-per-task=1		# Use x cores on node
#SBATCH --mem=10gb                   	# Job memory request
#SBATCH --time=00:30:00             	# Time limit hrs:min:sec
#SBATCH --output=../logs/frag_recruit_step1_%j.log  	# Standard output/error

date

module load anaconda
source activate bbtools

export SAG_DIR=/vortexfs1/omics/env-bio/collaboration/genome-streamlining/data/SAGs #specify directory containing SAGs
export RNA_DIR=/vortexfs1/omics/env-bio/collaboration/genome-streamlining/data/rRNAs #specify directory containing rRNA sequences
export MG_DIR=/vortexfs1/omics/env-bio/collaboration/genome-streamlining/data/metagenomes_filtered #specify directory containing the filtered metagenomes
mkdir /vortexfs1/omics/env-bio/collaboration/genome-streamlining/data/frag_recruit #make new directory for fragment recruitment
export FR_DIR=/vortexfs1/omics/env-bio/collaboration/genome-streamlining/data/frag_recruit #specify directory for fragment recruitment

#mapping and masking of rRNA genes in reference
for file in $(find ${RNA_DIR} -name *.fna) #loop over all predicted rRNA fasta files
do
    filename=$(basename ${file} _rrna.fna) #get basename and strip extension
    genome_path=$(find ${SAG_DIR} -name ${filename}.fna.gz) #get path to reference genome
    if [[ "${genome_path}" =~ too_small ]] #if too_small is in the filepath (meaning the genome wasn't used for frag recruitment)
    then
        : #don't do anything
    else
        bbmap.sh in=${file} ref=${genome_path} out=${FR_DIR}/${filename}_rRNA.sam nodisk=t perfectmode=t #map the rRNAs to reference
        bbmask.sh in=${genome_path} out=${FR_DIR}/${filename}_masked.fna sam=${FR_DIR}/${filename}_rRNA.sam lowercase=t mle=f #mask the rRNA, making all rDNA sequences lowercase
    fi
    rm ${FR_DIR}/*.sam #delete the sam file
done

conda deactivate

#removing sequences less than 2000bp from SAGs

source activate seqkit

seqkit stats ${FR_DIR}/*.fna > ${FR_DIR}/SAG_stats_prefilter.txt #get stats

for SAG in $(ls ${FR_DIR}/*.fna) #loop through the masked SAG sequences
do
    SAG_name=$(basename ${SAG} _masked.fna) #get filename
    cat ${SAG} | seqkit seq -m 2000 > ${FR_DIR}/${SAG_name}_filtered.fna #remove all sequences shorter than 2000bp and write
    rm ${SAG} #delete unfiltered SAG sequence
done

seqkit stats ${FR_DIR}/*.fna >> ${FR_DIR}/SAG_stats_postfilter.txt #get new stats

conda deactivate

#ideally there would be a part of the pipeline that fills in the ITS with lcase. complicated because sometimes multiple copies of rRNA cassette, spanning across contigs, etc. Can't seem to find a way to do this with bbtools. Would require custom script. The ITS regions are pretty short and recruitment to them probably would not skew results much (especially considering all of the other problems with our dataset.

#blasting of filtered metagenomes against masked SAGs

#see other script --> frag_recruit_step2.sh