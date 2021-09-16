FASTA_LIST=$1
OUTPUT_DIR=$( pwd )/output_alphafold


mkdir $OUTPUT_DIR

while read f
   do
      OUTFILE=run_alphafold_${f##*/}.sbatch; sed "s@FASTAFILE@$f@" run_alphafold_TEMPLATE.sbatch | sed "s@OUTPUTDIR@$OUTPUT_DIR@" | sed "s@JOBNAME@${f##*/}@" > $OUTFILE
   done < $FASTA_LIST  
