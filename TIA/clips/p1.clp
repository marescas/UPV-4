

(deffunction fuzzify (?fztemplate ?value ?delta)

        (bind ?low (get-u-from ?fztemplate))
        (bind ?hi  (get-u-to   ?fztemplate))

        (if (<= ?value ?low)
          then
            (assert-string
              (format nil "(%s (%g 1.0) (%g 0.0))" ?fztemplate ?low ?delta))
          else
            (if (>= ?value ?hi)
              then
                (assert-string
                   (format nil "(%s (%g 0.0) (%g 1.0))"
                               ?fztemplate (- ?hi ?delta) ?hi))
              else
                (assert-string
                   (format nil "(%s (%g 0.0) (%g 1.0) (%g 0.0))"
                               ?fztemplate (max ?low (- ?value ?delta))
                               ?value (min ?hi (+ ?value ?delta)) ))
            )
        )
  )



(deftemplate distancia
 0 50 m
((cerca (0 1)(15 0))
(medio (10 0)(25 1)(35 1)(40 0))
(lejos (35 0)(50 1)))) 

(deftemplate velocidad
 -30 30 kmh
((alejando (-30 1)(0 0))
(constante (-10 0)(0 1)(10 0))
(acercando (0 0)(30 1)))) 


(deftemplate presion-freno 0 100 p
((nula(z 10 25))
(media(pi 25 65))
(alta (s 65 90))
(brusca (s 95 100))
)
) 

(deftemplate vehiculo
	(slot id (type SYMBOL))
	(slot distancia (type FLOAT))
	(slot velocidad (type FLOAT))
	(slot freno (type FLOAT))
	(slot warning (type SYMBOL))
)


(defrule cerca-alejar
	(distancia cerca)
	(velocidad alejando)
=>
	
	(assert (presion-freno nula))) 

(defrule cerca-constante
	(distancia cerca)
	(velocidad constante)
=>
	
	(assert (presion-freno alta))) 

(defrule cerca-acercando
	(distancia cerca)
	(velocidad acercando)
=>
	
	(assert (presion-freno very brusca))) 

;Media
(defrule media-alejar
	(distancia medio)
	(velocidad alejando)
=>
	
	(assert (presion-freno nula))) 

(defrule media-constante
	(distancia medio)
	(velocidad constante)
=>
	
	(assert (presion-freno nula))) 

(defrule medio-acercando
	(distancia medio)
	(velocidad acercando)
=>
	
	(assert (presion-freno more-or-less brusca))) 

;Lejos

(defrule lejos-alejar
	(distancia lejos)
	(velocidad alejando)
=>
	
	(assert (presion-freno nula))) 

(defrule lejos-constante
	(distancia lejos)
	(velocidad constante)
=>
	
	(assert (presion-freno nula))) 

(defrule lejos-acercando
	(distancia lejos)
	(velocidad acercando)
=>
	
	(assert (presion-freno brusca))) 


(deffunction inicio()
(reset)
 (printout t "Introduce identificador de vehiculo:" crlf)
 (bind ?idvehiculo (read))
 (printout t "Introduce distancia de vehiculo:" crlf)
 (bind ?Rdistancia (read))
 (printout t "Introduce velocidad de vehiculo:" crlf)
 (bind ?Rvelocidad (read))
 (fuzzify distancia ?Rdistancia 0.0)
 (fuzzify velocidad ?Rvelocidad 0.0)
 (assert (vehiculo (id ?idvehiculo) (distancia ?Rdistancia) (velocidad ?Rvelocidad) (freno 0.0) (warning OFF)))
 (run)

)

(defrule defuzzy
(declare (salience -1))
 ?f <- (presion-freno ?)
 ?v <- (vehiculo (id ?vehiculo) (distancia ?Rdistancia) (velocidad ?Rvelocidad) (freno ?freno) (warning ?w))

 (test (= ?freno 0.0))
 => (bind ?e (moment-defuzzify ?f))
 
 (modify ?v (freno ?e))
 (printout t "presion freno es " ?e crlf)
 (halt))

(defrule warning
 (presion-freno very alta)
 ?v <- (vehiculo (id ?vehiculo) (distancia ?Rdistancia) (velocidad ?Rvelocidad) (freno ?freno) (warning ?w))
 (test (eq ?w  OFF))
 => 
 
 (modify ?v (warning ON))
 (printout t "Warning ON"crlf)
)

(defrule sistemas
 (presion-freno extremely brusca)
 => 
 
 (printout t "Sistemas de seguridad activados"crlf)
)
 

 