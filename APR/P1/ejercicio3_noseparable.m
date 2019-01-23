graphics_toolkit gnuplot;
load("data/mini/tr.dat") #tr
load("data/mini/trlabels.dat")#trlabels
C = 1000;
res = svmtrain(trlabels, tr, ["-q -t 0 -c ",num2str(C)]); #Kernel lineal y C = 1000
mult_lagrange = res.sv_coef; #multiplicadores de lagrange multiplicados por etiqueta clase -1 1
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

toler = zeros(length(trlabels),1);

for i = 1:length(res.sv_indices)
        toler(res.sv_indices(i))=abs( (abs(mult_lagrange(i))==C)*(1 - ( sign(mult_lagrange(i)) * (theta*tr(res.sv_indices(i),:)' + theta0) )) ); 

end

plot(valoresX,Yrecta,
        valoresX, Yrectamargen1,
        valoresX,Yrectamargen2,
        tr(trlabels==1, 1), tr(trlabels==1, 2), 'o',
        tr(trlabels==2, 1), tr(trlabels==2, 2), 'x',
        tr(res.sv_indices, 1), tr(res.sv_indices, 2), '+',
	tr(toler!=0,1),tr(toler!=0,2),'s');

for i = 1:rows(res.sv_indices)
	text(tr(res.sv_indices(i),1)+0.15,tr(res.sv_indices(i),2),sprintf("%4.2f",toler(res.sv_indices(i))),"FontSize",10)
        text(tr(res.sv_indices(i),1)-0.07,tr(res.sv_indices(i),2)+0.3,sprintf("%4.2f",abs(res.sv_coef(i))),"FontSize",10)
endfor

print -djpg ejer3noSep1000.jpg

pause;
