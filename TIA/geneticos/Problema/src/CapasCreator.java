
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Random;

import org.opt4j.*;
import org.opt4j.core.genotype.PermutationGenotype;
import org.opt4j.core.problem.Creator;
public class CapasCreator implements Creator<PermutationGenotype<Integer>> {

	@Override
	public PermutationGenotype<Integer> create() {
		//El genotipo estara formado por una lista de 12 capas elegidas al azar y sin repeticiones
		//PermutationGenotype<Integer> genotipo = new PermutationGenotype<>(Arrays.asList(Data.capas));
		PermutationGenotype<Integer> genotipo = new PermutationGenotype<>(Arrays.asList(Data.capas));
		genotipo.init(new Random());
		return genotipo;
	}
	
}
