classdef SimOptionsCommand < LineCommand

  properties 
    % [char] Name used for the command. Name is auto-included to keywords.
    name = 'SimOptions';
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

      [tokens,matches] = regexp(raw,'SimOptions\s*(.*);','tokens','match');
      fprintf(mcp.fout,['\t\t\tobj.simOptions.' tokens{1}{1} ';']);

      end % execute

  end % methods

end % classdef


