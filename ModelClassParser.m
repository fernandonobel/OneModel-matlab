classdef ModelClassParser < handle
  %% MODELCLASSPARSER This class parses files .mc into ModelClass models.
  %

  properties
    % [char] Name of the model to parse.
    filename
    % [char] Base name of the model without extension.
    basename
    % [char] Name for the ModelClass model.
    nameM
    % {Command} List of command defined for the parser.
    commands = {}
    % {filename} Filename of extended files. This is to avoid infinite recursion
    % of files
    filenameExtended = {}

  end % properties

  methods 

    function [obj] = ModelClassParser(filename)
      %% Constructor of ModelClassParser.
      %
      % param: filename File to parse into a ModelClass.

      obj.filename = filename;

      [folder, baseFileNameNoExt, extension] = fileparts(obj.filename);

      obj.basename = baseFileNameNoExt;

      obj.nameM = [baseFileNameNoExt '.m'];

      % Add here all the commands of the parser.
      obj.commands = {
      TestCommand()
      };

    end % ModelClassParser

    function [] = parse(obj)
      %% PARSE Parse the file into the a ModelClass.
      %
      % return: void

      % Open the model.
      obj.avoidRecursion(obj.filename);
      fid = fopen(obj.filename);

      % Open the generated model.
      fout = fopen(obj.nameM,'w');

      obj.addHeader(fout);

      obj.executeFileLines(fid,fout);

      obj.addFooter(fout);

      fclose(fid);
      fclose(fout);

    end % parse

    function [] = executeFileLines(obj,fid,fout)
      %% EXECUTEFILELINES 
      %
      % param: fid File descriptor to read.
      %      : fout File descriptor to write.
      %
      % return: void

      % Read a line of the model.
      tline = fgets(fid);

      % Aux buffer for preparing the lines to be executed.
      aux = '';

      % Variable to store the current command to execute.
      cmd = [];

      while ischar(tline)
        % Remove commented text in lines.
        tline = obj.removeComments(tline);

        % Remove empty lines.
        if isempty(tline)
          tline = fgets(fid);
          continue;
        end

        % Process char by char the line readed.
        for i = 1:length(tline)
          aux(end+1) = tline(i);

          % If we did not find a command.
          if isempty(cmd)
            % Look if any of the commands in the list is found.
            for i = 1:length(commands)
              % If any of the commands if found.
              if commands{i}.findCommand(aux)
                % Save it and stop looking for more commands.
                cmd = commands{i};
                break;
              end
            end
          end

          % If we have found a command
          if ~isempty(cmd)
            % Collect all the argument data needed for the command in aux.

            % Is the argument complete?
            if cmd.isArgumentComplete(aux)
              % Execute the comand.
              cmd.execute(aux, fout);

              fprintf(fout,'\n');

              % Reset the aux for new lines.
              aux = '';
              % Reset the cmd for new commands.
              cmd = [];
            end
          end
        end

        % Read the next line in the document.
        tline = fgets(fid);
      end

      % Check if something is remaining in aux after finishing the model.
      if ~all(isspace(aux)) && ~isempty(aux)
        feval(cmd,obj,aux,-1);
      end
    end % executeFileLines

    function [out] = removeComments(obj,tline)
      %% REMOVECOMMENTS Remove commented text of the model text.
      %
      % param: tline Line where to find and remove comments.
      %
      % return: out Line without comments.

      ind = strfind(tline,'%');

      if ~isempty(ind)
        tline = tline(1:ind(1)-1);
      end

      out = tline;

    end % removeComments

    function [] = addHeader(obj,fout)
      %% ADDHEADER Add the header to the Matlab Class.
      %
      % param: fout File output.
      %
      % return: void

      fprintf(fout,'classdef %s < ModelClass\n',obj.basename);
      fprintf(fout,'\tmethods\n');
      fprintf(fout,'\t\tfunction [obj] = %s()\n',obj.basename);

    end % addHeader

    function [] = addFooter(obj,fout)
      %% ADDFOOTER Add the footer to the Matlab Class.
      %
      % param: fout File output.
      %
      % return: void

      fprintf(fout,'\t\t\tobj.checkValidModel();\n');

      fprintf(fout,'\t\tend\n');
      fprintf(fout,'\tend\n');
      fprintf(fout,'end\n');

    end % addFooter

    function [] = avoidRecursion(obj,filename)
      %% AVOIDRECURSION Check if the filename was already used to avoid
      % recursion.
      %
      % param: filename Filename to check.
      %
      % return: void

      [pathstr,name,ext] = fileparts(filename);

      if any(strcmp(obj.filenameExtended,name),'all')
        error('The file "%s" was already included in the model. The parsing of the model was stoped to avoid infinite recursion.',name);
      end

      obj.filenameExtended{end+1} = name;

    end % avoidRecursion

  end %methods

  % Utils for building ModelClass commands.
  methods 
    function [isComplete,isReturn,fout,name,options] = lineCommand_init(obj,raw,fout)
      %% LINECOMMAND_INIT This function execute the init funtionally of commmands
      % that are ended by a ';'.
      %
      % param: raw  Raw data of the command.
      %      : fout File output
      %
      % return: isComplete True if raw has all the information to execute the command.
      %         isReturn True if the command has to perform a return.
      %         fout File output
      %         name The name of the object defined by the command.
      %         options The options associted with the name.

      if ~exist('fout','var')
        fout = [];
      end

      name = [];
      options = [];

      % Just for checking if the function exists.
      if nargin == 1
        isComplete = false;
        isReturn = true;
        return;
      end

      % Check if arg has all the data we need to perform this command.
      if nargin == 2
        if raw(end) == ';'
          % The argument is complete.
          isComplete = true;
        else
          % The argument is incomplete.
          isComplete = false;
        end
        isReturn = true;
        return;
      end

      % Execute the command.
      if nargin == 3
        isComplete = [];
        isReturn = false;

        % Remove intros.
        raw = raw(raw~=newline);
        arg = obj.getArgument(raw);
        [name,options] = obj.getOptions(arg);
      end

    end % initLineCommand

    function [arg] = getArgument(obj,tline)
      %% GETARGUMENT Get the command and argument of a line.
      % argument.
      %
      % param: tline Line of the model to interprect.
      %
      % return: arg The argument of the command.

      arg = [];

      expression = '\s*\w*\s(.+);';

      [tokens,matches] = regexp(tline,expression,'tokens','match');

      if ~isempty(tokens)
        arg = tokens{1}{1};
      end

    end % getArgument

    function [name,options] = getOptions(obj,arg)
      %% GETOPTIONS Get and process the options for the commands.
      %
      % param: arg Raw argument.
      %
      % return: name Main name for the variable/parameter.
      %         options Options to set for the variable/parameter.

      % TODO:
      % Look for no name no arguments syntaxis: 1+b==a
      if ~any(strfind(arg, '('))
        name = arg;
        options{1} = [];
        return
      end

      % Look for no name no arguments syntaxis: 1+b==a*(1+c)
      expression = '(.*?)\(';
      [tokens,matches] = regexp(arg,expression,'tokens','match');

      if ~isempty(tokens) && any(isspace(tokens{1}{1}))
        name = '';
        options{1} = arg;
        return
      end


      % Look for the normal syntaxis: name(arg1=true,arg2=fals)
      expression = '(\w*)\((.+)\)';
      [tokens,matches] = regexp(arg,expression,'tokens','match');

      if isempty(tokens)
        name = arg;
        options = [];
      else
        name = tokens{1}{1};

        arg = tokens{1}{2};
        expression = ',(?![^\(]*\))';
        ind = regexp(arg,expression);

        if ~isempty(ind) 
          options{1} = arg(1:ind(1)-1);

          for i = 1:length(ind)-1
            options{i+1} = arg(ind(i)+1:ind(i+1)-1);
          end

          options{end+1} = arg(ind(end)+1:end);
        else
          options{1} = arg;
        end

      end

      for i=1:length(options)
        options{i} = obj.removeSpace(options{i});
      end

    end % getOptions

    function [out] = removeSpace(obj,in)
      %% REMOVESPACE Remove unnecessary space in string but keep the spaces
      % between "'".
      %
      % param: in String with spaces.
      %
      % return: out String without unnecessary spaces.

      % Remove space at the beggining or end of the string.
      expression = '^[ \t]+|[ \t]+$';
      splits = regexp(in,expression,'split');

      % Save option without the empty splits.
      for i = 1:length(splits)
        if ~isempty(splits{i}) 
          in = splits{i};
        end
      end

      out = in;

    end % removeSpace

  end % methods

  % Commands for building ModelClass models.
  methods

    function [isComplete] = Variable(obj,varargin)
      %% VARIABLE Add a variable to the Model Class.
      % If fout is not provided, it will just return true if the arg is complete.
      %
      % [out] = Variable(obj,arg,fout)
      %
      % param: raw  Raw data of the command.
      %      : fout File output
      %
      % return: isComplete True if raw has all the information needed.

      [isComplete, isReturn, fout, name, options] = obj.lineCommand_init(varargin{:});

      if isReturn
        return;
      end

      % Error. The data of the model ended and the command wasn't complete.
      if fout == -1
        st = dbstack;
        error('the command ''%s'' has an error.',st(1).name);
      end

      fprintf(fout,'\t\t\tv = VariableClass(''%s'');\n',name);

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
          fprintf(fout,'\t\t\tv.isSubstitution=true;\n',options{i});
          % And generate its correspondign equation.
          arg = compose(' %s_eq(%s == %s, isSubstitution = true);',name,name,tokens{1}{2});
          obj.Equation(arg{1},fout);
        else
          fprintf(fout,'\t\t\tv.%s;\n',options{i});
        end
        %fprintf(fout,'\t\t\tv.%s;\n',options{i});
      end

      fprintf(fout,'\t\t\tobj.addVariable(v);\n');

    end % Variable

    function [isComplete] = Parameter(obj,varargin)
      %% PARAMETER Add a parameter to the Model Class.
      %
      % param: arg Arguments
      %      : fout File output
      %
      % return: isComplete True if arg has all the information needed.

      [isComplete, isReturn, fout, name, options] = obj.lineCommand_init(varargin{:});

      if isReturn
        return;
      end

      % Error. The data of the model ended and the command wasn't complete.
      if fout == -1
        st = dbstack;
        error('the command ''%s'' has an error.',st(1).name);
      end

      fprintf(fout,'\t\t\tp = ParameterClass(''%s'');\n',name);

      for i=1:length(options)
        % Skip empty options.
        if isempty(options{i})
          continue
        end

        fprintf(fout,'\t\t\tp.%s;\n',options{i});

      end

      fprintf(fout,'\t\t\tobj.addParameter(p);\n');

    end % Parameter

    function [isComplete] = Equation(obj,varargin)
      %% EQUATION Add an equation to the Model Class.
      %
      % param: arg Arguments
      %      : fout File output
      %
      % return: isComplete True if arg has all the information needed.

      [isComplete, isReturn, fout, name, options] = obj.lineCommand_init(varargin{:});

      if isReturn
        return;
      end

      % Error. The data of the model ended and the command wasn't complete.
      if fout == -1
        st = dbstack;
        error('the command ''%s'' has an error.',st(1).name);
      end

      if isempty(options{1})
        options{1} = name;
        name = '';
      end

      fprintf(fout,'\t\t\te = EquationClass(''%s'');\n',name);      

      try
        fprintf(fout,'\t\t\te.eqn = ''%s'';\n',options{1});
      catch
        error('eqn is not defined in the options.');
      end

      for i=2:length(options)
        % Skip empty options.
        if isempty(options{i})
          continue
        end

        fprintf(fout,'\t\t\te.%s;\n',options{i});

      end

      fprintf(fout,'\t\t\tobj.addEquation(e);\n');

    end % Equation

    function [isComplete] = extends(obj,varargin)
      %% EXTENDS Extends the actual model with the information of a base
      % model
      %
      % param: arg Arguments
      %      : fout File output
      %
      % return: isComplete True if arg has all the information needed.

      [isComplete, isReturn, fout, name, options] = obj.lineCommand_init(varargin{:});

      if isReturn
        return;
      end

      % Error. The data of the model ended and the command wasn't complete.
      if fout == -1
        st = dbstack;
        error('the command ''%s'' has an error.',st(1).name);
      end

      % Check if base model exists.
      if ~isfile(name)
        error(...
          'The file "%s" does not exists. Check the filename and the path.',name)
      end

      % Open the base model.
      obj.avoidRecursion(name);
      fBase = fopen(name);

      obj.executeFileLines(fBase,fout);

      fclose(fBase);

    end % extends


    function [isComplete] = MatlabCode(obj,raw,fout)
      %% MATLABCODE Allows to execute matlab code defined in the .mc model.
      %
      % param: raw Raw data.
      %      : fout File output
      %
      % return: isComplete True if arg has all the information needed.

      if ~exist('fout','var')
        fout = [];
      end

      % Error. The data of the model ended and the command wasn't complete.
      if fout == -1
        st = dbstack;
        error('the command ''%s'' has an error.',st(1).name);
      end

      % Just for checking if the function exists.
      if nargin == 1
        isComplete = false;
        return;
      end

      % Check if arg has all the data we need to perform this command.
      if nargin == 2
        if endsWith(raw,'end;')
          % The argument is complete.
          isComplete = true;
        else
          % The argument is incomplete.
          isComplete = false;
        end
        return;
      end

      % Execute the command.
      if nargin == 3
        isComplete = [];
      end

      [tokens,matches] = regexp(raw,'\s*MatlabCode\s([\s\S]*)end;','tokens','match');
      fprintf(fout,tokens{1}{1});

    end % MatlabCode

    function [isComplete] = SimOptions(obj,raw,fout)
      %% SIMOPTIONS This command sets the options for the simulation.
      %
      % param: raw Raw data.
      %      : fout File output
      %
      % return: isComplete

      if ~exist('fout','var')
        fout = [];
      end

      % Error. The data of the model ended and the command wasn't complete.
      if fout == -1
        st = dbstack;
        error('the command ''%s'' has an error.',st(1).name);
      end

      % Just for checking if the function exists.
      if nargin == 1
        isComplete = false;
        return;
      end

      % Check if arg has all the data we need to perform this command.
      if nargin == 2
        if endsWith(raw,';')
          % The argument is complete.
          isComplete = true;
        else
          % The argument is incomplete.
          isComplete = false;
        end
        return;
      end

      % Execute the command.
      if nargin == 3
        isComplete = [];
      end

      [tokens,matches] = regexp(raw,'SimOptions\s*(.*);','tokens','match');

      fprintf(fout,['\t\t\tobj.simOptions.' tokens{1}{1} ';']);

    end % SimOptions

    function [isComplete] = Class(obj,raw,fout)
      %% CLASS This command allow us to define classes.
      %
      % param: raw Raw data.
      %      : fout File output.
      %
      % return: isComplete

      if ~exist('fout','var')
        fout = [];
      end

      % Error. The data of the model ended and the command wasn't complete.
      if fout == -1
        % Get the name of the class we want do define.
        [tokens,matches] = regexp(raw,'Class\s*(\w*)\s*','tokens','match');

        error('the Class ''%s'' was defined but it has no ending. ',tokens{1}{1});
      end

      % Just for checking if the function exists.
      if nargin == 1
        isComplete = false;
        return;
      end

      % Check if arg has all the data we need to perform this command.
      if nargin == 2
        % Get the name of the class we want do define.
        [tokens,matches] = regexp(raw,'Class\s*(\w*)\s*','tokens','match');

        if isempty(tokens)
          % The argument is incomplete.
          isComplete = false;
          return;
        end

        if endsWith(raw,['end ' tokens{1}{1} ';'])
          % The argument is complete.
          isComplete = true;
        else
          % The argument is incomplete.
          isComplete = false;
        end

      end

      % Execute the command.
      if nargin == 3
        isComplete = [];
      end

      %[tokens,matches] = regexp(raw,'SimOptions\s*(.*);','tokens','match');

      %fprintf(fout,['\t\t\tobj.simOptions.' tokens{1}{1} ';']);

    end % Class

  end % methods

end % classdef
