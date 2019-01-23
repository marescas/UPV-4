%1 Desarrollar un script que implemente dicha red
addpath('~/asigDSIC/ETSINF/apr/p2/BNT')
addpath(genpathKPM('~/asigDSIC/ETSINF/apr/p2/BNT'))
N = 5; %numero de nodos
P = 1; %Polucion
F = 2; %Fumador
C =  3; %Cancer
R = 4; %Rayos X
D = 5; %Disnea
%Grafo red bayesiana
grafo = zeros(N,N);
grafo(P,C) = 1;
grafo(F,C) = 1;
grafo(C,[R,D]) = 1;
draw_graph(grafo);
nodosDiscretos = 1:N;
tallaNodos = 2 * ones(1,N);
tallaNodos(R) =3; % Rayos X tiene 3 posibles estados Negativo, dudoso y positivo
redB = mk_bnet(grafo,tallaNodos,'discrete',nodosDiscretos);
redB.CPD{P} = tabular_CPD(redB, P, [0.9 0.1]);
redB.CPD{F} = tabular_CPD(redB, F, [0.7 0.3]);
redB.CPD{R} = tabular_CPD(redB, R, [0.8 0.1 0.1 0.2 0.1 0.7]);
redB.CPD{D} = tabular_CPD(redB, D, [0.7 0.35 0.3 0.65]);
redB.CPD{C} = tabular_CPD(redB, C, [0.999 0.97 0.95 0.92 0.001 0.03 0.05 0.08]);
evidencia = cell(1,N);
evidencia{F} = 1; %No fumador
evidencia{R} = 1; % No Rayos X
evidencia{D} = 2; % Disnea
motor = jtree_inf_engine(redB);
[motor,logverosim] = enter_evidence(motor,evidencia);
m = marginal_nodes(motor,C); %¿Tiene cancer?
m.T
motor = jtree_inf_engine(redB);
evidencia = cell(1,N);
evidencia{C} = 2; %Tiene cancer
[explicacionmProbable,logVerosim] = calc_mpe(motor,evidencia)