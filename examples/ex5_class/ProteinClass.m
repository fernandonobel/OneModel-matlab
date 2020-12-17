classdef ProteinClass < ModelClass
	methods
		function [obj] = ProteinClass()
			obj.namespace = 'myProtein';

			v = VariableClass(obj,'x');
			obj.addVariable(v);

			p = ParameterClass(obj,'w_x');
			p.value = 1.0;
			obj.addParameter(p);

			p = ParameterClass(obj,'d_x');
			p.value = 1.0;
			obj.addParameter(p);

			e = EquationClass(obj,'');
			e.eqn = 'der_x == w_x - d_x*x';
			obj.addEquation(e);

			obj.namespace = '';

			v = VariableClass(obj,'x1');
			v.start = 0.0;
			obj.addVariable(v);

			p = ParameterClass(obj,'A');
			p.value = 1;
			obj.addParameter(p);

			e = EquationClass(obj,'');
			e.eqn = 'der_x1 == myProtein__x';
			obj.addEquation(e);

			obj.checkValidModel();
		end
	end
end
