import java.util.ArrayList;

import org.opt4j.*;
import org.opt4j.core.genotype.PermutationGenotype;
import org.opt4j.core.problem.Decoder;
public class CapasDecoder implements Decoder<PermutationGenotype<Integer>,ArrayList<Integer>> {

	@Override
	public ArrayList<Integer> decode(PermutationGenotype<Integer> genotipo) {
		ArrayList<Integer> fenotipo = new ArrayList<Integer>();
		for(int i = 0 ; i< genotipo.size(); i++) {
			fenotipo.add(genotipo.get(i));
		}
		return fenotipo;
	}

}
