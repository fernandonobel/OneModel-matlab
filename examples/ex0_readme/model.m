classdef model < ModelClass
  methods
    function [self] = model()
      s = self.newSymbol();
      s.name = 'x1';
      s.eqn = 'd_x1 ==  + k1 - gamma12*x1*x2 - d1*x1 ';
      self.addSymbol(s);

      s = self.newSymbol();
      s.name = 'x2';
      s.eqn = 'd_x2 ==  + k2*x3 - gamma12*x1*x2 - d2*x2 ';
      s.noNegative = true;
      self.addSymbol(s);

      s = self.newSymbol();
      s.name = 'x3';
      s.eqn = 'd_x3 ==  + k3*x1 - d3*x3 ';
      s.noNegative = true;
      self.addSymbol(s);
      
      s = self.newSymbol();
      s.name = 'ref';
      s.eqn = 'ref ==  k3/d3 ';
      s.noNegative = true;
      self.addSymbol(s);
    end
    
    function [p] = parameters(~)
      p.k1 = 1.0;
      p.k2 = 1.0;
      p.k3 = 1.0;
      p.gamma12 = 1.0;
      p.d1 = 1.0;
      p.d2 = 1.0;
      p.d3 = 1.0;
    end
    
    function [x0] = initialCondition(~)
      x0.x1 = 0.000000;
      x0.x2 = 0.000000;
      x0.x3 = 0.000000;
    end
  end
end
