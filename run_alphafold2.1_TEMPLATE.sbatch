#!/bin/bash
#SBATCH --job-name=JOBNAME        # create a short name for your job
#SBATCH --nodes=1                # node count
#SBATCH --ntasks=1               # total number of tasks across all nodes
#SBATCH --cpus-per-task=8        # cpu-cores per task (>1 if multi-threaded tasks)
#SBATCH --mem-per-cpu=16G         # memory per cpu-core (4G is default)
#SBATCH --gres=gpu:1             # number of gpus per node
#SBATCH --time=24:00:00          # total run time limit (HH:MM:SS)


module use /projects/MOLBIO/Modules/modulefiles-rhel8
module load alphafold/2.1.1

fasta=FASTAFILE
outdir=OUTPUTDIR
time run_alphafold.sh \
                 -f $fasta \
                 -o $outdir \
                 -d /scratch/gpfs/DATASETS/alphafold/2021-11-22 \
                 -m multimer \
                 -t 2021-11-22 \
                 -g \
                 -a 0 \
                 -n 8 \
                 -p reduced_dbs

rm $outdir/*pkl
rm -r $outdir/msas

