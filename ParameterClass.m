classdef ParameterClass < SymbolClass
  %% PARAMETERCLASS This class defines a constant parameter.
  %
  
  properties
    % real Value of the paramter.
    value
  end % properties
  
  methods 
  
    function [obj] = ParameterClass(mc, name)
      %% Constructor of ParameterClass.
      %
      % param: mc   ModelClass object.
      %        name Name of the symbol. 

      obj = obj@SymbolClass(mc, name);

      obj.value = nan;
      
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
