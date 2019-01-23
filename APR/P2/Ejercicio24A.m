
%En el ejemplo “Sprinkler”, repetir los procesos de aprendizaje a partir de datos
%completos y de datos incompletos explicados en la Sec.2.3, usando un numero mucho
%mayor de muestras de aprendizaje (por ejemplo, nMuestras = 1000), asi como
%permitiendo un mayor numero de iteraciones. Comentar los resultados obtenidos.


addpath('~/asigDSIC/ETSINF/apr/p2/BNT')
addpath(genpathKPM('~/asigDSIC/ETSINF/apr/p2/BNT'))
N = 4; C = 1; S = 2; R= 3; W = 4;
grafo = zeros(N,N);
grafo(C,[R S]) = 1;
grafo(R,W) = 1;
grafo(S,W) = 1;
draw_graph(grafo);
nodosDiscretos = 1:N;
tallaNodos = 2 * ones(1,N);
redB = mk_bnet(grafo,tallaNodos,'discrete',nodosDiscretos);
redB.CPD{W} = tabular_CPD(redB, W, [1.0 0.1 0.1 0.01 0.0 0.9 0.9 0.99]);
redB.CPD{C} = tabular_CPD(redB, C, [0.5 0.5]);
redB.CPD{S} = tabular_CPD(redB, S, [0.5 0.9 0.5 0.1]);
redB.CPD{R} = tabular_CPD(redB, R, [0.8 0.2 0.2 0.8]);
%Aprendizaje a partir de datos completos
semilla = 0; 
rng(semilla); 
nMuestras = 1000; % generamos 1000 muestras aleatorias
muestras = cell(N, nMuestras);
for i=1:nMuestras
    muestras(:,i) = sample_bnet(redB);
end
%estructura de la nueva red
redAPR = mk_bnet(grafo, tallaNodos);
redAPR.CPD{C} = tabular_CPD(redAPR, C);
redAPR.CPD{R} = tabular_CPD(redAPR, R);
redAPR.CPD{S} = tabular_CPD(redAPR, S);
redAPR.CPD{W} = tabular_CPD(redAPR, W);
redAPR2 = learn_params(redAPR,muestras);
TPCaux = cell(1,N);
%mostramos las probabilidades estimadas
for i=1:N 
    s=struct(redAPR2.CPD{i});
    TPCaux{i}=s.CPT;
end
disp("W")
dispcpt(TPCaux{W})
disp("S")
dispcpt(TPCaux{S})
disp("C")
dispcpt(TPCaux{C})
disp("R")
dispcpt(TPCaux{R})

%Aprendizaje con datos incompletos
muestrasS = muestras;
semilla = 0; rng(semilla);
ocultas = rand(N, nMuestras) > 0.5;
[I,J] = find(ocultas);
for k=1:length(I) 
    muestrasS{I(k), J(k)} = [];
end
redEM = mk_bnet(grafo, tallaNodos, 'discrete', nodosDiscretos);
redEM.CPD{C} = tabular_CPD(redEM, C);
redEM.CPD{R} = tabular_CPD(redEM, R);
redEM.CPD{S} = tabular_CPD(redEM, S);
redEM.CPD{W} = tabular_CPD(redEM, W);
motorEM = jtree_inf_engine(redEM);
maxIter = 10000; eps = 1e-4;
semilla = 0; rng(semilla);
[redEM2, trazaLogVer] = learn_params_em(motorEM, muestrasS, maxIter, eps);
auxTPC = cell(1,N);
for i=1:N 
    s=struct(redEM2.CPD{i}); auxTPC{i}=s.CPT;
end
dispcpt(auxTPC{S})