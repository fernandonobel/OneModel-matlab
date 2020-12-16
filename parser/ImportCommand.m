classdef ImportCommand < LineCommand

  properties 
    % [char] Name used for the command. Name is auto-included to keywords.
    name = 'Import';
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

      % Check if base model exists.
      if ~isfile(name)
        error(...
          'The file "%s" does not exists. Check the filename and the path.',name)
      end

      % Open the base model.
      mcp.avoidRecursion(name);
      fBase = fopen(name);

      obj.executeFileLines(fBase,mcp.fout);

      fclose(fBase);

      end % execute

  end % methods

end % classdef



