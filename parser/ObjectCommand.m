classdef ObjectCommand < LineCommand

  properties 
    % [char] Name used for the command. Name is auto-included to keywords.
    name;
    % {[char]} struct with the list of keywords that must be reserved for this command.
    keywords = {};
    % [char] End sequence of the command.
    endWith = ';';

  end % properties 

  methods

    function [out] = findCommand(obj, raw)
      %% FINDCOMMAND Is the start of the command found?
      %
      % param: raw Raw text from the ModelClass file.
      %
      % return: out true if the start of the command is found.

      % The command is found when the name of a defined class is found.
      [matches] = regexp(raw,'\s*(\w*)\s*,'match');

      out = ~isempty(matches);

    end % findCommand 

    function [] = execute(obj, raw)
      %% EXECUTE Execute the command.
      %
      % param: raw  Raw text from the ModelClass file.
      %
      % return: true if the argument is complete.

      % TODO

    end % execute

  end % methods

end % classdef


