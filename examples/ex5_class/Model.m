classdef Model < ModelClass
	methods
		function [obj] = Model()


			obj.namespace = 'myProtein';

			v = VariableClass(obj,'w_x');
			v.isPlot = false;
			obj.addVariable(v);

			v = VariableClass(obj,'x');
			obj.addVariable(v);

			p = ParameterClass(obj,'d_x');
			p.value = 1.0;
			obj.addParameter(p);

			e = EquationClass(obj,'');
			e.eqn = 'der_x == w_x - d_x*x';
			obj.addEquation(e);

			obj.namespace = '';


			e = EquationClass(obj,'');
			e.eqn = 'myProtein__w_x == 100';
			e.isSubstitution = true;
			obj.addEquation(e);

			obj.checkValidModel();
		end
	end
end
