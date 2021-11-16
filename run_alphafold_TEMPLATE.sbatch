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
#SBATCH --mail-user=vc8200@princeton.edu

module purge
module load anaconda3/2020.11
module load cudatoolkit

nvidia-smi

# Full path to your alphafold_data and alphafold_latest.sif
# Also replace your email address on line 11
DATA=/scratch/gpfs/vc8200/alphafold_data
SINGU=/scratch/gpfs/vc8200/alphafold_latest.sif 

bash alphafold_command.sh FASTAFILE OUTPUTDIR $DATA $SINGU 
rm OUTPUTPATH/*pkl
rm -r OUTPUTPATH/msas

