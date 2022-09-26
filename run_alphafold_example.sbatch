#!/bin/bash
#SBATCH --job-name=run_alphafold       # create a short name for your job
#SBATCH --nodes=1                # node count
#SBATCH --ntasks=1               # total number of tasks across all nodes
#SBATCH --cpus-per-task=1        # cpu-cores per task (>1 if multi-threaded tasks)
#SBATCH --mem-per-cpu=64G         # memory per cpu-core (4G is default)
#SBATCH --time=48:00:00          # total run time limit (HH:MM:SS)
#SBATCH --gres=gpu:1            # number of gpus per node
#SBATCH --mail-type=begin        # send email when job begins
#SBATCH --mail-type=end          # send email when job ends
#SBATCH --mail-user=USERNAME@princeton.edu

module purge
module load anaconda3/2020.11
module load cudatoolkit

module use /projects/MOLBIO/Modules/modulefiles-rhel8
module load alphafold/2.1.1

# Arguments to the alphafold function
# FASTAFILE: A path to a single protein sequence in fasta format, see fastas/fmg2.fasta as an example
# OUTPUTDIR: Where to put outfile 
# MODEL: monomor or multimer. If multimer, have more than one protein sequence in the fasta file

# Change to your desired fasta file, output directory, and model type
FASTAFILE=fastas/fmg2.fasta
OUTPUTDIR=$( pwd )
MODEL=monomer


run_alphafold.sh -f $FASTAFILE -o $OUTPUTDIR  -d /scratch/gpfs/DATASETS/alphafold/2021-11-22  -m $MODEL  -t 2022-9-25  -g  -a 0 -n 8 -p reduced_dbs
