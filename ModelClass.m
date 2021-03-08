classdef (Abstract) ModelClass < handle
  %% MODELCLASS This class simplifies working with ODE models.
  % The main idea is to simplify the work of building a ODE model,
  % and therefore reducing the time spent in this process. The main
  % utilities of this class are: (i) doing simulations from symbolic
  % ODEs, (ii) linearize the model at the equilibrium point, (iii)
  % calculate eigenvalues. Using this class has many advantages like
  % having to code less, it is easier to maintain ODE models and all 
  % your models will have these utilities.

  % Model data.
  properties 
    % When defining the model it is possible to declare Varibles and Equations
    % that are just a substitution of variables or parameters. Then this
    % subsitution equations are only useful for grouping terms to simplify the
    % reading of the model but these equation do not provide new relationships
    % between variables. So normally, we would like to work with the
    % susbtitution (model not reduced) but sometimes (for simulation purposes)
    % it is better to have the model without out any of these intermediate 
    % variables (model reduced). For this purpose it is defined the property 
    % 'isReduced' to swicth between these two behaivours.

    % bool Use the extended model?
    isReduced = false

    % [char] The current namespace being used. 
    % This variable will be used during the initialization to inidicate the 
    % current namespace that has to be used for defined ModelParts which does 
    % not have a defined namespace.
    namespace

    % {char} List of file dependencies.
    % This is used to check if the generated .m is up-to-date with the .mc model
    % If it is up-to-date, the .m code wont be generated again to save 
    % computation time.
    dependenciesPath = {}

  end

  properties (Dependent)
    % [sym] Variables of the model.      
    vars                
    % [bool] Is an algebraic variable?     
    varsIsAlgebraic
    % {[char]} Names of the vars of the model.
    varsName
    % [real] Initial condition of the vars.
    varsStart
    % [bool] Is an no negative state?
    varsIsNoNegative
    % [int] Index of variables that are no negative.
    varsIndexNoNegative
    % [bool] Should var be plotted?
    varsPlot
    % int Number of variables.
    varsNum
    % [sym] Equations of the model. 
    eqns                
    % {str} Names of the equations.
    eqnsName
    % [sym] Left part of the equations.
    eqnsLeft
    % [sym] Right part of the equations.
    eqnsRight          
    % [sym] Derivatives of the model.
    ders                
    % [bool] Is the equation just a substitution of vars?
    isSubs
    % [sym] Parameters of the model.
    params              
    % {[char]} Names of the parameters of the model.
    paramsName
    % [real] Default value of the parameters.
    paramsValue 
    % {[char]} Names of the symbols of the model.
    symbolsName
    % [bool] Should the symbol be plotted?
    symbolsIsPlot
  end % propierties (Dependent)

  %properties (Dependent, Access = private)
  properties (Dependent, Access = private)
    % [int] Index that match each variable with the related equation.
    varIndex 
  end % properties (Dependent)

  properties % (Access = private)
    % [SymbolClass] Array with all the symbols of the model.
    symbols
    % [VariableClass] Array with all the variables of the model.
    variables
    % [ParameterClass] Array with all the parameters of the model.
    parameters
    % [EquationClass] Array with all the equations of the model.
    equations
    % SimulationOptionsClass Object with the simulation options.
    simOptions
  end % Propierties (Access = private)

  %% Contructors
  methods
    function [obj] =  ModelClass()
      %% MODELCLASS Constructor of Model Class.
      %
      % return: obj ModelClass object.

      % Default value of the namespace.
      obj.namespace = '';

      obj.variables = VariableClass.empty();
      obj.parameters = ParameterClass.empty();
      obj.symbols = SymbolClass.empty();
      obj.equations = EquationClass.empty();
      obj.simOptions = SimulationOptionsClass();

    end % ModelClass
  end % methods

  % ModelClass propierties.
  methods
    function [] = set.isReduced(obj,isReduced)
      %% SET.ISREDUCED Set interface for isReduced propierty.
      %
      % param: isReduced [bool] Use the reduced model?.
      %
      % return: void

      if ~islogical(isReduced)
        error('isReduced must be logical.');
      end

      obj.isReduced = isReduced;

    end % set.isReduced

  end % methods

  %% Model definition.
  methods
    function [] =  addVariable(obj,v)
      %% ADDVARIABLE Add a variable to the model.
      %
      % param: v Variable to include.
      %
      % return: void

      obj.variables(end+1) = v;
      obj.symbols{end+1} = v;

    end % addVariable

    function [] =  addParameter(obj,p)
      %% ADDVARIABLE Add a parameter to the model.
      %
      % param: p Parameter to include.
      %
      % return: void

      obj.parameters(end+1) = p;
      obj.symbols{end+1} = p;

    end % addParameter

    function [] =  addEquation(obj,e)
      %% ADDVARIABLE Add an equation to the model.
      %
      % param: e Equation to include.
      %
      % return: void

      obj.equations(end+1) = e;

    end % addEquation

    function [out] = getEquationByName(obj,name)
      %% GETEQUATIONBYNAME Get the Equation object by its name.
      %
      % param: name String with the name of the equation.
      %
      % return: out

      if ~contains(name,'__')
        % Take into accout the namespace.
        name = [obj.namespace name]; 
      end

      aux = obj.isReduced;
      obj.isReduced = false;

      names = obj.eqnsName();

      out = obj.equations(strcmp(name, names));

      obj.isReduced = aux;

    end % getEquationByName

    function [] = updateEquation(obj,eqn)
      %% UPDATEEQUATION Update an equation object with new information.
      %
      % param: eqn New equation object to replace the old one.
      %
      % return: void

      name = eqn.name;

      aux = obj.isReduced;
      obj.isReduced = false;

      names = obj.eqnsName();

      obj.equations(strcmp(name, names)) = eqn;

      obj.isReduced = aux;

    end % updateEquation

    function [out] = getSymbolByName(obj,name)
      %% GETSYMBOLBYNAME Get the Symbol (Variable or Parameter) object by its 
      % name.
      %
      % param: name [char] String with the name of the Symbol.
      %
      % return: out Variable Object symbol.

      aux = obj.isReduced;
      obj.isReduced = false;

      names = obj.symbolsName();

      out = obj.symbols{strcmp(name, names)};

      obj.isReduced = aux;

    end % getSymbolByName

    function [] = updateSymbol(obj,symbol)
      %% UPDATESYMBOL Update a symbol with new information.
      %
      % param: symbol New symbol object to replace the old one.
      %
      % return: void

      aux = obj.isReduced;
      obj.isReduced = false;

      names = obj.symbolsName();

      obj.symbols{strcmp(symbol.name, names)} = symbol;

      obj.isReduced = aux;

    end % updateSymbol

    function [] = checkValidModel(obj)
      %% CHECKVALIDMODEL Check if the model is valid. 
      % This involves: 
      %   (1) duplicate use of symbols names.
      %
      % return: void


      % (1) Check if there is duplicate use of symbols names.
      [U, I] = unique(obj.symbolsName, 'first');

      if length(obj.symbolsName) ~= length(U)
        % There are duplicates.
        duplicateNames = obj.symbolsName;
        duplicateNames(I) = [];

        error('The symbol name "%s" is duplicated in the model. Please change the name in one of its definitions.', duplicateNames{1});
      end

      % (2) Reorganize the equations to match the corresponding variable.
      obj.equations = [obj.equations(obj.varIndex)];


    end % checkValidModel

  end % methods

  %% Model data.
  methods
    function [] = set.namespace(obj,in)
      %% SET.NAMESPACE Set interface for namespace.
      %
      % param: in [char] Namespace to set

      % If "in" is empty.
      if isempty(in)
        % Set the namespace to empty.
        obj.namespace = in;
        return;
      end

      % Check if it is a valid name for a namespace.
      if isvarname(in)
        % Set it.
        obj.namespace = [in '__'];
      else
        % Throw an error.
        error('''%s'' is not a valid name for a namespace.', in);
      end

    end % set.namespace

    function [out] =  get.vars(obj)
      %% GET.VARS Get symbolic variables of the model.
      %
      % return: out Symbolic varibles array.

      out = [obj.variables.nameSym].';

      % Return reduced model if needed.
      if obj.isReduced
        out = out(~obj.isSubs);
      end

    end % get.vars

    function [out] =  get.varsIsAlgebraic(obj)
      %% GET.VARSISALGEBRAIC Are the variables algebraics?
      % Get a boolean array, if true the variable corresponding to that 
      % index is algebraic.
      %
      % return: out Boolean array.

      for i = 1:length(obj.variables)
        out(i,1) = obj.equations(i).isAlgebraic;
      end

      % Return reduced model if needed.
      if obj.isReduced
        out = out(~obj.isSubs);
      end

    end % get.varsIsAlgebraic

    function [out] =  get.varsName(obj)
      %% GET.VARSNAME  Get vars name.
      %
      % return: out {[char]} Names of the vars of the model.

      out = {obj.variables.name}.';

      % Return reduced model if needed.
      if obj.isReduced
        out = out(~obj.isSubs);
      end

    end % get.varsName

    function [out] = get.varsStart(obj)
      %% GET.VARSSTART Get vars start.
      %
      % return: out [real] Initial condition values.

      out = [obj.variables.start];

      % Return reduced model if needed.
      if obj.isReduced
        out = out(~obj.isSubs);
      end

    end % get.varsStart

    function [out] =  get.varsIsNoNegative(obj)
      %% GET.VARSNONEGATIVE Get no negative vars.
      %
      % return: out [bool] True if the var on that index is no negative.

      out = [];

      for i = 1:length(obj.variables)
        if obj.variables(i).isNoNegative == true
          out(end+1) = i;
        end
      end

      out = [obj.variables.isNoNegative];

      % Return reduced model if needed.
      if obj.isReduced
        out = out(~obj.isSubs);
      end

    end % get.varsNoNegative

    function [out] =  get.varsIndexNoNegative(obj)
      %% GET.VARSINDEXNONEGATIVE Get index of no negative vars.
      %
      % return: out [int] Index of no negative vars.

      out = [];

      for i = 1:length(obj.variables)
        if obj.variables(i).isNoNegative == true
          out(end+1) = i;
        end
      end

      % Return reduced model if needed.
      if obj.isReduced && ~isempty(out)
        out = out(~obj.isSubs);
      end

    end % get.varsIndexNoNegative


    function [out] =  get.varsPlot(obj)
      %% GET.VARSPLOT Should var be plotted?
      %
      % return: out [bool] varsPlot.

      out  = [obj.variables.isPlot];

      % Return reduced model if needed.
      if obj.isReduced
        out = out(~obj.isSubs);
      end

    end % get.varsPlot

    function [out] =  get.varsNum(obj)
      %% GET.VARSPLOT Number of variables in the model.
      %
      % return: out int varsNum.

      % Return reduced model if needed.
      if obj.isReduced
        out = sum(~obj.isSubs);
      else
        out = length(obj.variables);
      end

    end % get.varsPlot

    function [out] = get.varIndex(obj)
      %% GET.VARINDEX Index that relates each variable with the equation that
      % calculate it.
      %
      % return: out [int] varIndex

      % It is necessay to order the eqns to math the order of the vars. This way
      % the process of simulation is simplified a lot.

      % The number of free variables must match the number of equations.
      if length(obj.variables) ~= length(obj.equations)
        error('The number of free variables of the model does not match the number of equations');
      end

      % Index to match each equation to its corresponding free variable.
      eqnIndex = zeros(size(obj.variables));
      % Index to match each variable to its corresponding equations.
      varIndex = zeros(size(obj.variables));

      % First match equations with derivatives to the corresponding free
      % variable.
      for i = 1:length(obj.equations)
        ders = obj.equations(i).dersStr;

        if isempty(ders)
          continue;
        end

        for j = 1:length(obj.variables)
          if strcmp(ders,obj.variables(j).name)
            eqnIndex(i) = j;
            varIndex(j) = i;
          end
        end

      end

      % Now match substitution variables with the substitution equation.
      for i = 1:length(obj.equations)

        % Skip not subsitution equations.
        if ~obj.equations(i).isSubstitution
          continue;
        end

        for j = 1:length(obj.variables)
          if strcmp(obj.equations(i).varsStr(1),obj.variables(j).name)
            eqnIndex(i) = j;
            varIndex(j) = i;
          end
        end

      end

      % Then match the algebraic equation with the remaining freeVariables.
      knownVars = [obj.paramsName(:)' {obj.variables(eqnIndex(eqnIndex>0)).name}];

      remainingIndex_last = sum(eqnIndex==0);

      while true       
        % Exit the loop if all the indexes have been set.
        if remainingIndex_last == 0
          break
        end

        % Try to set more indexes.
        for i = 1:length(obj.equations)
          % If the equation has an index, skip it.
          if eqnIndex(i) > 0
            continue
          end

          % Check the number of free variables in the equantion.
          eqnVars = obj.equations(i).varsStr;
          eqnVars = eqnVars(~ismember(eqnVars,knownVars));

          % If there is only one free var.
          if length(eqnVars) == 1
            % We have a match!
            ind = find(ismember({obj.variables.name},eqnVars));
            eqnIndex(i) = ind;
            varIndex(ind) = i;
            % And add the var to known vars.
            knownVars(end+1) = eqnVars;
          end
        end

        % Calculate the index remaining to be set.
        remainingIndex = sum(eqnIndex==0);

        % If there wasn't an advance looking for indexes.
        if remainingIndex == remainingIndex_last
          % Throw an error.
          errorVars = [];
          for i = 1:length(eqnVars)
            errorVars = [errorVars '"' eqnVars{i} '" '];
          end
          error('The model is not well defined, plase check the definition and equations of the following Variables: %s',errorVars);
        end

        remainingIndex_last = remainingIndex;
      end

      out = varIndex;

    end % get.varIndex

    function [out] =  get.eqns(obj)
      %% GET.EQNS Get symbolic equations of the model.
      %
      % return: out Symbolic equations array.

      out = [obj.equations.eqnSym].';

      % Return reduced model if needed.
      if obj.isReduced
        out = out(~obj.isSubs);

        obj.isReduced = false;

        subsVars = (obj.vars(obj.isSubs)).';
        subsEqns = obj.eqnsRight(obj.isSubs);

        obj.isReduced = true;

        while any(ismember(symvar(out).', subsVars.', 'rows'))
          out = subs(out,subsVars,subsEqns);
        end
      end

    end % get.eqns

    function [out] = get.eqnsName(obj)
      %% GET.EQNSNAME Get the names of the equations.
      %
      % return: out Struct with the name of the equations.

      out = {obj.equations.name};

      % Return reduced model if needed.
      if obj.isReduced
        out = out(~obj.isSubs);
      end

    end % get.eqnsName


    function [out] =  get.eqnsLeft(obj)
      %% GET.EQNSLEFT Get left equal part of the equations of the model.
      %
      % return: out Simbolic left part of equations.

      out = [obj.equations.left];

      % Return reduced model if needed.
      if obj.isReduced
        out = out(~obj.isSubs);
      end

    end % get.eqnsLeft

    function [out] =  get.eqnsRight(obj)
      %% GET.EQNSRIGHT Get right equal part of the equations of the model.
      %
      % return: out Simbolic right part of equations.

      out = [obj.equations.right];

      % Return reduced model if needed.
      if obj.isReduced
        subsEqns = out(obj.isSubs);
        out = out(~obj.isSubs);

        obj.isReduced = false;

        subsVars = (obj.vars(obj.isSubs)).';

        obj.isReduced = true;

        if isempty(subsVars)
          return;
        end

        while any(ismember(symvar(out).', subsVars.', 'rows'))
          out = subs(out,subsVars,subsEqns);
        end
      end

    end % get.eqnsRight

    function [out] =  get.ders(obj)
      %% GET.DERS Get derivatives of variables of the model.
      %
      % return: out Symbolic derivatives.

      out = cellfun(@(x) sym(['d_' x]),...
        {obj.variables.name}...
        ,'Uni',false);
      out = [out{:}];

      % Return reduced model if needed.
      if obj.isReduced
        out = out(~obj.isSubs);
      end

    end % get.ders

    function [out] = get.isSubs(obj)
      %% GET.ISSUBS is the varible or equation just a substitution?
      %
      % return: out [bool] isSubs.

      out = [obj.equations.isSubstitution];

    end % get.isSubs


    function [out] =  get.params(obj)
      %% GET.PARAMS Get symbolic parameters of the model.
      %
      % return: out Symbolic parameters array.

      if isempty(obj.parameters)
        out = [];
      else
        out = [obj.parameters.nameSym];
      end

    end % get.params

    function [out] =  get.paramsName(obj)
      %% GET.PARASNAME  Get params name.
      %
      % return: out {[char]} Names of the params of the model.

      if isempty(obj.parameters)
        out = {''};
      else
        out = {obj.parameters.name}.';
      end

    end % get.paramsName

    function [out] = get.paramsValue(obj)
      %% GET.PARAMSVALUE Get the defautl value of the parameters of the model.
      %
      % return: out [Real] Array with the default values of the parameters.

      out = [obj.parameters.value];

    end % get.paramsValue

    function [out] = get.symbols(obj)
      %% GET.SYMBOLSNAME Get symbols of the model.
      %
      % return: out {SymbolClass} symbols.

      out = {};

      % TODO: this code will not work, isSubstitution is a equation propierty.
      for i = 1:length(obj.symbols)
        % Skip subsitution symbols if the model is reduced.
        if obj.symbols{i}.isSubstitution && obj.isReduced
          continue
        end

        out{end+1} = obj.symbols{i};
      end

    end

    function [out] =  get.symbolsName(obj)
      %% GET.SYMBOLSNAME Get symbols name.
      %
      % return: out {[char]} Names of the symbols of the model.

      out = {};

      symbols = obj.symbols;

      for i = 1:length(symbols)
        out{end+1} = symbols{i}.name;
      end

    end % get.varsName

    function [out] = get.symbolsIsPlot(obj)
      %% GET.SYMBOLSISPLOT Should the symbol be plot?
      %
      % return: out [bool] symbolsIsPlot.

      out = [];

      symbols = obj.symbols;

      for i = 1:length(symbols)
        out(end+1) = symbols{i}.isPlot;
      end

    end % get.symbolsIsPlot

  end % methods

  %% Utils
  methods
    function [f_exp] = symbolic2MatlabFunction(obj,exp,newHeader)
      % Convert a general symbrootLocusSweep(obj,p_ini,p_end,varargin)olic expression into a well formated
      % matlab function.

      % Convert symbolic ODE into a function.
      f = matlabFunction(exp);
      % Convert function into string.
      sf = func2str(f);

      % Get the name of all the symbols (variables and parameters).
      names = StrSymbolic.symvar(sf);

      % Add 'p.' to all symbols.
      ind = false(size(sf));
      for i = 1:length(names)
        aux = strfind(sf,names{i});
        for j = 1:length(aux)
          ind(aux(j):aux(j)+length(names{i})-1) = true;
        end
      end
      lastInd = false;
      for i = length(sf):-1:1
        % Add the p. to the string.
        if lastInd == true && ind(i) == false
          sf = insertAfter(sf,i,'p.');
        end
        lastInd = ind(i);
      end      

      % Remove the header.
      sf = extractAfter(sf,min(strfind(sf,')')));
      % Add the new header.
      sf = strcat('@(',newHeader,')',sf);

      % Replace the name of each var for x(i).
      for i = 1:length(obj.vars)
        expr = strcat('p\.',obj.varsName{i},'\>');
        [start,final]=regexp(sf,expr);
        start = flip(start);
        final = flip(final);
        for j = 1:size(start,2)
          sf = replaceBetween(sf,start(j),final(j),strcat('x(', num2str(i),',:)'));
        end
      end
      % Convert the final string into a func.
      f_exp = str2func(sf);

    end % symbolic2MatlabFunction

  end % methods

  methods (Static)
    function [out] = load(filename, varargin)
      %% LOAD Load a ModelClass model.
      %
      % param: filename Name of the model to load.
      %
      % return: out ModelClass object.

      % Options for the model (used typically with "if" commands").
      opts = getOption(varargin,'opts',[]);
      % Always compile the model.
      force_compile = getFlag(varargin,'force-compile');

      [folder, name, extension] = fileparts(filename);

      if ~strcmp(extension,'.mc')
        error('The file must have ''.mc'' extension.');
      end

      if ~isfile(filename)
        error(['The file "' filename '" does not exist.']);
      end
      
      compile = true;
      
      if isfile(['./build/' name '.m'])
        disp('Found a compilated model.'); 
        % Check if the model is up-to-date.
        compile = ~feval([name '.isUpToDate']);
      end

      if compile && ~force_compile
        % Just use the current version of the model.
        disp('Using preexisting compilated model.');
      else
        % Compile an up-to-date version.
        disp(['Compiling model...']);
        mp = ModelClassParser(filename);
        mp.parse();
        disp('Compilation finished.');
      end

      % Load the model.
      disp('Model is loading...');
      out = feval(name,opts);
      disp('Model is loaded.');

    end % load

    function [out] = version(~)
      %% VERSION Prints the version of the ModelClass software.
      %
      % return: void

      [filepath, name, ext]  = fileparts(which('ModelClass.m'));

      % Get the version from the version file.
      pathVersion = [filepath '/version'];
      fid = fopen(pathVersion);
      versionNumber = fgetl(fid);
      fclose(fid);

      % Get the commit number if .git is present.
      commit = '';
      pathHead = [filepath '/.git/HEAD'];
      if isfile(pathHead)
        % File exists.
        fid = fopen(pathHead);
        head = fgetl(fid);
        fclose(fid);

        % Check if the head is a reference or no.
        if strcmp(head(1:5),'ref: ')
          % It is a reference.
          pathRef = [filepath '/.git/' head(6:end)];
          fid = fopen(pathRef);
          commit = fgetl(fid);
        else
          % It is the commit hash.
          commit = head;
        end

        commit = [' ' commit(1:7)];
      end

      out = ([versionNumber commit '   -   Fernando Nóbel (fersann1@upv.es)']);

    end % version

    function [isOutdated] = checkVersion(~)
      %% CHECKVERSION Check if the local version of ModelClass is outdated.
      %
      % return: isOutdated bool True if the local version is outdated.

      % Get the local version.
      [filepath, name, ext]  = fileparts(which('ModelClass.m'));
      pathVersion = [filepath '/version'];
      fid = fopen(pathVersion);
      versionLocal = fgetl(fid);
      fclose(fid);
      versionLocal = regexp(versionLocal,'v(\d*).(\d*).(\d*)','tokens');
      versionLocal = versionLocal{1};

      % Get the latest version.
      versionLatest = webread('https://raw.githubusercontent.com/FernandoNobel/ModelClass/master/version');
      versionLatest = regexp(versionLatest,'v(\d*).(\d*).(\d*)','tokens');
      versionLatest = versionLatest{1};

      % Compare the latest and local  versions.

      isOutdated = false;

      if str2num(versionLatest{1}) > str2num(versionLocal{1})
        isOutdated = true;
      elseif str2num(versionLatest{2}) > str2num(versionLocal{2})
        isOutdated = true;
      elseif str2num(versionLatest{3}) > str2num(versionLocal{3})
        isOutdated = true;
      end

      if isOutdated
        warning('The local version of ModelClass is outdated, please update to the latest version.');
      else
        disp('The local version of ModelClass is up to date.');
      end

    end % checkVersion

    function [] = update(~)
      %% UPDATE Update the ModelClass code to the latest in the main repository.
      %
      % return: void

      % Get the initial path.
      pathInitial = pwd();

      % Get the absoulute path.
      [path, name, ext]  = fileparts(which('ModelClass.m'));

      cd(path);
      cd('..');

      % Download the latest version of the code.
      disp('Downloading the latest version of ModelClass...');
      websave('./latest.zip','https://github.com/FernandoNobel/ModelClass/archive/master.zip');
      disp('Download end.');

      % Move the .git if it exists.
      if exist([path '/.git'], 'dir')
        disp('Founded .git folder.');
        disp('Saved the .git folder.');
        movefile([path '/.git'],'./git-tmp');
      end

      % Remove the old code.
      disp('Remove old files.');
      warning('off');
      rmdir(path,'s'); % This generates a warnig and messes up with the path.
      warning('on');

      % Unzip the code.
      disp('Unzip the code...');
      unzip('./latest.zip','.');
      disp('Unzip end');

      % Move to that location the lastest code.
      disp('Move the lastest files.');
      try
        movefile('./ModelClass-master',path);
      catch
      end

      % Restore the path for this session.
      addpath(path);
      addpath([path '/utils']);

      % Move back the .git folder if it exists.
      if exist('./git-tmp', 'dir')
        disp('Move back the .git folder.');
        movefile('./git-tmp',[path '/.git']);
      end

      % Clean-up.
      disp('Clean installation files.');
      delete('latest.zip');

      % Come back to the initial path.
      cd(pathInitial);

      disp('');
      disp('ModelClass has been successfully updated!');

    end % update

    function [out] = checkUpToDate(dependenciesPath)
      %% CHECKUPTODATE Check if the model is up-to-date.
      %
      % param: obj
      %
      % return: out True if model if up-to-date.

      out = true;

      [folder, name, extension] = fileparts(dependenciesPath{1});

      modelPath = ['./build/' name '.m'];
      modelDate = dir(modelPath).datenum;

      for i = 1:length(dependenciesPath)
        if  modelDate < dir(dependenciesPath{i}).datenum
          out = false;
          disp('Model is out-dated.');
          return
        end
      end

      disp('Model is up-to-date.');

    end % checkUpToDate

  end % methods

end % classdef
