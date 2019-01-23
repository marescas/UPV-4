graphics_toolkit gnuplot;
load("data/usps/tr.dat") #tr
load("data/usps/trlabels.dat")#trlabels
#Extraemos los datos de las clases 0 a 3
datos = tr(trlabels < 4,:);
trlabelss = trlabels(trlabels<4, :);
#Barajamos las filas y cogemos un conjunto para train y otro para test
[N,L] = size(datos);
rand("seed",23);
perm = randperm(N); #permutación de filas
data=tr(perm,:); #aplicamos la permutación a los datos
#aplicamos la permutación a las etiquetas
datalabels = trlabelss(perm,:);
NTr=round(.4*N); #extraemos 70% para train
traindata = data(1:NTr,:);
trainlabels = datalabels(1:NTr,:);
tedata=data(NTr+1:N,:); # 30% para test
telabels = datalabels(NTr+1:N,:);
for i = 0:3
	for j = i+1: 3
		#clasificadores binarios clase i vs j
		localdata = [traindata(trainlabels == i,:);
		 traindata(trainlabels ==j,:)];
		locallabels = [trainlabels(trainlabels ==i,:);
		 trainlabels(trainlabels ==j,:)];
		res = svmtrain(locallabels,localdata,"-q -t 0 -c 1000");
		if i == 0
		 	clasificadores(j)= res;
		else
			clasificadores(i+j+1) = res;
		endif
	endfor
endfor
disp("Entrenado con exito modelo votacion")
for i = 1:6
	#almacenamos la prediccion para cada clasificador
	[prediction, accuracy, decision_values] = svmpredict(telabels,
		tedata,clasificadores(i),"-q");
	prediccion(:,i) = prediction;
endfor
[Filas,Columnas] = size(prediccion);
contador = zeros(Filas,4);
#contamos cuantas veces aparece la clase j [0..3] en cada fila
for i = [1:Filas]
	for j = [1:4]
		contador(i,j) = sum(prediccion(i,:) ==j-1);
endfor
endfor
#La clase asignada será la más votada...
[value,pos] = max(contador');
mis_etiquetas = pos-1;
aciertoVotacion = sum(mis_etiquetas' == telabels)/length(telabels)
intervaloVotacion = 1.96* sqrt((aciertoVotacion * (1-aciertoVotacion))/
length(telabels))
disp("DAGS")

for d = [1:length(telabels)]
	inferior = 0;
	superior = 3;
	mi_clasificador = -1;
	while (inferior +1 != superior)
		if inferior == 0
			mi_clasificador = superior;
		else
			mi_clasificador = inferior+superior+1;
		endif
		prediccion =  svmpredict(telabels(d,:),tedata(d,:),
		clasificadores(mi_clasificador),"-q");
		if prediccion != superior
			superior--;
		else
			inferior++;
		endif

	endwhile
	if inferior == 0
		mi_clasificador = superior;
	else
		mi_clasificador = inferior+superior+1;
	endif
	predicciones(d) = svmpredict(telabels(d,:),tedata(d,:),
	clasificadores(mi_clasificador),"-q");

endfor
aciertoDAG = sum(predicciones' == telabels)/length(telabels)
intervaloDAG = 1.96* sqrt((aciertoDAG * (1-aciertoDAG))/
length(telabels))
