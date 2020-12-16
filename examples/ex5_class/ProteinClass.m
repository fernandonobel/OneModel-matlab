classdef ProteinClass < ModelClass
	methods
		function [obj] = ProteinClass()

			obj.simOptions.AbsTol = 1e-6;
			% This is a test comment.

			v = VariableClass('x1');
			v.start = 0.0;
			obj.addVariable(v);

			p = ParameterClass('A');
			p.value = 1;
			obj.addParameter(p);

			e = EquationClass('');
			e.eqn = 'der_x1 == A';
			obj.addEquation(e);


disp(1);


			obj.checkValidModel();
		end
	end
end
