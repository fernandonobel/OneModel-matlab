classdef model < ModelClass
	% This code was generated by ModelClass v0.4.7 88821cd   -   Fernando Nóbel (fersann1@upv.es)
	methods
		function [obj] = model(opts)
			v = VariableClass(obj,'x');
			v.start = 0;
			obj.addVariable(v);

			p = ParameterClass(obj,'A');
			p.value = 1;
			obj.addParameter(p);

			e = EquationClass(obj,'');
			e.eqn = 'der_x == A - x';
			obj.addEquation(e);

			obj.checkValidModel();
		end

	end
	methods(Static)
		function [out] = isUpToDate()
			dependenciesPath = {...
				'./model/model.mc'...
			};
			out = model.checkUpToDate(dependenciesPath);
		end
	end
end
