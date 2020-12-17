classdef ProteinClass < ModelClass
	methods
		function [obj] = ProteinClass()
			obj.namespace = 'Protein';

			v = VariableClass(obj,'x1');
			v.start = 0.0;
			obj.addVariable(v);

			obj.namespace = '';

			p = ParameterClass(obj,'A');
			p.value = 1;
			obj.addParameter(p);

			obj.namespace = 'genes';

			e = EquationClass(obj,'');
			e.eqn = 'der_x1 == A';
			obj.addEquation(e);

			obj.checkValidModel();
		end
	end
end
