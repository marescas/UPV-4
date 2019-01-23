import org.opt4j.core.problem.ProblemModule;

public class CapasModulo extends ProblemModule {

	@Override
	protected void config() {
		bindProblem(CapasCreator.class, CapasDecoder.class, CapasEvaluador.class);
		
	}

}
