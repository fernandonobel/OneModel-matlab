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
      obj.value = nan;
      
    end % ParameterClass

    function [] = set.value(obj,value)
      %% SET.VALUE Set interface for value propierty.
      %
      % param: value
      %
      % return: void
      
      if ~isreal(value) && ~strcmp(class(value),'sym')
        error('value must be a real number or symbolic.');
      end

      obj.value = value;
      
    end % set.value

    	
  end % methods
  
end % classdef
