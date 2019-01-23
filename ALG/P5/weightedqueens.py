# -*- coding: utf-8 -*-
#Alumnos
#Marcos Esteve Casademunt
#Enric Bonet Cortés
import numpy as np
import random
import heapq # a priority queue, es un minheap
import argparse
import time


def pessimistic(N,weights):
    return sum(max(weights[row,col] for col in range(N))
               for row in range(N))

def evaluate(s,weights):
    return sum(weights[row,col] for row,col in enumerate(s))

def show_solution(s,N,weights):
    print("    "+"".join("%5d" % c for c in  range(N)))
    for r in range(N):
        print("%3d %s" % (r,"".join((" %4d" % (weights[r,c]))
                                              if s[r]==c else "   --"
                                              for c in range(N))))
    print("+".join(str(weights[r,c]) for r,c in enumerate(s)),"=",
          evaluate(s,weights))

def backtracking(N,weights):
    # weights es una matriz NxN
    assert((type(weights) is np.ndarray) and (weights.shape == (N,N)))
    bestSolution, bestScore = None, pessimistic(N,weights)
    def is_promising(s, newcol):
        # si tenemos el estado s = [1,3,0]
        # en row 0 la reina va en col 1
        # en row 1 la reina va en col 3
        # en row 2 la reina va en col 0
        # check if a new queen can be put in coordinate [newrow,newcol]
        newrow = len(s)
        return all(newcol != col and newrow-row != abs(newcol-col)
                   for row,col in enumerate(s))
    def back(s):
        nonlocal bestSolution, bestScore
        if len(s) == N:
            current = evaluate(s,weights)
            if current < bestScore:
                bestScore = current
                bestSolution = s
        else:
            for col in range(N):
                if is_promising(s, col):
                    back(s+[col])
    back([])
    return bestSolution, bestScore

def optimisticSimple(s,weights,parentScore):
    # parentScore es el score del padre de s
    # COMPLETAR, CALCULAR DE MANERA INCREMENTAL (LISTO)
    row = len(s)-1
    col = s[-1]
    opt = parentScore + weights[row][col]-min(weights[row])
    return opt

def optimisticVert(s,weights,parentScore):
    Infty=2**30
    # parte conocida:
    opt = sum(weights[row,col] for row,col in enumerate(s))
    # cota optimista de la parte que nos queda por completar:
    # COMPLETAR, se aconseja usar min con un iterador y el argumetno default (LISTO)
    row = len(s)
    for i in range(row,len(weights)):
        no_conocido = min([weights[i,col] for col in range(len(weights)) if col not in s],default=Infty)
        opt+=no_conocido
    return opt

def optimisticEllaborate(s,weights,parentScore):
    Infty=2**30
    # la diagonal ppal:
    #     c0 c1 c2 c3
    #    -------------
    # r0 | 0| 1| 2| 3|
    #    -------------
    # r1 |-1| 0| 1| 2|
    #    -------------
    # r2 |-2|-1| 0| 1|
    #    -------------
    # r3 |-3|-2|-1| 0|
    #    -------------
    # esto se consigue para [r,c] con el valor c-r

    # la diagonal inversa:
    #     c0 c1 c2 c3
    #    -------------
    # r0 |-3|-2|-1|0 |
    #    -------------
    # r1 |-2|-1| 0| 1|
    #    -------------
    # r2 |-1| 0| 1| 2|
    #    -------------
    # r3 | 0| 1| 2| 3|
    #    -------------
    # se consigue con r+c-(N-1)

    conocida = 0
    no_conocida = 0
    col_usadas = set()
    diagprincipal_usada = set()
    diaginversa_usada = set()
    # Guardamos columnas, diagonales principales y diagonales inversas utilizadas
    for row in range(len(s)):
        col_usadas.add(s[row])
        diagprincipal_usada.add(s[row]-row)
        diaginversa_usada.add(s[row]+row)
        conocida+= weights[row,s[row]] # parte conocida
    # COMPLETAR!!!

    for row in range(len(s),len(weights)):
        no_conocida+=min([weights[row,col] for col in range(len(weights))
        if col not in col_usadas
        and col-row not in  diagprincipal_usada
        and col+row not in diaginversa_usada],default = Infty)

    return conocida+no_conocida

def branchAndBound(N,weights,
                   verbosity=0,
                   explicitPruning=False,
                   reportStatistics=False,
                   optimistic=optimisticSimple):
    # weights es una matriz NxN
    assert((type(weights) is np.ndarray) and (weights.shape == (N,N)))

    def branch(s):
        # COMPLETAR, solamente debe ramificar las columnas no amenazadas (LISTO)
        col_usadas = set()
        diagprincipal_usada = set()
        diaginversa_usada = set()
        # Guardamos columnas, diagonales principales y diagonales inversas utilizadas
        for row in range(len(s)):
            col_usadas.add(s[row])
            diagprincipal_usada.add(s[row]-row)
            diaginversa_usada.add(s[row]+row)

        newrow = len(s)
        return [s+[newcol] for newcol in range(N)
                if newcol not in col_usadas
                    and newcol-newrow not in diagprincipal_usada
                    and newcol+ newrow not in diaginversa_usada]


    def is_complete(s):
        return len(s)==N

    def initial_score():
        return sum(min(weights[row,col] for col in range(N))
                   for row in range(N))

    def implicit():
        A = [] # empty priority queue
        x = None
        fx = pessimistic(N,weights)

        # anyadimos el estado inicial:
        s = []
        opt = initial_score()
        heapq.heappush(A,(opt,s))

        # bucle principal de ramificacion y poda con PODA IMPLICITA
        iter = 0
        maxA = 0
        podaOpt = 0
        terminales = 0
        noTerminales = 0
        while len(A)>0 and A[0][0] < fx:
            iter+=1
            lenA = len(A)
            if lenA > maxA:
                maxA =lenA
            score_s,s = heapq.heappop(A)
            # COMPLETAR: contadores para que esto funcione
            if verbosity > 1:
                print("Iter. %04d |A|=%05d max|A|=%05d fx=%04d len(s)=%02d score_s=%04d" % \
                      (iter,lenA,maxA,fx,len(s),score_s))
            for child in branch(s):
                if is_complete(child): # si es terminal
                    terminales+=1
                    # seguro que es factible
                    # falta ver si mejora la mejor solucion en curso
                    opt_child = evaluate(child,weights)
                    if opt_child < fx:
                        if verbosity > 0:
                            print("MEJORAMOS",x,fx,"CON",child,opt_child)
                        x, fx = child, opt_child
                else: # no es terminal
                    noTerminales+= 1
                    # la función optimistic recibe como 3er argumento
                    # el score del padre para poder realizar el
                    # cálculo de manera incremental:
                    opt_child = optimistic(child,weights,score_s)
                    # lo metemos en el cjt de estados activos si supera
                    # la poda por cota optimista:
                    podaOpt+=1
                    if opt_child < fx:
                        podaOpt-=1
                        heapq.heappush(A,(opt_child,child))
        if verbosity > 0:
            print("%4d Iterations, max|A|=%05d" % (iter,maxA))
        return x,fx

    def explicit():
        A = [] # empty priority queue
        x = None
        fx = pessimistic(N,weights)

        # anyadimos el estado inicial:
        s = []
        opt = initial_score()
        heapq.heappush(A,(opt,s))

        # bucle principal de ramificacion y poda con PODA EXPLICITA
        # COMPLETAR


        iter = 0
        maxA = 0
        podaOpt = 0
        terminales = 0
        noTerminales = 0
        while len(A)>0:
            iter+=1
            lenA = len(A)
            if lenA > maxA:
                maxA =lenA
            score_s,s = heapq.heappop(A)
            # COMPLETAR: contadores para que esto funcione
            if verbosity > 1:
                print("Iter. %04d |A|=%05d max|A|=%05d fx=%04d len(s)=%02d score_s=%04d" % \
                      (iter,lenA,maxA,fx,len(s),score_s))
            for child in branch(s):
                if is_complete(child): # si es terminal
                    terminales+=1
                    # seguro que es factible
                    # falta ver si mejora la mejor solucion en curso
                    opt_child = evaluate(child,weights)
                    if opt_child < fx:
                        if verbosity > 0:
                            print("MEJORAMOS",x,fx,"CON",child,opt_child)
                        x, fx = child, opt_child
                        #Poda explicita REVISAR
                        A = [a for a in A if a[0] < fx]
                        heapq.heapify(A)
                else: # no es terminal
                    noTerminales+= 1
                    # la función optimistic recibe como 3er argumento
                    # el score del padre para poder realizar el
                    # cálculo de manera incremental:
                    opt_child = optimistic(child,weights,score_s)
                    # lo metemos en el cjt de estados activos si supera
                    # la poda por cota optimista:
                    podaOpt+=1
                    if opt_child < fx:
                        podaOpt-=1
                        heapq.heappush(A,(opt_child,child))


        if verbosity > 0:
            print("%4d Iterations, max|A|=%05d" % (iter,maxA))
        return x,fx

    return explicit() if explicitPruning else implicit()

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("-v", "--verbosity", help="increase output verbosity",
                        type=int, choices=[0,1,2], default = 0)
    parser.add_argument("--seed", help="seed of random number generator", type=int, default=1234)
    parser.add_argument("-N", help="chess board size", type=int)
    parser.add_argument("--Nmin", help="minimum chess board size", type=int, default=4)
    parser.add_argument("--Nmax", help="maximum chess board size", type=int, default=10)
    parser.add_argument("-W", help="maximum weight", type=int, default=9999)
    parser.add_argument("-w", "--weights", help="show weights",
                        action="store_true", default=False)
    parser.add_argument("-o", "--optimistic", help="Type of optimistic function (simple, vert, ellaborate)", default="simple", choices=["simple","vert","ellaborate"])
    parser.add_argument("-s", "--statistics", help="Report statistic information",
                        action="store_true")
    parser.add_argument("-b", "--backtracking", help="Also computes solution with backtracking",
                        action="store_true", default=False)
    parser.add_argument("-i", "--implicit", help="Also computes solution B&B implicit pruning",
                        action="store_true", default=False)
    parser.add_argument("-e", "--explicit", help="Also computes solution B&B explicit pruning",
                        action="store_true", default=False)
    args = parser.parse_args()
    random.seed(args.seed)
    np.random.seed(args.seed)
    N = args.N if args.N != None else random.randint(args.Nmin,args.Nmax)
    weights = np.random.randint(args.W, size=(N,N))
    optimistic = optimisticSimple
    if args.optimistic.lower() == 'vert':
        optimistic = optimisticVert
    elif args.optimistic.lower() == 'ellaborate':
        optimistic = optimisticEllaborate
    print("N",N)
    if args.weights:
        print("weights")
        print(weights)
    if args.backtracking:
        print("Probamos con backtracking:")
        time_backtracking_start = time.process_time()
        x,fx = backtracking(N,weights)
        time_backtracking_stop = time.process_time()
        print(x,fx,"(ellapsed time %.5f)" %
              (time_backtracking_stop-time_backtracking_start,))
        show_solution(x,N,weights)
    if args.implicit:
        print("Ahora probamos con branch and bound poda implícita:")
        time_bbimplicit_start = time.process_time()
        x,fx = branchAndBound(N,weights,
                              optimistic = optimistic,
                              reportStatistics=args.statistics,
                              verbosity = args.verbosity)
        time_bbimplicit_stop = time.process_time()
        print(x,fx,"(ellapsed time %.5f)" %
              (time_bbimplicit_stop-time_bbimplicit_start,))
        show_solution(x,N,weights)
    if args.explicit:
        print("Ahora probamos con branch and bound poda explícita:")
        time_bbexplicit_start = time.process_time()
        x,fx = branchAndBound(N,weights,
                              optimistic = optimistic,
                              explicitPruning = True,
                              reportStatistics=args.statistics,
                              verbosity = args.verbosity)
        time_bbexplicit_stop = time.process_time()
        print(x,fx,"(ellapsed time %.5f)" %
              (time_bbexplicit_stop-time_bbexplicit_start,))
        show_solution(x,N,weights)
