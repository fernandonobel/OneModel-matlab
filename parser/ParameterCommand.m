classdef ParameterCommand < LineCommand

  properties 
    % [char] Name used for the command. Name is auto-included to keywords.
    name = 'parameter';
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

      fprintf(obj.mcp.fout,'\t\t\tp = ParameterClass(obj,''%s'');\n',name);

      for i=1:length(options)
        % Skip empty options.
        if isempty(options{i})
          continue
        end

        fprintf(obj.mcp.fout,'\t\t\tp.%s;\n',options{i});

      end

      fprintf(obj.mcp.fout,'\t\t\tobj.addParameter(p);\n');

    end % execute

  end % methods

end % classdef

