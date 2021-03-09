classdef ConnectCommand < LineCommand

  properties 
    % [char] Name used for the command. Name is auto-included to keywords.
    name = 'Connect';
    % {[char]} struct with the list of keywords that must be reserved for this command.
    keywords = {};
    % [char] End sequence of the command.
    endWith = ';';
    
  end % properties 

  methods

    function [] = execute(obj, raw)
      %% EXECUTE Execute the command.
      %
      % param: raw  Raw text from the ModelClass file.
      %
      % return: true if the argument is complete.

      % Remove intros.
      raw = raw(raw~=newline);
      arg = obj.getArgument(raw);
      [name,options] = obj.getOptions(arg);
      
      if length(options) ~= 2
          error(['"' obj.name '" must have only two arguments. \n\n %s'], raw); 
      end
      
      arg = compose(' (%s == %s, isSubstitution = true);',options{1},options{2});
      
      equation = EquationCommand(obj.mcp);
      equation.execute(arg{1});

      end % execute

  end % methods

end % classdef

