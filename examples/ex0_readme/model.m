classdef model < ModelClass
	methods
		function [obj] = model()
			v = VariableClass('x1');
			obj.addVariable(v);

			v = VariableClass('x2');
			obj.addVariable(v);

			v = VariableClass('x3');
			obj.addVariable(v);

			v = VariableClass('ref');
			v.isSubstitution=true;
			e = EquationClass('');
			e.eqn = 'ref ==  k3/d3';
			e.isSubstitution = true;
			obj.addEquation(e);
			obj.addVariable(v);

			p = ParameterClass('k1');
			p.value = 1.0;
			obj.addParameter(p);

			p = ParameterClass('k2');
			p.value = 1.0;
			obj.addParameter(p);

			p = ParameterClass('k3');
			p.value = 1.0;
			obj.addParameter(p);

			p = ParameterClass('d1');
			p.value = 1.0;
			obj.addParameter(p);

			p = ParameterClass('d2');
			p.value = 1.0;
			obj.addParameter(p);

			p = ParameterClass('d3');
			p.value = 1.0;
			obj.addParameter(p);

			p = ParameterClass('gamma12');
			p.value = 1.0;
			obj.addParameter(p);

			e = EquationClass('');
			e.eqn = 'der_x1 == k1    - gamma12*x1*x2 - d1*x1';
			obj.addEquation(e);

			e = EquationClass('');
			e.eqn = 'der_x2 == k2*x3 - gamma12*x1*x2 - d2*x2';
			obj.addEquation(e);

			e = EquationClass('');
			e.eqn = 'der_x3 == k3*x1 - d3*x3';
			obj.addEquation(e);

		obj.checkValidModel();
		end
	end
end
