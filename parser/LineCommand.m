classdef (Abstract) LineCommand < Command
  %% LINECOMMAND Class for the definiton of line commands
  %
  % This class implements the typical structure of a line command.
  % A line command starts with the command name and ends with a ';'.
  %
  % For example:
  %   Variable x;
  %   Variable x(start = 0.0);
  %   Variable x(
  %     start = 0.0
  %   );
  %   input Variable x;

  properties (Abstract)
    % [char] Name used for the command.
    name

  end % properties

  methods 

    function [obj] = LineCommand()
      %% Constructor of LineCommand.
      %

      % Add the name of the command to the keywords to reserve.
      obj.keywords{end+1} = obj.name;

    end % LineCommand

    function [out] = findCommand(obj, raw)
      %% FINDCOMMAND Is the start of the command found?
      %
      % param: raw Raw text from the ModelClass file.
      %
      % return: out true if the start of the command is found.

      expr = ['\s*' obj.name '\s*'];

      % The command is found when 'Test is found.
      [matches] = regexp(raw,expr,'match');

      out = ~isempty(matches);

    end % findCommand 

    function out = isArgumentComplete(obj, raw)
      %% ISARGUMENTCOMPLETE Does the command have everything it needs to run?
      %
      % param: raw Raw text from the ModelClass file.
      %
      % return: true if the argument is complete.

      % The argument is complete when ';' is found.
      [matches] = regexp(raw,';','match');

      out = ~isempty(matches);
    end

    function [arg] = getArgument(obj,raw)
      %% GETARGUMENT Get the argument of a line command.
      %
      % param: raw Raw text from the ModelClass file.
      %
      % return: arg The argument of the command.

      arg = [];

      expression = '\s*\w*\s(.+);';

      [tokens,matches] = regexp(raw,expression,'tokens','match');

      if ~isempty(tokens)
        arg = tokens{1}{1};
      end

    end % getArgument

    function [name,options] = getOptions(obj,arg)
      %% GETOPTIONS Get and process the options for the commands.
      %
      % param: arg Raw argument.
      %
      % return: name Main name for the variable/parameter.
      %         options Options to set for the variable/parameter.

      % TODO:
      % Look for no name no arguments syntaxis: 1+b==a
      if ~any(strfind(arg, '('))
        name = arg;
        options{1} = [];
        return
      end

      % Look for no name no arguments syntaxis: 1+b==a*(1+c)
      expression = '(.*?)\(';
      [tokens,matches] = regexp(arg,expression,'tokens','match');

      if ~isempty(tokens) && any(isspace(tokens{1}{1}))
        name = '';
        options{1} = arg;
        return
      end


      % Look for the normal syntaxis: name(arg1=true,arg2=fals)
      expression = '(\w*)\((.+)\)';
      [tokens,matches] = regexp(arg,expression,'tokens','match');

      if isempty(tokens)
        name = arg;
        options = [];
      else
        name = tokens{1}{1};

        arg = tokens{1}{2};
        expression = ',(?![^\(]*\))';
        ind = regexp(arg,expression);

        if ~isempty(ind) 
          options{1} = arg(1:ind(1)-1);

          for i = 1:length(ind)-1
            options{i+1} = arg(ind(i)+1:ind(i+1)-1);
          end

          options{end+1} = arg(ind(end)+1:end);
        else
          options{1} = arg;
        end

      end

      for i=1:length(options)
        options{i} = obj.removeSpace(options{i});
      end

    end % getOptions

  end % methods

end % classdef
