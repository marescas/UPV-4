function[tasaDeError] = Ejercicio3(trfile,trlabelsfile,tefile,telabelsfile,numGausianas)
addpath('~/asigDSIC/ETSINF/apr/p2/BNT')
addpath(genpathKPM('~/asigDSIC/ETSINF/apr/p2/BNT'))
datApr = load(trfile, '-ascii');
etqApr = load(trlabelsfile, '-ascii');
dataApr = zscore(datApr);
etiqApr = etqApr + 1;
[numVec dim] = size(dataApr);
numClas = max(etiqApr);
numGaus = numGausianas;
grafo = [ 0 1 1 ; 0 0 1 ; 0 0 0 ];
numNodos = length(grafo);
tallaNodos = [numClas numGaus dim];
nodosDiscretos = [1 2];
redB = mk_bnet(grafo, tallaNodos, 'discrete', nodosDiscretos);
redB.CPD{1} = tabular_CPD(redB, 1);
redB.CPD{2} = tabular_CPD(redB, 2);
redB.CPD{3} = gaussian_CPD(redB, 3, 'cov_type', 'diag');
datosApr = cell(numNodos, numVec);
datosApr(numNodos,:) = num2cell(dataApr', 1);
datosApr(1,:) = num2cell(etiqApr', 1);
motor = jtree_inf_engine(redB);
semilla = 0; rng(semilla);
[redB2, ll, motor2] = learn_params_em(motor, datosApr);
datTest = load(tefile, '-ascii');
etqTest = load(telabelsfile, '-ascii');
dataTest = zscore(datTest);
etiqTest = etqTest + 1;
p = zeros(length(dataTest), numClas); %% Limpiamos p por si se ha usado antes
evidencia = cell(numNodos,1); %% Un cell array vacio para las observaciones
for i=1:length(dataTest)
    evidencia{numNodos} = dataTest(i,:)';
    [motor3, ll] = enter_evidence(motor2, evidencia);
    m = marginal_nodes(motor3, 1);
    p(i,:) = m.T';
end
error_clasificacion = 0;
for  i = 1: length(p)
    [valor,indice] = max(p(i,:));
    if(indice ~= etiqTest(i) )
        error_clasificacion = error_clasificacion +1;
    end
end
tasaDeError = 100 * error_clasificacion/length(etiqTest);
