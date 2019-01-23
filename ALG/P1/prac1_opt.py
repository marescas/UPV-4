"""
Ejercicio muy opcional
Alumnos:
Enric Bonet Cortés
Marcos Esteve Casademunt
"""

def buscarmenores(lista,elemento):
    """
    Recibe una lista ordenada ascendente y un elemento. Busca en O(logN) el elemento en la lista
    Si encuentra el elemento --> -1,mitad
    Si no lo encuentra devuelve el indice donde tiene que ir el nuevo elemento
    """
    inicio = 0
    fin = len(lista)
    encontrado = False
    while inicio+1!= fin and not encontrado:
        mitad = int((fin +inicio)/2)
        if  elemento < lista[mitad] :
            fin = mitad
        elif lista[mitad] == elemento:
            encontrado = True
        else:
            inicio = mitad
    if not encontrado:
        if inicio == 0 and lista[0]>=elemento: #si el elemento es el nuevo mínimo
            return 0,0
        else:
            return fin,0
    return (-1,mitad) # en caso de encontrar el valor en la lista
def ejercicioOpcional2(lista):
    """
    Calcula para cada elemento de la secuencia, la longitud de la mayor
    subsecuencia creciente que termina en cada posición. Tiempo O(n*log(n))
    """
    menores = [] #Guardamos ascendentemente los menores
    resultado = []
    menores.append(lista[0]) #añadimos el primer elemento a la lista
    resultado.append(1) #su longitud máxima es 1
    for i in range(1,len(lista)):
        if lista[i] > menores[len(menores)-1]: #si el elemento de la lista es el nuevo máximo
            menores.append(lista[i])
            resultado.append(len(menores))
        else:
            valor = buscarmenores(menores,lista[i]) #buscamos el nuevo valor
            if valor[0] != -1: #si no lo hemos encontrado en la lista de menores
                resultado.append(valor[0]+1) #longitud máxima del elemento i
                menores[valor[0]] = lista[i] #actualizamos la lista de menores
            else:  #si hemos encontrado el valor en la lista
                resultado.append(valor[1]+1)
    return resultado
