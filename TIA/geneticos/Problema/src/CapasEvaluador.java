import java.util.ArrayList;

import org.opt4j.*;
import org.opt4j.core.Objective.Sign;
import org.opt4j.core.Objectives;
import org.opt4j.core.problem.Evaluator;
public class CapasEvaluador implements Evaluator<ArrayList<Integer>>  {

	@Override
	public Objectives evaluate(ArrayList<Integer> fenotipo) {
		double resultado = 0;
		double coste = 0;
		String abc = "012";
		String abd = "013";
		String fhi = "578";
		String fhj = "579";
		String resultados = ""; 
		for(int i = 1; i< fenotipo.size();i++) {
			resultado += Data.aislante[fenotipo.get(i-1)][fenotipo.get(i)];
		}
		for(int i =0 ; i< fenotipo.size();i++) {
			resultados+=fenotipo.get(i);
			coste+= 100;
		}

		//Si existe abc o abd incrementamos el aislante en 0.02
		if(resultados.indexOf(abc) != -1 || resultados.indexOf(abd) != -1 ) {
			resultado = resultado +resultado * 0.02;
			
		}
		//Si  existe fhi o fhj la descartamos  asignandole el minimo valor posible
		if(resultados.indexOf(fhi) != -1 || resultados.indexOf(fhj) != -1) {
			resultado = -Double.MIN_VALUE;
		}
		//Segundo ejercicio:
		if(resultados.startsWith("1") || resultados.startsWith("2") || resultados.startsWith("3")) {
			coste+=20;
		}
		if(resultados.startsWith("4") || resultados.startsWith("5") || resultados.startsWith("6")) {
			coste+=50;
		}
		
		
		Objectives objetivos = new Objectives();
		objetivos.add("Valor aislante maximo", Sign.MAX, resultado);
		objetivos.add("Valor coste minimo", Sign.MIN, coste);
		return objetivos;
	}

}
