numeroGausianas = [1 2 5 10 20 50 100];
trfile = "data/spam/tr.dat";
trlabelsfile = "data/spam/trlabels.dat";
tefile = "data/spam/ts.dat";
telabelsfile = "data/spam/tslabels.dat";
for gausiana=1 : length(numeroGausianas)
      error = Ejercicio3(trfile,trlabelsfile,tefile,telabelsfile,numeroGausianas(gausiana));
      sprintf("Con %d gausianas error = %.3f ",numeroGausianas(gausiana),error )
end    