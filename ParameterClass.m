classdef ParameterClass < SymbolClass
  %% PARAMETERCLASS This class defines a constant parameter.
  %
  
  properties
    
  end % properties
  
  methods 
  
    function [obj] = ParameterClass(name)
      %% Constructor of ParameterClass.
      %
      % param: name Name of the symbol. 

      obj = obj@SymbolClass(name);
      
      
    end % ParameterClass

    	
  end % methods
  
end % classdef
