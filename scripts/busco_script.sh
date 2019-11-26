#!/bin/bash
#SBATCH --partition=compute             # Queue selection
#SBATCH --job-name=busco           # Job name
#SBATCH --mail-type=END                 # Mail events (BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=cberger@whoi.edu  # Where to send mail
#SBATCH --ntasks=1                      # Run on a single CPU
#SBATCH --cpus-per-task=10               # Use x cores on node
#SBATCH --mem=1gb                     # Job memory request
#SBATCH --time=6:00:00                  # Time limit hrs:min:sec
#SBATCH --output=busco_%j.log           # Standard output/error

export OMP_NUM_THREADS=10

module load bio
module load bio hmmer blast augustus

export PATH="/vortexfs1/apps/bio/augustus-3.1.1/bin:$PATH"
export PATH="/vortexfs1/apps/bio/augustus-3.1.1/source/augustus-3.3.1/scripts:$PATH"
export AUGUSTUS_CONFIG_PATH="/vortexfs1/omics/env-bio/collaboration/genome-streamlining/Genome-Streamline/envs/busco/config/"

path_to_busco="/vortexfs1/omics/env-bio/collaboration/genome-streamlining/Genome-Streamline/envs/busco/busco"
path_to_data="/vortexfs1/omics/env-bio/collaboration/genome-streamlining/data"

#Does busco on nucleotide genomes, all against bacteria 

for file in $(find /vortexfs1/omics/env-bio/collaboration/genome-streamlining/data/SAGs/ -name *fna.gz)
do
	file_name=$(basename ${file} .fna.gz)
	gunzip ${file}
	python ${path_to_busco}/scripts/run_BUSCO.py -i ${file%.*} -o ${file_name}_busco -l ${path_to_data}/busco/bacteria_odb9 -m geno -c 10
	gzip ${file%.*}
done

##then do busco for specific groups: 
for file in $(find /vortexfs1/omics/env-bio/collaboration/genome-streamlining/data/SAGs/alphaproteobacteria -name *fna.gz)
do
	file_name=$(basename ${file} .fna.gz)
	gunzip ${file}
	python ${path_to_busco}/scripts/run_BUSCO.py -i ${file%.*} -o ${file_name}_busco_proteo -l ${path_to_data}/busco/proteobacteria_odb9 -m geno -c 10
	gzip ${file%.*}
done

for file in $(find /vortexfs1/omics/env-bio/collaboration/genome-streamlining/data/SAGs/gammaproteobacteria -name *fna.gz)
do
	file_name=$(basename ${file} .fna.gz)
	gunzip ${file}
	python ${path_to_busco}/scripts/run_BUSCO.py -i ${file%.*} -o ${file_name}_busco_gamma -l ${path_to_data}/busco/gammaproteobacteria_odb9 -m geno -c 10
	gzip ${file%.*}
done

for file in $(find /vortexfs1/omics/env-bio/collaboration/genome-streamlining/data/SAGs/bacteroidetes -name *fna.gz)
do
	file_name=$(basename ${file} .fna.gz)
	gunzip ${file}
	python ${path_to_busco}/scripts/run_BUSCO.py -i ${file%.*} -o ${file_name}_busco_bacteroidetes -l ${path_to_data}/busco/bacteroidetes_odb9 -m geno -c 10
	gzip ${file%.*}
done

for file in $(find /vortexfs1/omics/env-bio/collaboration/genome-streamlining/data/SAGs/actinobacteria -name *fna.gz)
do
	file_name=$(basename ${file} .fna.gz)
	gunzip ${file}
	python ${path_to_busco}/scripts/run_BUSCO.py -i ${file%.*} -o ${file_name}_busco_actino -l ${path_to_data}/busco/actinobacteria_odb9 -m geno -c 10
	gzip ${file%.*}
done

######################################

#Does busco on predicted proteins:
for file in $(find /vortexfs1/omics/env-bio/collaboration/genome-streamlining/data/Proteins/ -name *faa)
do
	file_name=$(basename ${file} .faa)
	python ${path_to_busco}/scripts/run_BUSCO.py -i ${file%.*} -o ${file_name}_busco -l ${path_to_data}/busco/bacteria_odb9 -m prot -c 10
done

##then do busco for specific groups: 
for file in $(find /vortexfs1/omics/env-bio/collaboration/genome-streamlining/data/SAGs/alphaproteobacteria -name *fna.gz)
do
	file_name=$(basename ${file} .fna.gz)
	python ${path_to_busco}/scripts/run_BUSCO.py -i ${path_to_data}/Proteins/${file_name}_proteins.faa -o ${file_name}_busco_proteo_prot -l ${path_to_data}/busco/proteobacteria_odb9 -m prot -c 10
done

for file in $(find /vortexfs1/omics/env-bio/collaboration/genome-streamlining/data/SAGs/gammaproteobacteria -name *fna.gz)
do
	file_name=$(basename ${file} .fna.gz)
	python ${path_to_busco}/scripts/run_BUSCO.py -i ${file%.*} -o ${file_name}_busco_gamma_prot -l ${path_to_data}/busco/gammaproteobacteria_odb9 -m prot -c 10
done

for file in $(find /vortexfs1/omics/env-bio/collaboration/genome-streamlining/data/SAGs/bacteroidetes -name *fna.gz)
do
	file_name=$(basename ${file} .fna.gz)
	python ${path_to_busco}/scripts/run_BUSCO.py -i ${file%.*} -o ${file_name}_busco_bacteroidetes_prot -l ${path_to_data}/busco/bacteroidetes_odb9 -m prot -c 10
done

for file in $(find /vortexfs1/omics/env-bio/collaboration/genome-streamlining/data/SAGs/actinobacteria -name *fna.gz)
do
	file_name=$(basename ${file} .fna.gz)
	python ${path_to_busco}/scripts/run_BUSCO.py -i ${file%.*} -o ${file_name}_busco_actino_prot -l ${path_to_data}/busco/actinobacteria_odb9 -m prot -c 10
done

