classdef VariableCommand < LineCommand

  properties 
    % [char] Name used for the command. Name is auto-included to keywords.
    name = 'Variable';
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

      fprintf(obj.mcp.fout,'\t\t\tv = VariableClass(obj,''%s'');\n',name);

      for i=1:length(options)
        % Skip empty options.
        if isempty(options{i})
          continue
        end
        expression = '(.*)=(.*)';
        [tokens,matches] = regexp(options{i},expression,'tokens','match');

        % Get the option to execute
        option = tokens{1}{1};

        % And remove spaces at begging and at end.
        option = obj.removeSpace(option);

        if strcmp(option,'value')
          % Set variable as a substitution.
          fprintf(obj.mcp.fout,'\t\t\tv.isSubstitution=true;\n',options{i});
          % And generate its correspondign equation.
          arg = compose('Equation %s_eq(%s == %s, isSubstitution = true);',name,name,tokens{1}{2});
          
          equation = EquationCommand(obj.mcp);
          equation.execute(arg{1});
        else
          fprintf(obj.mcp.fout,'\t\t\tv.%s;\n',options{i});
        end
      end

      fprintf(obj.mcp.fout,'\t\t\tobj.addVariable(v);\n');

    end % execute

  end % methods

end % classdef
