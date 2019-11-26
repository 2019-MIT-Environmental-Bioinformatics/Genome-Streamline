#!/bin/bash
#SBATCH --partition=compute         	# Queue selection
#SBATCH --job-name=prinseq_n_cat       	# Job name
#SBATCH --mail-type=END             	# Mail events (BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=ztobias@whoi.edu  # Where to send mail
#SBATCH --ntasks=1                  	# Run on a single CPU
#SBATCH --cpus-per-task=1		# Use x cores on node
#SBATCH --mem=40gb                   	# Job memory request
#SBATCH --time=05:00:00             	# Time limit hrs:min:sec
#SBATCH --output=prinseq_n_cat_%j.log  	# Standard output/error


module load anaconda
source activate prinseq

export INPUT_DIR=/vortexfs1/omics/env-bio/collaboration/genome-streamlining/data/metagenomes
export OUTPUT_DIR=/vortexfs1/omics/env-bio/collaboration/genome-streamlining/data/metagenomes_filtered

#define an object holding the SRA accessions for 454 generated metagenomes 
pyrolist="ERR091522 ERR091523 ERR091524 ERR091525 ERR091526 ERR091527 ERR091528 ERR091529 ERR091530 ERR091531 ERR091532 ERR091533 ERR091534 ERR091535 ERR091536 ERR091537 ERR091538 ERR091539 ERR091540 ERR091541 ERR091542 ERR091543 ERR091544 ERR091553 ERR091554 ERR091555 ERR091556 ERR091557 ERR091558 SRR037008 SRR062129 SRR062131 SRR062132 SRR062134 SRR062135 SRR062139 SRR062140 SRR062141 SRR062142 SRR062145 SRR062146 SRR062147 SRR062148 SRR062150 SRR062151 SRR062153 SRR062154 SRR062155 SRR062156 SRR062157 SRR062160 SRR062161 SRR062162 SRR062163 SRR062166 SRR062167 SRR062168 SRR062169 SRR062170 SRR062171 SRR062172 SRR062188 SRR062189 SRR062190 SRR062191 SRR062192 SRR062193 SRR062196 SRR062197 SRR062198 SRR062201 SRR062202 SRR062203 SRR062204 SRR062205 SRR062206 SRR062207 SRR062208 SRR062210 SRR062211 SRR062212 SRR062213 SRR062214 SRR062217 SRR062220 SRR062221 SRR062222 SRR062223 SRR062224 SRR062225 SRR062226 SRR062227 SRR062228 SRR062229 SRR062231 SRR062232 SRR062233 SRR062234 SRR062235 SRR062237 SRR062238 SRR062239 SRR062240 SRR062250 SRR062251 SRR062252 SRR062253 SRR062254 SRR062255 SRR062256 SRR062257 SRR062258 SRR062259 SRR062260 SRR062261 SRR062262 SRR062263 SRR062264 SRR062268 SRR062275 SRR062625 SRR063385 SRR063388 SRR063390 SRR063767 SRR063769 SRR063770 SRR066138 SRR066139"

fastalist="P4_j P4_f P4_a P26_j P26_a P12_f P12_j P12_a GS001a GS001c GS001b GS000b GS000d GS000c HF10"

for file in `find ${INPUT_DIR} -name *.gz`
do
	filename=$(basename ${file} .gz)
	filename=$(basename ${filename} .fa)
	filename=$(basename ${filename} .fastq) #strip of all possible extensions
	echo "Currently filtering ${filename} and appending to $(basename $(dirname ${file}))_filtered.fa.gz"
	trunc=${filename::-2} #remove the _1 or _2 extensions
	if [[ " ${pyrolist} " =~ .*\ ${trunc}\ .* ]]
    then #if truncated filename matches string in the pyrosequencing list, use entropy filtering:
		gzip -dc ${file} | perl /vortexfs1/home/ztobias/.conda/envs/prinseq/bin/prinseq-lite.pl -fastq stdin -lc_method entropy -lc_threshold 70 -ns_max_n 0 -min_len 100 -derep 12345 -out_format 1 -out_good stdout -out_bad null | gzip >> ${OUTPUT_DIR}/$(basename $(dirname ${file}))_filtered.fa.gz
	elif [[ " ${fastalist} " =~ .*\ ${filename}\ .* ]] #else if it matches fasta list, run with input as fasta w/o entropy
    then
		gzip -dc ${file} | perl /vortexfs1/home/ztobias/.conda/envs/prinseq/bin/prinseq-lite.pl -fasta stdin -ns_max_n 0 -min_len 100 -derep 12345 -out_format 1 -out_good stdout -out_bad null | gzip >> ${OUTPUT_DIR}/$(basename $(dirname ${file}))_filtered.fa.gz
    else #otherwise just do fastq input without entropy
        gzip -dc ${file} | perl /vortexfs1/home/ztobias/.conda/envs/prinseq/bin/prinseq-lite.pl -fastq stdin -ns_max_n 0 -min_len 100 -derep 12345 -out_format 1 -out_good stdout -out_bad null | gzip >> ${OUTPUT_DIR}/$(basename $(dirname ${file}))_filtered.fa.gz
	fi
done
 



