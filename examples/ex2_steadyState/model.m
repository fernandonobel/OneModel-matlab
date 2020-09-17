classdef model < ModelClass
	methods
		function [obj] = model()
			v = VariableClass('le');
			v.start = 0;
			obj.addVariable(v);

			e = EquationClass('');
			e.eqn = 'der_le == 1 - le';
			obj.addEquation(e);

		obj.checkValidModel();
		end
	end
end
