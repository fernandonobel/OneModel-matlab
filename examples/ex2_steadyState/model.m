classdef model < ModelClass
	methods
		function [obj] = model()
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
