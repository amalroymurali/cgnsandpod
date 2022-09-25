clear
load RAWDATA/SP7_test.mat
P=permute(P_ij, [3,1,2]);
P=reshape(P,[size(P,1),5100]);

T=t;
X=x_ij;
Y=y_ij;

P=double(P);
T=double(T);
X=double(X);
Y=double(Y);

save(sprintf('MAT/SP7_test_all_tstep'),...
    'P', 'T', 'X', 'Y')
