classdef model < ModelClass
	methods
		function [obj] = model()
			v = VariableClass('t');
			v.start = 0;
			obj.addVariable(v);

			e = EquationClass('');
			e.eqn = 'der_t == 1 - t';
			obj.addEquation(e);

		obj.checkValidModel();
		end
	end
end
