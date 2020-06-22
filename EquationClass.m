classdef EquationClass < handle
  %% EQUATIONCLASS This class defines equations for ModelClass.
  %

  properties
    % [char] Name of the equation.
    name
    % [char] Char array equation.
    eqn
    % [sym] Simbolic equation.
    eqnSym
    % bool Is the equation just an assignation of variables?
    isAssign
  end % properties

  properties (Dependent)
    % [left] Left part of the equation.
    left
    % [right] Right part of the equation.
    right 
    % [sym] Variables of the equation.
    vars
    % [sym] Derivatives variables in the equation.
    ders
  end % properties (Dependent)

  methods 

    function [obj] = EquationClass(name)
      %% Constructor of EquationClass.
      %
      % param: eqn [char] String with the equation.

      obj.name = name;
      obj.eqn = '';
      obj.isAssign = false;

    end % EquationClass

    function [out] =  getFreeVars(obj,knownVars)
      %% GETFREEVARS Return variables that are free in the equation.
      %
      % param: knownVars [sym] Array with known vars.
      %
      % return: out [sym] Free vars in the equation.

      vars = obj.vars;

      out = sym([]);

      for i = 1:length(vars)
        isFree = true;
        for j = 1:length(knownVars)
          if vars(i) == knownVars(j)
            isFree = false;
            break;
          end
        end
        if isFree
          out(end+1) = vars(i);
        end
      end
      
    end % getFreeVars

    function [] = set.name(obj,name)
      %% SET.NAME Set interface for name propierty.
      %
      % param: name
      %
      % return: void

      if ~ischar(name) 
        error('name must be a char array.');
      end
      
      obj.name = name;
      
    end % set.name

    function [] = set.eqn(obj,eqn)
      %% SET.EQN Set interface for eqn propierty.
      %
      % param: eqn
      %
      % return: void

      if ~ischar(eqn) 
        error('eqn must be a char array.');
      end

      obj.eqn = eqn;
      obj.eqnSym = str2sym(eqn);
      
    end % set.eqn

    function [] = set.isAssign(obj,isAssign)
      %% SET.ISASSIGN Set interface for isAssign propierty.
      %
      % param: isAssign
      %
      % return: void
      
      if ~islogical(isAssign)
        error('isAssign must be logical.');
      end

      obj.isAssign = isAssign;
      
    end % set.isAssign

    function [out] =  get.left(obj)
      %% GET.LEFT Get left equal part of the equation.
      %
      % return: out Simbolic left part of the equation.

      ind_equal = strfind(obj.eqn,'=');

      out = obj.eqn(1:ind_equal(1)-1);

      out = str2sym(out).';
    end % get.left

    function [out] =  get.right(obj)
      %% GET.RIGHT Get right equal part of the equation.
      %
      % return: out Simbolic rigth part of the equation.

      ind_equal = strfind(obj.eqn,'=');

      out = obj.eqn(ind_equal(2)+1:end);

      out = str2sym(out).';
    end % get.right

    function [out] = get.vars(obj)
      %% GET.VARS Variables of the equation.
      %
      % return: out [sym] Variables of the equation.

      out = symvar(obj.eqnSym);
      
    end % get.vars

    function [out] = get.ders(obj)
      %% GET.DERS Get the variables that have a derivative in the equation.
      %
      % return: out Derivative variables.

      vars = obj.vars;

      expression = 'd_(\w*)';

      out = sym([]);
      for i = 1:length(vars)
        [tokens,matches] = regexp(char(vars(i)),expression,'tokens','match');
        if ~isempty(tokens)
          out(end+1) = sym(tokens{1});
          matches;
        end
      end

    end % get.ders

  end % methods

end % classdef
