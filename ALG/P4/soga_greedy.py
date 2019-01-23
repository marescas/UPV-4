# -*- coding: utf-8 -*-
import random
import sys
import numpy as np

def generateTugOfWar(Nmin, Nmax, Wmin=10, Wmax=10000):
    "devuelve v,w"
    N = random.randrange(Nmin, Nmax)
    return N, [random.randrange(Wmin, Wmax) for i in range(2*N)]


# solución exacta basada en programación dinámica
def dp_tug_of_war(v, return_list=False):
    N2 = len(v)
    assert (N2 % 2 == 0)
    N = N2 // 2
    W = (sum(v) + 1) // 2
    V = {}
    for i in range(len(v)+1):
        V[i] = {}
        for j in range(N+1):
            V[i][j] = set()
    for i in range(1, len(v) + 1):
        V[i][1].update(V[i-1][1])
        if v[i-1] <= W:
            V[i][1].add(v[i-1])
        for j in range(2, min(N + 1, i + 1)):
            V[i][j].update([c + v[i - 1] for c in V[i - 1][j - 1] if c + v[i - 1] <= W])  # use object i-1
            V[i][j].update(V[i-1][j]) # don't use object i-1
    if return_list:
        i, j, W = N2, N, max(V[i][j])
        path = []
        while W > 0 and j > 0 and i > 0:
            if W - v[i-1] in V[i-1][j-1] or (j == 1 and W == v[i-1]):
                path.append(v[i - 1])
                j -= 1
                W -= v[i - 1]
            i -= 1
        return path
    return max(V[N2][N])


# solución exacta basada en programación dinámica alternativa
def dp_tug_of_war2(v, return_list=False):
    def merge(list1, list2, value, W):
        resul = []
        i, j, len1, len2 = 0, 0, len(list1), len(list2)
        while i < len1 and j < len2 and list2[j][0] + value <= W:
            newvalue = list2[j][0] + value
            if list1[i][0] == newvalue:
                resul.append(list1[i])
                i += 1
                j += 1
            elif list1[i][0] < newvalue:
                resul.append(list1[i])
                i += 1
            else:
                resul.append((newvalue, [value, list2[j][1]]))
                j += 1
        resul += list1[i:]
        while j < len2 and list2[j][0] + value <= W:
            newvalue = list2[j][0] + value
            resul.append((newvalue, [value, list2[j][1]]))
            j += 1
        return resul
    N2 = len(v)
    assert(N2 % 2 == 0)
    N = N2 // 2
    W = (sum(v)+1) // 2
    # crear lista de listas, crecerá hasta longitud N
    pool = [[(0,None)]]
    # bucle N veces haciendo crecer dicha lista
    for i in range(N):
        #print(i,end=" ")
        value = v[i]
        pool.append([(x+value,[value,y]) for x,y in pool[-1] if x+value<=W])
        for j in range(len(pool)-1,0,-1):
            pool[j] = merge(pool[j],pool[j-1],value,W)
    # ahora la lista tiene talla N+1 (desde 0 hasta N)
    # bucle N veces haciendo decrecer la lista:
    for i in range(N):
        value = v[N+i]
        for j in range(N,i,-1):
            pool[j] = merge(pool[j],pool[j-1],value,W)
        pool[i] = None
    # quedarnos con el máximo de la única lista que quedará al final
    maxval,thepath = max(pool[N])
    if return_list:
        path = []
        while thepath != None:
            path.append(thepath[0])
            thepath = thepath[1]
        return path
    return maxval
    #return abs(sum(v)-2*sum(path))


    x = [0] * len(w)
    profit = 0
    for i in range(len(w)):
        if w[i] < W:
            x[i] = 1
            W -= w[i]
            profit += v[i]
    return profit, x


def greedy_tug_of_war(v):
    #print(v)
    N2 = len(v)
    assert(N2 % 2 == 0)
    N = N2 // 2
    ######################################
    # SUSTITUIR POR ALGO MAS INTELIGENTE
    left  =[]
    right = []
    v = sorted(v)
    i = 0
    while i < N2:
        if sum(left) >=sum(right):
            left.append(v[i])
            right.append(v[i+1])
        else:
            left.append(v[i+1])
            right.append(v[i])
        i+=2
    accumleft,accumright = sum(left),sum(right)
    #######################################
    return accumleft



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
        print("El %7.2f%% de las soluciones voraces estan en o por encima del "\
          "%3d%% respecto la optima" % (100*acumulado[i]/total,i))
        i+=1
    print("El %7.2f%% de las soluciones voraces coinciden con la optima."\
            % (100*acumulado[100]/total))

import time
import sys
if __name__ == "__main__":
    trials = 100
    soluciones_DP, soluciones_greedy = [], []
    if len(sys.argv) > 1:
        casos = []
        for l in open(sys.argv[1]):
            l = list(map(int, l.split()))
            casos.append([len(l)-1, l[:-1]])
            soluciones_DP.append(l[-1])
        trials = len(casos)
    else:
        casos = [generateTugOfWar(2, 51, 10, 401) for i in range(trials)]
    t0 = time.time()
    for i in range(trials):
        N, v = casos[i]
        print("iteración: %d\r" % i, end="")
        if len(soluciones_DP) < trials:
            solDP = dp_tug_of_war(v)
            solDP = min(solDP, sum(v) - solDP)
            soluciones_DP.append(solDP)
        solvoraz = greedy_tug_of_war(v)
        solvoraz = min(solvoraz, sum(v) - solvoraz)
        soluciones_greedy.append(solvoraz)
    mostrar_soluciones(list(zip(soluciones_DP, soluciones_greedy)))
    with open("casos_soga.txt", "w") as fh:
        for i in range(trials):
            fh.write('\t'.join(map(str, casos[i][1]+[soluciones_DP[i]])) + '\n')
    tf = time.time()-t0
    print("Se ha tardado %f segundos en hacer el test." % (tf))
