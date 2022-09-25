# Seiber's POD method along with input data conversion to CGNS format.

Compiled by:
    Amal Roy Murali,
    LMFA, Ecole Centrale Lyon,
    Lyon, France.

This folder contains the code for reusing Seiber's POD as used in Wolf ROM model.

To use a new matlab file as input, place the matlab file in the MAT2CGNS/MAT folder.

Make sure that all the data in this MAT file is in double precision, and follows the same variable name and order as in the file MAT2CGNS/MAT/SP7_test_all_tstep.mat

Then inside the MAT2CGNS folder, run

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

Hope that helps!

Good luck!

