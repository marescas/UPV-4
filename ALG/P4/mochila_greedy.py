# -*- coding: utf-8 -*-
import random
import sys

def generateKnapsack(Nmin, Nmax, Wmin, Wmax):
    "devuelve v,w"
    N = random.randrange(Nmin, Nmax)
    W = random.randrange(Wmin, Wmax)
    v = [random.randrange(1, 1000) for i in range(N)]
    w = [random.randrange(1, W) for i in range(N)]
    return N,W,v,w

def iterative_knapsack_profit(W, v, w):
    V = {}
    for c in range(W+1):
        V[0,c] = 0
    for i in range(1, len(v)+1):
        V[i,0] = 0
        for c in range(1, min(W+1,w[i-1])):
            V[i,c] = V[i-1, c]
        for c in range(w[i-1], W+1):
            V[i,c] = max(V[i-1, c], V[i-1, c-w[i-1]] + v[i-1])
    return V[len(v), W]



def greedy_knapsack(w, v, W):
    ######################################
    # SUSTITUIR POR ALGO MAS INTELIGENTE
    x = [0] * len(w)
    profit = 0
    for (ratio,i) in sorted([ (v[i]/w[i],i) for i in range(len(w))],reverse = True ):
        if w[i] < W:
            x[i] = 1
            W -= w[i]
            profit += v[i]
    return profit
    #######################################

def mostrar_soluciones(soluciones):
    histograma = 101*[0]
    acumulado = 101*[0]
    total = len(soluciones)
    for (exacta,aprox) in soluciones:
        ratio = int(100*aprox/float(exacta))
        histograma[ratio] += 1
    acumulado[100] = histograma[100]
    for i in range(99,-1,-1):
        acumulado[i] = histograma[i]+acumulado[i+1]
    i = 0
    while i<100 and acumulado[i+1]==100:
        i+=1
    while i<100:
        print("El %7.2f%% de las soluciones voraces estan en o encima del "\
          "%3d%% respecto la optima" % (100*acumulado[i]/total,i))
        i+=1
    print("El %7.2f%% de las soluciones voraces coinciden con la optima."\
            % (100*acumulado[100]/total))

import time
import sys
if __name__ == "__main__":
    soluciones_DP, soluciones_greedy = [], []
    trials = 1000
    t0 = time.time()
    if len(sys.argv) > 1:
        casos = []
        for l in open(sys.argv[1]):
            l = list(map(int, l.split()))
            N, W = l[0], l[1]
            v = l[2:N+2]
            w = l[N+2:2*N+2]
            solDP = l[-1]
            casos.append((N, W, v, w))
            soluciones_DP.append(solDP)
        trials = len(casos)
    else:
        casos = [generateKnapsack(50, 100, 100, 101) for i in range(trials)]
    t0 = time.time()
    for i in range(trials):
        N, W, v, w = casos[i]
        print("iteración: %d\r" % i, end="")
        if len(soluciones_DP) < trials:
            solDP = iterative_knapsack_profit(W, v, w)
            soluciones_DP.append(solDP)
        solvoraz = greedy_knapsack(w, v ,W)
        soluciones_greedy.append(solvoraz)
    mostrar_soluciones(list(zip(soluciones_DP, soluciones_greedy)))
    with open("casos_mochila.txt", "w") as fh:
        for i in range(trials):
            N, W, v, w = casos[i]
            fh.write('\t'.join(map(str, [N] + [W] + v + w + [soluciones_DP[i]])) + '\n')
    tf = time.time()-t0
    print("Se ha tardado %f segundos en hacer el test." % (tf))
