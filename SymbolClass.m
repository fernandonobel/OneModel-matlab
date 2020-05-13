classdef SymbolClass < handle
  %% SYMBOLCLASS This class is a base for defining symbols for the ModelClass.
  %
  
  properties
    % [char] String with the name of the symbol.
    name
    % sym Symbolic name used for manipulating the symbol in equations.
    nameSym
    % [char] Name for LaTeX generation.
    nameTex
  end % properties
  
  methods 
  
    function [obj] = SymbolClass(name)
      %% Constructor of ValueClass.
      %
      % param: name Name of the symbol. 

      obj.name = name;
      obj.nameSym = sym(name);
      obj.nameTex = name;

    end % SymbolClass

    function [] =  set.name(obj,name)
      %% SET.NAME Set interface for name propierty.
      %
      % param: name [char] Name for the symbol.
      %
      % return: void

      if ~isstring(name) && ~ischar(name)
        error('ERROR: name must be a string.');
      end

      obj.name = name;
      
    end % set.name

    function [] =  set.nameSym(obj,nameSym)
      %% SET.NAMESYM Set interface for nameSym propierty.
      %
      % param: nameSym sym Symbolic name.
      %
      % return: void

      if ~strcmp(class(nameSym),'sym')
        error('ERROR: nameSym must be a symbolic expression.');
      end

      obj.nameSym = nameSym;
      
    end % set.nameSym

    function [] =  set.nameTex(obj,nameTex)
      %% SET.NAMETEX Set interface for nameTex propierty.
      %
      % param: nameTex [char] String with the named used for LaTeX.
      %
      % return: void
      
      if ~isstring(nameTex) && ~ischar(nameTex)
        error('ERROR: nameTex must be a string.');
      end

      obj.nameTex = nameTex;
      
    end % set.nameTex
    	
  end % methods
  
end % classdef
