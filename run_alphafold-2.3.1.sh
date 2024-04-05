#!/bin/bash
# Description: AlphaFold non-docker version
# Author: Sanjay Kumar Srikakulam

# Changes, Matthew Cahn, 11/16/2021
#   Find run_alphafold.py by PATH (not in the current directory).
#   Change the model_names flag to model_preset.
#   Use a newer version of the uniclust30 database.
#   If -g is supplied, set use_gpu to true, instead of to the following argument, since there isn't one.
#   If processing a multimer, omit the pdb70 database, and include pdb_seqres and uniprot.

usage() {
        echo ""
        echo "Please make sure all required parameters are given"
        echo "Usage: $0 <OPTIONS>"
        echo "Required Parameters:"
        echo "-d <data_dir>     Path to directory of supporting data"
        echo "-o <output_dir>   Path to a directory that will store the results."
        echo "-m <model_names>  Names of models to use (a comma separated list)"
        echo "-f <fasta_path>   Path to a FASTA file containing one sequence"
        echo "-t <max_template_date> Maximum template release date to consider (ISO-8601 format - i.e. YYYY-MM-DD). Important if folding historical test sets"
        echo "Optional Parameters:"
        echo "-n <openmm_threads>   OpenMM threads (default: all available cores)"
        echo "-b                    Run multiple JAX model evaluations to obtain a timing that excludes the compilation time, which should be more indicative of the time required for inferencing many proteins (default: 'False')"
        echo "-g <use_gpu>      Enable NVIDIA runtime to run with GPUs (default: True)"
        echo "-a <gpu_devices>  Comma separated list of devices to pass to 'CUDA_VISIBLE_DEVICES' (default: 0)"
        echo "-p <preset>       Choose preset model configuration - no ensembling and smaller genetic database config (reduced_dbs), no ensembling and full genetic database config  (full_dbs) or full genetic database config and 8 model ensemblings (casp14)"
	echo "-j <num_pred>     Number of predictions per multimer model (default:5)"
	echo "-x <norelax>      Turn off the final relaxation step on the predicted models (default: true)"
        echo ""
        exit 1
}

while getopts ":d:o:m:f:t:g:n:a:p:b:j:x:" i; do
        case "${i}" in
        d)
                data_dir=$OPTARG
        ;;
        o)
                output_dir=$OPTARG
        ;;
        m)
                model_names=$OPTARG
        ;;
        f)
                fasta_path=$OPTARG
        ;;
        t)
                max_template_date=$OPTARG
        ;;
        g)
                use_gpu=true
        ;;
        n)
                openmm_threads=$OPTARG
        ;;
        a)
                gpu_devices=$OPTARG
        ;;
        p)
                preset=$OPTARG
        ;;
        j)
                num_pred=$OPTARG
        ;;
        x)
                norelax=true
        ;;
        b)
                benchmark=true
        ;;
        esac
done

# Parse input and set defaults
if [[ "$data_dir" == "" || "$output_dir" == "" || "$model_names" == "" || "$fasta_path" == "" || "$max_template_date" == "" ]] ; then
    usage
fi

if [[ "$benchmark" == "" ]] ; then
    benchmark=false
fi

if [[ "$use_gpu" == "" ]] ; then
    use_gpu=true
fi

if [[ "$gpu_devices" == "" ]] ; then
    gpu_devices=0
fi

if [[ "$preset" == "" ]] ; then
    preset="full_dbs"
fi

if [[ "$norelax" ]]; then
    echo norelax: $norelax
    norelax=true
fi

if [[ "$preset" != "full_dbs" && "$preset" != "casp14" && "$preset" != "reduced_dbs" ]] ; then
    echo "Unknown preset! Using default ('full_dbs')"
    preset="full_dbs"
fi


# Export ENVIRONMENT variables and set CUDA devices for use
# CUDA GPU control
export CUDA_VISIBLE_DEVICES=-1

echo use_gpu: $use_gpu
echo gpu_devices: $gpu_devices

if [[ "$use_gpu" == true ]] ; then
    export CUDA_VISIBLE_DEVICES=0

    if [[ "$gpu_devices" ]] ; then
        export CUDA_VISIBLE_DEVICES=$gpu_devices
    fi
fi

echo CUDA_VISIBLE_DEVICES: $CUDA_VISIBLE_DEVICES

echo openmm_threads: $openmm_threads

# OpenMM threads control
if [[ "$openmm_threads" ]] ; then
    export OPENMM_CPU_THREADS=$openmm_threads
fi

# TensorFlow control
export TF_FORCE_UNIFIED_MEMORY='1'

# JAX control
export XLA_PYTHON_CLIENT_MEM_FRACTION='4.0'

# Path and user config (change me if required)
bfd_database_path="$data_dir/bfd/bfd_metaclust_clu_complete_id30_c90_final_seq.sorted_opt"
small_bfd_database_path="$data_dir/small_bfd/bfd-first_non_consensus_sequences.fasta"
mgnify_database_path="$data_dir/mgnify/mgy_clusters.fa"
template_mmcif_dir="$data_dir/pdb_mmcif/mmcif_files"
obsolete_pdbs_path="$data_dir/pdb_mmcif/obsolete.dat"
pdb70_database_path="$data_dir/pdb70/pdb70"
uniref30_database_path="$data_dir/uniref30/UniRef30_2021_03"
uniref90_database_path="$data_dir/uniref90/uniref90.fasta"
pdb_seqres_database_path="$data_dir/pdb_seqres/pdb_seqres.txt"
uniprot_database_path="$data_dir/uniprot/uniprot.fasta"

# Binary path (change me if required)
hhblits_binary_path=$(which hhblits)
hhsearch_binary_path=$(which hhsearch)
jackhmmer_binary_path=$(which jackhmmer)
kalign_binary_path=$(which kalign)

# Run AlphaFold with required parameters
# 'reduced_dbs' preset does not use bfd and uniclust30 databases
if [[ "$model_names" == "multimer" ]]; then
    pdb70_arg=""
    pdb_seqres_arg="--pdb_seqres_database_path=$pdb_seqres_database_path"
    uniprot_arg="--uniprot_database_path=$uniprot_database_path"
else
    pdb70_arg="--pdb70_database_path=$pdb70_database_path"
    pdb_seqres_arg=""
    uniprot_arg=""
fi

if [[ "$norelax" ]]; then
    relax_arg="--norun_relax"
    use_gpu_relax_arg="--nouse_gpu_relax"
else
    relax_arg="--run_relax"
    use_gpu_relax_arg="--use_gpu_relax"
fi

echo relax_arg: $relax_arg
echo pdb70_arg: $pdb70_arg
echo pdb_seqres_arg: $pdb_seqres_arg
echo uniprot_arg: $uniprot_arg
echo pdb_seqres_database_path: $pdb_seqres_database_path

if [[ "$preset" == "reduced_dbs" ]]; then
    echo run_alphafold.py \
    --hhblits_binary_path=$hhblits_binary_path \
    --hhsearch_binary_path=$hhsearch_binary_path \
    --jackhmmer_binary_path=$jackhmmer_binary_path \
    --kalign_binary_path=$kalign_binary_path \
    --small_bfd_database_path=$small_bfd_database_path \
    --mgnify_database_path=$mgnify_database_path \
    --template_mmcif_dir=$template_mmcif_dir \
    --obsolete_pdbs_path=$obsolete_pdbs_path $pdb70_arg \
    --uniref90_database_path=$uniref90_database_path \
    $pdb_seqres_arg \
    $uniprot_arg \
    --data_dir=$data_dir \
    --output_dir=$output_dir \
    --fasta_paths=$fasta_path \
    --model_preset=$model_names \
    --max_template_date=$max_template_date \
    --benchmark=$benchmark \
    --logtostderr \
    --num_multimer_predictions_per_model=5 \
    $relax_arg \
    $use_gpu_relax_arg

    
    run_alphafold.py \
    --hhblits_binary_path=$hhblits_binary_path \
    --hhsearch_binary_path=$hhsearch_binary_path \
    --jackhmmer_binary_path=$jackhmmer_binary_path \
    --kalign_binary_path=$kalign_binary_path \
    --small_bfd_database_path=$small_bfd_database_path \
    --mgnify_database_path=$mgnify_database_path \
    --template_mmcif_dir=$template_mmcif_dir \
    --obsolete_pdbs_path=$obsolete_pdbs_path $pdb70_arg \
    --uniref90_database_path=$uniref90_database_path \
    $pdb_seqres_arg \
    $uniprot_arg \
    --data_dir=$data_dir \
    --output_dir=$output_dir \
    --fasta_paths=$fasta_path \
    --model_preset=$model_names \
    --max_template_date=$max_template_date \
    --benchmark=$benchmark \
    --logtostderr \
    --num_multimer_predictions_per_model=5 \
    $relax_arg \
    $use_gpu_relax_arg
else
    echo run_alphafold.py \
    --hhblits_binary_path=$hhblits_binary_path \
    --hhsearch_binary_path=$hhsearch_binary_path \
    --jackhmmer_binary_path=$jackhmmer_binary_path \
    --kalign_binary_path=$kalign_binary_path \
    --bfd_database_path=$bfd_database_path \
    --mgnify_database_path=$mgnify_database_path \
    --template_mmcif_dir=$template_mmcif_dir \
    --obsolete_pdbs_path=$obsolete_pdbs_path $pdb70_arg \
    --uniref30_database_path=$uniref30_database_path \
    --uniref90_database_path=$uniref90_database_path \
    $pdb_seqres_arg \
    $uniprot_arg \
    --data_dir=$data_dir \
    --output_dir=$output_dir \
    --fasta_paths=$fasta_path \
    --model_preset=$model_names \
    --max_template_date=$max_template_date \
    --benchmark=$benchmark \
    --logtostderr \
    --num_multimer_predictions_per_model=5 \
    $relax_arg \
    $use_gpu_relax_arg

    
    run_alphafold.py \
    --hhblits_binary_path=$hhblits_binary_path \
    --hhsearch_binary_path=$hhsearch_binary_path \
    --jackhmmer_binary_path=$jackhmmer_binary_path \
    --kalign_binary_path=$kalign_binary_path \
    --bfd_database_path=$bfd_database_path \
    --mgnify_database_path=$mgnify_database_path \
    --template_mmcif_dir=$template_mmcif_dir \
    --obsolete_pdbs_path=$obsolete_pdbs_path $pdb70_arg \
    --uniref30_database_path=$uniref30_database_path \
    --uniref90_database_path=$uniref90_database_path \
    $pdb_seqres_arg \
    $uniprot_arg \
    --data_dir=$data_dir \
    --output_dir=$output_dir \
    --fasta_paths=$fasta_path \
    --model_preset=$model_names \
    --max_template_date=$max_template_date \
    --benchmark=$benchmark \
    --logtostderr \
    --num_multimer_predictions_per_model=5 \
    $relax_arg \
    $use_gpu_relax_arg
fi
