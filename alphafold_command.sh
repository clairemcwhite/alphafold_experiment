fasta=$1
outdir=$2
alphafold_data=$3
alphafold_singularity=$4

singularity run --env NVIDIA_VISIBLE_DEVICES='0',TF_FORCE_UNIFIED_MEMORY=1,XLA_PYTHON_CLIENT_MEM_FRACTION=4.0,OPENMM_CPU_THREADS=8 -B $alphafold_data:/data -B .:/etc --pwd /app/alphafold --nv $alphafold_singularity \
--fasta_paths $fasta \
--output_dir $outdir \
--data_dir /data/ \
--uniref90_database_path /data/uniref90/uniref90.fasta \
--mgnify_database_path /data/mgnify/mgy_clusters_2018_12.fa \
--small_bfd_database_path /data/small_bfd/bfd-first_non_consensus_sequences.fasta \
--pdb70_database_path /data/pdb70/pdb70 \
--template_mmcif_dir /data/pdb_mmcif/mmcif_files \
--obsolete_pdbs_path /data/pdb_mmcif/obsolete.dat \
--max_template_date=2021-07-26 \
--model_names model_1,model_2,model_3,model_4,model_5 \
--preset reduced_dbs
