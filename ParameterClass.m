classdef ParameterClass < SymbolClass
  %% PARAMETERCLASS This class defines a constant parameter.
  %
  
  properties
    % real Value of the paramter.
    value
    % char Value for TeX generation.
    valueTex
  end % properties
  
  methods 
  
    function [obj] = ParameterClass(mc, name)
      %% Constructor of ParameterClass.
      %
      % param: mc   OneModel object.
      %        name Name of the symbol. 

      obj = obj@SymbolClass(mc, name);

      obj.value = nan;
      obj.valueTex = [];
      
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

      if isempty(obj.valueTex)
        obj.valueTex = num2str(obj.value);
      end
      
    end % set.value
    	
  end % methods
  
end % classdef
