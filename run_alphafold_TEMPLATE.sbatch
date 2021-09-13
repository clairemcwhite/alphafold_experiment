#!/bin/bash
#SBATCH --job-name=JOBNAME        # create a short name for your job
#SBATCH --nodes=1                # node count
#SBATCH --ntasks=1               # total number of tasks across all nodes
#SBATCH --cpus-per-task=8        # cpu-cores per task (>1 if multi-threaded tasks)
#SBATCH --mem-per-cpu=4G         # memory per cpu-core (4G is default)
#SBATCH --gres=gpu:1             # number of gpus per node
#SBATCH --time=24:00:00          # total run time limit (HH:MM:SS)
#SBATCH --mail-type=begin        # send email when job begins
#SBATCH --mail-type=end          # send email when job ends
#SBATCH --mail-user=cmcwhite@princeton.edu

module purge
module load anaconda3/2020.11
module load cudatoolkit

#conda activate hf-transformers

nvidia-smi

ALPHADATA=/scratch/gpfs/cmcwhite/alphafold_data
ALPHASINGU=/scratch/gpfs/cmcwhite/alphafold_latest.sif

bash alphafold_command.sh FASTAFILE OUTPUTDIR $ALPHADATA $ALPHASINGU

