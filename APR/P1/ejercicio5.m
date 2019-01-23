graphics_toolkit gnuplot;
load("data/usps/tr.dat") #tr
load("data/usps/trlabels.dat")#trlabels
load("data/usps/ts.dat") #t
load("data/usps/tslabels.dat")#tslabels

[N,D] = size(ts);
printf("t \t \t C \t \t p \t \t i \n ");
printf("========================================== \n");
for t = 0:3
	for C = [0.01,0.1 , 1, 10, 100, 1000]
		res = svmtrain(trlabels, tr,
			 ["-q -t ", num2str(t), " -c ", num2str(C)] );
		[pred, accuracy, d] = svmpredict(tslabels,ts,res,'-q');
		p = accuracy(1) / 100;
		intervalo = 1.96* sqrt((p * (1-p))/N);
		printf("%d \t %d \t %3f \t %3f   \n",t,C,p,intervalo);

	endfor;
	printf("Cambiando kernel \n");
endfor;
pause;
