set -e
gfortran mod_write_cgns.f script.f -ffree-line-length-none -I /usr/local/include -L /usr/local/lib -I/usr/local/MATLAB/R2022a/extern/include -L/usr/local/MATLAB/R2022a/bin/glnxa64 -cpp -lcgns -lmat -lmx -Wl,-rpath /usr/local/MATLAB/R2022a/bin/glnxa64/ -o mat2cgns.exe 

./mat2cgns.exe MAT/SP7_test_all_tstep.mat
mv ./*.cgns CGNS/
