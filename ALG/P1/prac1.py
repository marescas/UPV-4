"""
Alumnos:
Enric Bonet Cortés
Marcos Esteve Casademunt
"""
def ejercicio2(lista):
    """
    Realiza la transformación de recursiva a iterativa implementado un algoritmo
    iterativo que calcule, para cada elemento de la secuencia, la longitud de la mayor
    subsecuencia creciente que termina en cada posición.
    """
    resultado = []
    for i in range(0,len(lista)):
        value = 0
        for j in range(0,i):
            if lista[i]>lista[j] and value < resultado[j]: #buscamos la subsecuencia
                value= resultado[j]
        resultado.append(value+1) #se considera al propio elemento
    return resultado

def ejercicio3(lista):
    return max(ejercicio2(lista))

def ejercicio4(lista):
    """
    Recuperar una subsecuencia de longitud máxima usando BackPointers
    """
    resultado = [] #guardo el tamaño de las subsecuencia
    punteros = []
    camino = []
    for i in range(0,len(lista)):
        value = 0
        puntero = -1
        for j in range(0,i):
            if lista[i]>lista[j] and value < resultado[j]: #buscamos la subsecuencia mas larga
                puntero = j
                value= resultado[j]
        resultado.append(value+1) #se considera al propio elemento
        punteros.append(puntero)
    t = resultado.index(max(resultado))
    while t != -1: #recorremos los punteros para encontrar el camino
        camino.append(lista[t])
        t = punteros[t]
    camino.reverse()
    return camino
