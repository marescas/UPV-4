graphics_toolkit gnuplot;
load("data/mini/tr.dat") #tr
load("data/mini/trlabels.dat")#trlabels
#Kernel lineal y C = 1000
res = svmtrain(trlabels, tr, "-t 0 -c 1000");
#multiplicadores de lagrange multiplicados por etiqueta clase -1 1
mult_lagrange = res.sv_coef;
vectores_soporte = tr(res.sv_indices,:); #vectores soportes
theta = mult_lagrange' * vectores_soporte;
theta0 = -1 * res.rho;
margen = 1 / (theta * theta');
pendiente = -theta(1)/ theta(2);
b1 = -theta0/theta(2);
bmargen1 =-(theta0 +1)/theta(2);
bmargen2 =-(theta0 -1)/theta(2);
valoresX = [1:0.001:10];
Yrecta = pendiente * valoresX + b1;
Yrectamargen1 = pendiente * valoresX + bmargen1;
Yrectamargen2 = pendiente * valoresX + bmargen2;
plot(valoresX,Yrecta,
        valoresX, Yrectamargen1,
        valoresX,Yrectamargen2,
        tr(trlabels==1, 1), tr(trlabels==1, 2), 'o',
        tr(trlabels==2, 1), tr(trlabels==2, 2), 'x',
        tr(res.sv_indices, 1), tr(res.sv_indices, 2), '+');
print -djpg ejer3.jpg

pause;
