classdef ProteinClass < ModelClass
	methods
		function [obj] = ProteinClass()

			v = VariableClass('a');
			obj.addVariable(v);

			e = EquationClass('');
			e.eqn = 'der_a == 1';
			obj.addEquation(e);

			obj.checkValidModel();
		end
	end
end
