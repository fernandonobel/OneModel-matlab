classdef SymbolClass < handle
  %% SYMBOLCLASS This class is a base for defining symbols for the ModelClass.
  %
  
  properties
    % [char] String with the name of the symbol.
    string
    % sym Symbolic name used for manipulating the symbol in equations.
    sym
  end % properties
  
  methods 
  
    function [obj] = SymbolClass(name)
      %% Constructor of ValueClass.
      %
      % param: name Name of the symbol. 

      obj.string = name;
      obj.sym = str2sym(name);
      
    end % SymbolClass

    	
  end % methods
  
end % classdef
