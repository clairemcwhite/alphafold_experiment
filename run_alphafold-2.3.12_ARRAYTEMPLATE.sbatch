#!/bin/bash
#SBATCH --job-name=COMMANDFILE       # create a short name for your job
#SBATCH --nodes=1                # node count
#SBATCH --ntasks=1               # total number of tasks across all nodes
#SBATCH --cpus-per-task=1        # cpu-cores per task (>1 if multi-threaded tasks)
#SBATCH --mem-per-cpu=64G         # memory per cpu-core (4G is default)
#SBATCH --time=48:00:00          # total run time limit (HH:MM:SS)
#SBATCH --gres=gpu:1            # number of gpus per node
#SBATCH --mail-type=begin        # send email when job begins
#SBATCH --mail-type=end          # send email when job ends
#SBATCH --mail-user=USER@princeton.edu
#SBATCH --array=[1-NUMJOBS]
#SBATCH --output="command_array_k-%A-%a.out"
module purge
module load anaconda3/2020.11
module load cudatoolkit


module use /projects/MOLBIO/Modules/modulefiles-rhel8
module load alphafold/2.3.1

command=$(sed -n "$SLURM_ARRAY_TASK_ID"p COMMANDFILE)
echo $command
echo $SLURM_ARRATH_TASK
srun $command


