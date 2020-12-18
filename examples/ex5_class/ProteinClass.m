classdef ProteinClass < ModelClass
	methods
		function [obj] = ProteinClass()

			obj.namespace = 'p1';

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


			obj.namespace = 'p2';

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


			p = ParameterClass(obj,'A');
			p.value = 1;
			obj.addParameter(p);

			e = EquationClass(obj,'');
			e.eqn = 'p1__w_x == A';
			e.isSubstitution = true;
			obj.addEquation(e);

			e = EquationClass(obj,'');
			e.eqn = 'p2__w_x == p1__x';
			e.isSubstitution = true;
			obj.addEquation(e);

			obj.checkValidModel();
		end
	end
end
