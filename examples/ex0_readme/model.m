classdef model < ModelClass
    methods
        function [self] = model()
            % Variables
            v = VariableClass('x1');
            self.addVariable(v);

            v = VariableClass('x2');
            self.addVariable(v);

            v = VariableClass('x3');
            self.addVariable(v);

            v = VariableClass('ref'); 
            v.isAlgebraic = true;
            self.addVariable(v);

            % Parameters
            p = ParameterClass('k1');
            self.addParameter(p);

            p = ParameterClass('k2');
            self.addParameter(p);

            p = ParameterClass('k3');
            self.addParameter(p);

            p = ParameterClass('d1');
            self.addParameter(p);

            p = ParameterClass('d2');
            self.addParameter(p);

            p = ParameterClass('d3');
            self.addParameter(p);

            p = ParameterClass('gamma12');
            self.addParameter(p);

            % Equations
            e = EquationClass('ref ==  k3/d3');
            self.addEquation(e);
            
            e = EquationClass('d_x1 ==  + k1 - gamma12*x1*x2 - d1*x1');
            self.addEquation(e);

            e = EquationClass('d_x2 ==  + k2*x3 - gamma12*x1*x2 - d2*x2');
            self.addEquation(e);

            e = EquationClass('d_x3 ==  + k3*x1 - d3*x3');
            self.addEquation(e);



        end
    end
end
