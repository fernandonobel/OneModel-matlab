classdef model < ModelClass
	methods
		function [obj] = model()
			obj.simOptions.AbsTol = 1e-3;
			obj.simOptions.RelTol = 1e-9;
			obj.simOptions.TimeSpan  = [0 10];
			v = VariableClass('x');
			v.start = 0;
			obj.addVariable(v);

			p = ParameterClass('k');
			p.value = 1;
			obj.addParameter(p);

			e = EquationClass('');
			e.eqn = 'der_x == k - x';
			obj.addEquation(e);

			obj.checkValidModel();
		end
	end
end
