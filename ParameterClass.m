classdef ParameterClass < SymbolClass
  %% PARAMETERCLASS This class defines a constant parameter.
  %
  
  properties
    % real Value of the paramter.
    value
  end % properties
  
  methods 
  
    function [obj] = ParameterClass(name)
      %% Constructor of ParameterClass.
      %
      % param: name Name of the symbol. 

      obj = obj@SymbolClass(name);
      obj.value = [];
      
    end % ParameterClass

    function [] = set.value(obj,value)
      %% SET.VALUE Set interface for value propierty.
      %
      % param: value
      %
      % return: void
      
      if ~isreal(value)
        error('value must be a real number.');
      end

      obj.value = value;
      
    end % set.value

    	
  end % methods
  
end % classdef
