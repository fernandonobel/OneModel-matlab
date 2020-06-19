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
    % [char] Physical units of the symbol.
    units
    % [char] Comment of the symbol.
    comment
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
        error('name must be a string.');
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
        error('nameSym must be a symbolic expression.');
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
        error('nameTex must be a string.');
      end

      obj.nameTex = nameTex;
      
    end % set.nameTex

    function [] = set.units(obj,units)
      %% SET.UNITS Set interface for units propierty.
      %
      % param: units [char] Units.
      %
      % return: void

      if ~isstring(units) && ~ischar(units)
        error('units must be a string.');
      end

      obj.units = units;
      
    end % set.units

    function [] = set.comment(obj,comment)
      %% SET.COMMENT Set interface for comment propierty.
      %
      % param: comment [char] Comment.
      %
      % return: void

      if ~isstring(comment) && ~ischar(comment)
        error('comment must be a string.');
      end

      obj.comment = comment;
      
    end % set.comment
   	
  end % methods
  
end % classdef
