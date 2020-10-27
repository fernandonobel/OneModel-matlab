classdef model < ModelClass
	methods
		function [obj] = model()
			obj.simOptions.AbsTol = 1e-9;
			obj.simOptions.RelTol = 1e-9;
			obj.simOptions.TimeSpan  = [0 10];
			v = VariableClass('x');
			v.start = 0;
			obj.addVariable(v);

			e = EquationClass('');
			e.eqn = 'der_x == 1 - x';
			obj.addEquation(e);

			obj.checkValidModel();
		end
	end
end
