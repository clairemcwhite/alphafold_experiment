FASTA_LIST=$1
OUTPUT_DIR=$( pwd )/output_alphafold
mkdir $OUTPUT_DIR

while read f
   do
      fp=$f
      protname=${f##*/}
      OUTFILE=run_alphafold_${protname}.sbatch; sed "s@FASTAFILE@$fp@" run_alphafold2.1_TEMPLATE.sbatch | sed "s@OUTPUTDIR@$OUTPUT_DIR@" | sed "s@JOBNAME@$protname@" > $OUTFILE
   done < $FASTA_LIST  
