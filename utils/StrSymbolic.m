classdef StrSymbolic < handle
  %% STRSYMBOLIC This class implements symbolic operations but using strings
  % instead of using the symbolic toolbox. The functionallity developed in this
  % class is faster than the symbolic toolbox, but it is at the expense of using 
  % strings and not all the functionallity of the symbolic toolbox will be
  % implemented here. Use this class only for optimization purposes.
  %

  methods (Static)
    function [out] = symvar(in)
      %% SYMVAR Find symbolic variables in string input.
      %
      % param: in [char] String input.
      %
      % return: out {[char]} String variables.

      out = {};

      aux = in;
      % Add 'p.' to all state and parameters.
      ind = false(size(aux));
      % Search for everything but words.
      % Words cannot start with a number but they can contain numbers.
      ind(regexp(aux,'\W|(?<=[0-9])[a-zA-Z]')) = true;
      aux(ind)= ' ';
      % Remove numbers that follow an empty space.
      while 1
        ind_old = ind;
        ind(regexp(aux,'(?<=\s)\d')) = true;
        aux(ind)= ' ';
        offset = 0;
        if ~sum(ind ~= ind_old)
          break;
        end
      end

      for i = regexp(aux,'\w*')
        words = (split(aux(i:end)));
        word = words{1};

        if (exist(word,'builtin')==5)
          continue;
        end

        if (strcmp(word,'t'))
          continue;
        end

        out{end+1} = word;
      end

    end % symvar

    function [out] = subs(s,old,new)
      %% SUBS Symbolic substitution.
      %
      % param: s {[char]} String with the expression.
      %      : old {[char]} Variable to be substituted in s.
      %      : new {[char]} New value for old.
      %
      % return: out {[char]} String with the substitution done.

      cont = 0;

      while any(strcmp(old,StrSymbolic.symvar(s)))

        for i = 1:length(old)
          s = strrep(s,old{i},new{i});
        end

        cont = cont + 1;

        if cont > 50
          error('The substitution does not converge. Check that the arguments are coherent.');
        end

      end

      out = s;

    end % subs

  end % methods

end % classdef