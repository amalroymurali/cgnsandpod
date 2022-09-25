#!/bin/bash
set -e
#rm nohup.out
cd ../MAT2CGNS
sh run_convert.sh
cd ../pod
sh clean.sh
sh compileOpt.sh
./pod 
#tail -f nohup.out

