classdef VariableClass < SymbolClass
  %% VARIABLECLASS This class defines a variable value or state.
  %
  
  properties
    % bool Is the variable no negative?
    isNoNegative
  end % properties

  methods 
  
    function [obj] = VariableClass(name)
      %% Constructor of VariableClass.
      %
      % param: name Name of the symbol. 

      obj = obj@SymbolClass(name);
      obj.isNoNegative = false;
      obj.isPlot = true;
      
    end % VariableClass

    function [] =  set.isNoNegative(obj,isNoNegative)
      %% SET.ISNONEGATIVE Set interface for isNoNegative propierty.
      %
      % param: isNoNegative
      %
      % return: void
      
      if ~islogical(isNoNegative)
        error('isNoNegative must be logical.');
      end

      obj.isNoNegative = isNoNegative;
      
    end % set.isNoNegative

  end % methods
  
end % classdef
