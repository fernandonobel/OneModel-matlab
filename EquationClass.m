classdef EquationClass < handle
  %% EQUATIONCLASS This class defines equations for ModelClass.
  %

  properties
    % [sym] Simbolic equation.
    nameSym
    % [char] Char array equation.
    name
  end % properties

  properties (Dependent)
    % [left] Left part of the equation.
    left
    % [right] Right part of the equation.
    right 
  end % properties (Dependent)

  methods 

    function [obj] = EquationClass(eqn)
      %% Constructor of EquationClass.
      %
      % param: eqn [char] String with the equation.

      obj.nameSym = str2sym(eqn);
      obj.name = eqn;

    end % EquationClass

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

  end % methods

end % classdef
