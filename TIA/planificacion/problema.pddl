(define(problem problema1)
    (:domain ruta-camiones)
    (:objects
    A - ciudad
    B -ciudad
    C - ciudad
    D - ciudad
    E - ciudad

    p1 - paquetep
    p2 - paquete

    c1 - camion
    c2 - camion

    d1 - conductor
    d2 - conductor
    )
    (:init
    (at p1 A)
    (at p2 D )
    (at c1 A )
    (at c2 A)
    (at d1 C)
    (at d2 D)
    (= (costeciu A B) 1)
    (= (costeciu B A) 1)
    (= (costeciu A C) 1)
    (= (costeciu C A) 1)
    (= (costeciu B D) 3)
    (= (costeciu D B) 3)
    (= (costeciu C B) 2)
    (= (costeciu B C) 2)
    (= (costeciu E B) 3)
    (= (costeciu B E) 3)
    (= (costeciu C E) 6)
    (= (costeciu E C) 6)

    (= (duraciciu A B) 4)
    (= (duraciciu B A) 4)
    (= (duraciciu A C) 2)
    (= (duraciciu C A) 2)
    (= (duraciciu B C) 3)
    (= (duraciciu C B) 3)
    (= (duraciciu B D) 3)
    (= (duraciciu D B) 3)
    (= (duraciciu B E) 4)
    (= (duraciciu E B) 4)
    (= (duraciciu C E) 9)
    (= (duraciciu E C) 9)
    

    (ruta A B)
    (ruta B A)
    (ruta A C)
    (ruta C A)
    (ruta C B)
    (ruta B C)
    (ruta B D)
    (ruta D B)
    (ruta B E)
    (ruta E B)
    (ruta C E)
    (ruta E C)

    (= (costebus) 3)
    (= (tiempobus) 10)
    (= (costepesado) 4)
    (= (tiempopesado) 2)
    (= (costeligero) 2)
    (= (tiempoligero) 1)
    (= (costesubir) 1)
    (= (tiemposubir) 1)
    (= (costetotal) 0)
    )

    (:goal (and
            (at p1 E)
            (at p2 C)
            (at c2 A)
            (at d1 B)
    ))
    (:metric minimize (+ (* 0.2 (total-time)) (* 0.5 (costetotal))))

)
