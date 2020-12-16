classdef EquationCommand < LineCommand

  properties 
    % [char] Name used for the command. Name is auto-included to keywords.
    name = 'Equation';
    % {[char]} struct with the list of keywords that must be reserved for this command.
    keywords = {};
    % [char] End sequence of the command.
    endWith = ';';
    
  end % properties 

  methods

    function [] = execute(obj, raw, mcp)
      %% EXECUTE Execute the command.
      %
      % param: raw  Raw text from the ModelClass file.
      %        mcp  ModelClassParser object.
      %
      % return: true if the argument is complete.

      % Remove intros.
      raw = raw(raw~=newline);
      arg = obj.getArgument(raw);
      [name,options] = obj.getOptions(arg);

      if isempty(options{1})
        options{1} = name;
        name = '';
      end

      fprintf(mcp.fout,'\t\t\te = EquationClass(''%s'');\n',name);      

      try
        fprintf(mcp.fout,'\t\t\te.eqn = ''%s'';\n',options{1});
      catch
        error('eqn is not defined in the options.');
      end

      for i=2:length(options)
        % Skip empty options.
        if isempty(options{i})
          continue
        end

        fprintf(mcp.fout,'\t\t\te.%s;\n',options{i});

      end

      fprintf(mcp.fout,'\t\t\tobj.addEquation(e);\n');

      end % execute

  end % methods

end % classdef


