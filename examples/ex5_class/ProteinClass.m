classdef ProteinClass < ModelClass
	methods
		function [obj] = ProteinClass()
			% This is a test comment.

			v = VariableClass('x1');
			v.start = 0.0;
			obj.addVariable(v);

			p = ParameterClass('A');
			p.value = 1;
			obj.addParameter(p);

			e = EquationClass('der_x1 == A');
			e.eqn = '';
			obj.addEquation(e);


disp(1);


			obj.checkValidModel();
		end
	end
end
