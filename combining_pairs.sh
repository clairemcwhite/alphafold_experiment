filelist=$1
numU=$2


Us=`head -c $numU < /dev/zero | tr '\0' 'U'`
echo $Us

while read f
 do 
   while read g
   do
    outfile=${f%.fasta}_${numU}U_${g}
    tmp_outfile=${outfile}.tmp
    echo $outfile
    echo $tmp_outfile


    echo ">${f%.fasta}_${g%.fasta}filedelim" > $tmp_outfile

    #echo "XXXXX" >> $tmp_outfile
    grep -v '>' $f >>  $tmp_outfile
    echo $Us >> $tmp_outfile
    grep -v '>' $g >>  $tmp_outfile
    #echo "XXXXX" >> $tmp_outfile

    cat $tmp_outfile | tr -d '\n' | sed 's/filedelim/\n/' > $outfile 
    rm $tmp_outfile
  done < $filelist
done < $filelist
