classdef ProteinClass < ModelClass
	methods
		function [obj] = ProteinClass()
			% This is a test comment.

			% Variable comment.
			v = VariableClass('x1');
			v.start = 0.0;
			obj.addVariable(v);

			obj.checkValidModel();
		end
	end
end
