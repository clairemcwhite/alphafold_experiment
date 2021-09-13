
OUTPUT_DIR=$( pwd )/output_alphafold


echo $OUTPUT_DIR
for f in $( pwd )/fastas/*fasta; do OUTFILE=run_alphafold_${f##*/}.sbatch; sed "s@FASTAFILE@$f@" run_alphafold_TEMPLATE.sbatch | sed "s@OUTPUTDIR@$OUTPUT_DIR@" | sed "s@JOBNAME@${f##*/}@" > $OUTFILE; done
