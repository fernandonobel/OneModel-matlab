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

    function [out] =  checkSymbol(obj)
      %% CHECKSYMBOL Check that the symbol is well configured.
      %
      % return: out bool True if it is well configured.

      1+1

      % TODO: Check if the name of the state is already used.
      
    end % checkSymbol
    	
  end % methods
  
end % classdef
