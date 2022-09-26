# Seiber's POD method along with input data conversion to CGNS format.
POD modules of this code is forked from the repo hugolui/ROM_code and a data converter from MAT2CGNS is appended.

Author:
    Amal Roy Murali,
    LMFA, Ecole Centrale Lyon,   
    Lyon, France.

This folder contains the code for reusing Seiber's POD as used in Wolf ROM model.

To use a new matlab file as input, place the matlab file in the MAT2CGNS/MAT folder.

Make sure that all the data in this MAT file is in double precision, and follows the same variable name and order as in the file MAT2CGNS/MAT/SP7_test_all_tstep.mat

Then inside the MAT2CGNS folder, insert the file name in the script run_convert.sh
    
   On Line 4
   Ln4: ./mat2cgns.exe __file_name__

Then run

	$ sh run_convert.sh

A successfull conversion will lead to output similar to MAT2CGNS/sample_output.txt. Resulting files are in the MAT2CGNS/CGNS folder.

Once files are converted, the POD algorithm can be used. For this goto pod folder.

then run

	$ sh compileOpt.sh
	$ ./pod

A successfull run will lead to output similar to pod/output.log
This will generate the POD modes in a CGNS file names pod/POD_modes.cgns

The resulting modes can be seen using ParaView.

Further plots and results are generated in the pod/figs and pod/SVD_files folders.

If once alogrithm runs as expected, a complete converion>pod can be done using the script available at pod/run.sh

Good luck!

