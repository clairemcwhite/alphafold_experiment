FASTA_LIST=$1
USER=$2
OUTPUTDIR=$( pwd )/output_alphafold
mkdir $OUTPUTDIR

COMMAND_FILE=${FASTA_LIST}_COMMANDS.sh
SBATCH_FILE=run_alphafold_array_${FASTA_LIST}.sbatch

rm $COMMAND_FILE
rm $SBATCH_FILE

NUMJOBS=`wc -l $FASTA_LIST | awk '{print $1}'`
echo $NUMJOBS
while read f
   do
      protname=${f##*/}
      protname=${protname%.fasta}
      fasta=$f
      outdir=$OUTPUTDIR
      echo "bash run_alphafold.sh -f $fasta -o $OUTPUTDIR  -d /scratch/gpfs/DATASETS/alphafold/2021-11-22  -m monomer  -t 2021-11-22  -g  -a 0 -n 8 -p reduced_dbs;rm $OUTPUTDIR/$protname/*pkl; rm -r $OUTPUTDIR/$protname/msas"  >> $COMMAND_FILE 
      
   done < $FASTA_LIST 


sed "s@COMMANDFILE@$COMMAND_FILE@" run_alphafold2_ARRAYTEMPLATE.sbatch | sed "s@USER@$USER@" |  sed "s@NUMJOBS@$NUMJOBS@" > $SBATCH_FILE
