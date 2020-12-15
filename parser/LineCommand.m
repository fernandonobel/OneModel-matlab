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

  end % methods
  
end % classdef
