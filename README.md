# Scripts to manage running alphafold2 jobs

### Run one protein

- Make a file containing the fasta formatted sequence of the protein
  -  See fastas/fmg2.fasta as an example of how this file should look
- Copy run_alphafold_single.sbatch to a new filename
  - Ex. cp run_alphafold_single.sbatch run_alphafold_myprot.sbatch
- Open and modify variables in run_alphafold_myprot.sbatch 

### Run multiple proteins with an array job

- Make one fasta formatted file per protein
  -  See fastas/fmg2.fasta as an example of how each file should look

- Make a file containing the names of all the fasta files of proteins you would like to run
  - See example_fastapaths.txt as an example of how this should look

- Use make_alphafold_array_commands.sh script to format sbatch job submission file 
  - change USERNAME to your netid
  - bash make_alphafold_array_commands.sh example_fastapaths.txt USERNAME
  - This creates two files:
    - example_fastapaths_COMMANDS.sh
    - run_alphafold_array_example_fastapaths.sbatch
- Submit job to della
  - bash run_alphafold_array_example_fastapaths.sbatch
