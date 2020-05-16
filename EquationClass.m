classdef EquationClass < handle
  %% EQUATIONCLASS This class defines equations for ModelClass.
  %

  properties
    % [char] Char array equation.
    name
    % [sym] Simbolic equation.
    nameSym
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

    function [obj] = EquationClass(eqn)
      %% Constructor of EquationClass.
      %
      % param: eqn [char] String with the equation.

      obj.name = eqn;
      obj.nameSym = str2sym(eqn);

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

    function [out] =  get.left(obj)
      %% GET.LEFT Get left equal part of the equation.
      %
      % return: out Simbolic left part of the equation.

      ind_equal = strfind(obj.name,'=');

      out = obj.name(1:ind_equal(1)-1);

      out = str2sym(out).';
    end % get.left

    function [out] =  get.right(obj)
      %% GET.RIGHT Get right equal part of the equation.
      %
      % return: out Simbolic rigth part of the equation.

      ind_equal = strfind(obj.name,'=');

      out = obj.name(ind_equal(2)+1:end);

      out = str2sym(out).';
    end % get.right

    function [out] = get.vars(obj)
      %% GET.VARS Variables of the equation.
      %
      % return: out [sym] Variables of the equation.

      out = symvar(obj.nameSym);
      
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
