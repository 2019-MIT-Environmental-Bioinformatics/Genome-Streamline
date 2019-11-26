#!/bin/bash
#SBATCH --job-name=BatchBLAST             # Job name
#SBATCH --mail-type=END                   # Mail events (BEGIN, END, FAIL, ALL, ARRAY_TASKS)
#SBATCH --mail-user=ngermolus@whoi.edu    # Where to send mail
#SBATCH --ntasks=1                        # Run a single task
#SBATCH --mem=100gb                       # Job Memory
#SBATCH --time=6:00:00                    # Time limit hrs:min:sec
#SBATCH --output=array_%A-%a.log          # Standard output and error log
#SBATCH --array=1-56                      # Array range
 
pwd; hostname; date

module load bio blast

export INPUT_DIR="/vortexfs1/omics/env-bio/collaboration/genome-streamlining/data/Proteins/"
export OUTPUT_DIR="/vortexfs1/omics/env-bio/collaboration/genome-streamlining/data/SAG_Blastp/"
export LOG_DIR="/vortexfs1/omics/env-bio/collaboration/genome-streamlining/Genome-Streamline/logs"


 
echo This is task $SLURM_ARRAY_TASK_ID


 
date
