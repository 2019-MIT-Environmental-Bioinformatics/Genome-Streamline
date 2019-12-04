#!/bin/bash
#SBATCH --partition=compute         # Queue selection
#SBATCH --job-name=get_GOS       # Job name
#SBATCH --mail-type=END             # Mail events (BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=ztobias@whoi.edu  # Where to send mail
#SBATCH --ntasks=1                  # Run on a single CPU
#SBATCH --mem=1gb                   # Job memory request
#SBATCH --time=02:00:00             # Time limit hrs:min:sec
#SBATCH --output=get_GOS_%j.log  # Standard output/error
 
pwd; hostname; date
 
curl ftp://ftp.imicrobe.us/projects/26/CAM_PROJ_GOS.read.fa.gz --output GOS_reads.fa.gz #fetch reads from iMicrobe
 
date
