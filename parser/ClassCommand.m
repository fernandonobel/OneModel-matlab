classdef ClassCommand < LineCommand

  properties 
    % [char] Name used for the command. Name is auto-included to keywords.
    name = 'Class';
    % {[char]} struct with the list of keywords that must be reserved for this command.
    keywords = {};
    % [char] End sequence of the command. It is defined dynamically.
    endWith; 
    
  end % properties 

  methods

    function out = isComplete(obj, raw)
      %% ISCOMPLETE Does the command have everything it needs to run?
      %
      % param: raw Raw text from the ModelClass file.
      %
      % return: true if the argument is complete.

      [tokens] = regexp(raw,'\s*Class\s\s*(\w*)\s*','tokens');
      
      if isempty(tokens)
          out = false;
          return;
      end
      
      obj.endWith = ['\s*end\s\s*' tokens{1}{1} '\s*;'];

      out = isComplete@LineCommand(obj, raw);

    end


    function [] = execute(obj, raw, mcp)
      %% EXECUTE Execute the command.
      %
      % param: raw  Raw text from the ModelClass file.
      %        mcp  ModelClassParser object.
      %
      % return: true if the argument is complete.

      % TODO

      end % execute

  end % methods

end % classdef


