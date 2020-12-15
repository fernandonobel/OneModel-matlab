classdef MatlabCodeCommand < LineCommand

  properties 
    % [char] Name used for the command. Name is auto-included to keywords.
    name = 'MatlabCode';
    % struct with the list of keywords that must be reserved for this command.
    keywords = {};
    
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

      % Check if base model exists.
      if ~isfile(name)
        error(...
          'The file "%s" does not exists. Check the filename and the path.',name)
      end

      [tokens,matches] = regexp(raw,'\s*MatlabCode\s([\s\S]*)end;','tokens','match');
      fprintf(fout,tokens{1}{1});

      end % execute

  end % methods

end % classdef
