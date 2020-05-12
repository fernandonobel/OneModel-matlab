classdef VariableClass < SymbolClass
  %% VARIABLECLASS This class defines a variable value or state.
  %
  
  properties
    % bool Is the variable algebraic?
    isAlgebraic
    % bool Is the variable no negative?
    isNoNegative
    % plot Should the variable be plot?
    isPlot
  end % properties

  methods 
  
    function [obj] = VariableClass(name)
      %% Constructor of VariableClass.
      %
      % param: name Name of the symbol. 

      obj = obj@SymbolClass(name);
      obj.isAlgebraic = false;
      obj.isNoNegative = false;
      obj.isPlot = true;
      
    end % VariableClass
    	
  end % methods
  
end % classdef
