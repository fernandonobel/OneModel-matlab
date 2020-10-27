classdef model < ModelClass
	methods
		function [obj] = model()
			v = VariableClass('x');
			v.start = 0;
			obj.addVariable(v);

			p = ParameterClass('k');
			p.value = 1;
			obj.addParameter(p);

			e = EquationClass('');
			e.eqn = 'der_x == k - x';
			obj.addEquation(e);

p = obj.getSymbolByName('k');
p.value = 5;

			obj.checkValidModel();
		end
	end
end
