(define (domain ruta-camiones)
(:requirements
	:durative-actions 
	:typing 
	:fluents
)
(:types
	camion
	conductor
	ciudad
	paquete
	paquetep 
	-object
)
(:predicates
	(at ?x -(either camion conductor paquete paquetep) ?c -ciudad) ;El conductor/paquete/camion x esta en la ciudad c
	(in ?p -(either conductor paquete paquetep) ?t - camion ) ; El conductor o el paquete p esta en el camion t
	(ruta ?c1 ?c2 - ciudad) ; existe una carretera entre c1 y c2
	(usada ?c1 -ciudad); La grua de la ciudad c1 esta usada
)
(:functions
	(costeciu ?c1 ?c2 - ciudad) ;coste de ir de la ciudad c1 a c2 o c2 a c1
	(duraciciu ?c1 ?c2 - ciudad) ; duracion de ir de la ciudad c1 a c2
	(costebus); coste de desplazarse en bus
	(tiempobus) ;duracion de desplazarse en bus
	(costepesado) ;coste de cargar / descargar un paquete pesado
	(tiempopesado) ;tiempo de cargar / descargar un paquete pesado
	(costeligero) ;coste de cargar / descargar un paquete ligero
	(tiempoligero) ;coste de cargar / descargar un paquete pesado
	(costesubir) ;coste subir / bajar
	(tiemposubir) ;tiempo de subir / bajar
	(costetotal) ;coste total
)
;Acciones
(:durative-action conducir
	:parameters(?t -camion ?c -conductor ?origen ?destino -ciudad)
	:duration(= ?duration (duraciciu ?origen ?destino ) ) ;tiempo de desplazarse de la ciudad origen al destino
	:condition (and
				(over all (in ?c ?t )) ; conductor tiene que estar en el camion
				(over all (ruta ?origen ?destino)) ;debe existir una ruta entre el origen y el destino
				(at start(at ?t ?origen)) ; el camion debe estar en origen 			
	)
	:effect(and 
			(at start(not (at ?t ?origen))) ;El camion ya no está en el origen
			(at end (at ?t ?destino )) ; El camion pasa a estar en el destino
			;(at end (at ?c ?destino ))  El conductor pasa a estar en el destino
			(at end (increase (costetotal) (costeciu ?origen ?destino)))
	)

)
(:durative-action subirCamion
	:parameters(?t -camion ?c -conductor ?origen -ciudad)
	:duration(= ?duration (tiemposubir ) ) ;tiempo de subir al camion
	:condition (and
				(at start(at ?t ?origen)) ; el camion debe estar en origen 	
				(at start(at ?c ?origen)) ; el conductor debe estar en origen 		
	)
	:effect(and 
			(at start(not (at ?c ?origen))) ;El conductor ya no está en el origen
			(at end (in ?c ?t)) ; el conductor sube al camion
			(at end (increase (costetotal) (costesubir)))
	)

)

(:durative-action bajarCamion
	:parameters(?t -camion ?c -conductor ?origen -ciudad)
	:duration(= ?duration (tiemposubir ) ) ;tiempo de subir al camion
	:condition (and
				(at start (in ?c ?t)) ;el conductor debe estar en el camion
				(at start(at ?t ?origen)) ; el camion debe estar en origen 		
	)
	:effect(and 
			(at end(at ?c ?origen)) ;El conductor esta en el origen
			(at start (not(in ?c ?t))) ; el conductor baja del camion
			(at end (increase (costetotal) (costesubir)))
	)
)

(:durative-action autobus
	:parameters(?t -camion ?c -conductor ?origen ?destino -ciudad)
	:duration(= ?duration (tiempobus ) ) ;tiempo de transporte en autobus
	:condition (and
				(at start(not (at ?t ?origen)))  ;el camion no debe estar en origen 	
				(at start(at ?c ?origen)) ; el conductor debe estar en origen
				(over all (ruta ?origen ?destino)) 		
	)
	:effect(and 
			(at start(not (at ?c ?origen))) ;El conductor ya no está en el origen
			(at end (at ?c ?destino)) ; el conductor se desplaza a destino
			(at end (increase (costetotal) (costebus)))
	)

)

(:durative-action cargar
	:parameters(?t -camion ?p -paquete ?origen -ciudad)
	:duration(= ?duration (tiempoligero ) ) ;tiempo de subir al camion
	:condition (and
				(at start(at ?t ?origen)) ; el camion debe estar en origen 	
				(at start(at ?p ?origen)) ; el conductor debe estar en origen 		
	)
	:effect(and 
			(at start(not (at ?p ?origen))) ;El paquete ya no está en el origen
			(at end (in ?p ?t)) ; el paquete sube al camion
			(at end (increase (costetotal) (costeligero)))
	)

)
(:durative-action descargar
	:parameters(?t -camion ?p -paquete ?origen -ciudad)
	:duration(= ?duration (tiempoligero ) ) ;tiempo de subir al camion
	:condition (and
				(at start (in ?p ?t)) ;el paquete debe estar en el camion
				(at start(at ?t ?origen)) ; el camion debe estar en origen 		
	)
	:effect(and 
			(at end(at ?p ?origen)) ;El paquete esta en el origen
			(at start( not(in ?p ?t))) ; el paquete baja del camion
			(at end (increase (costetotal) (costeligero)))
	)
)
(:durative-action cargar-pesado
	:parameters(?t -camion ?p -paquetep ?origen -ciudad)
	:duration(= ?duration (tiempopesado ) ) ;tiempo de subir al camion
	:condition (and
				(at start(at ?t ?origen)) ; el camion debe estar en origen 	
				(at start(at ?p ?origen)) ; el conductor debe estar en origen
				(at start (not(usada ?origen))) 		
	)
	:effect(and 
			(at start (usada ?origen)) 			
			(at start(not (at ?p ?origen))) ;El paquete ya no está en el origen
			(at end (in ?p ?t)) ; el paquete sube al camion
			(at end (increase (costetotal) (costepesado)))
			(at end (not(usada ?origen))) 
	)

)
(:durative-action descargar-pesado
	:parameters(?t -camion ?p -paquetep ?origen -ciudad)
	:duration(= ?duration (tiempopesado ) ) ;tiempo de subir al camion
	:condition (and
				(at start (in ?p ?t)) ;el paquete debe estar en el camion
				(at start(at ?t ?origen)) ; el camion debe estar en origen 
			(at start (not(usada ?origen)))
	)
	:effect(and 
			(at start (usada ?origen))
			(at end(at ?p ?origen)) ;El paquete esta en el origen
			(at start( not(in ?p ?t))) ; el paquete baja del camion
			(at end (increase (costetotal) (costepesado)))
			(at end (not(usada ?origen))) 
	)
)







)
