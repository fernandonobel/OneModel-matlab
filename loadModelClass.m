function [out] = loadModelClass(name)
  %% LOADMODELCLASS Load a ModelClass model.
  %
  % param: name Name of the model to load.
  %
  % return: out ModelClass object.

  warning('This function will be removed in future versions of ModelClass, please use ''ModelClass.load'' instead.');
  
  mp = ModelClassParser([name '.mc']);
  mp.parse();

  out = feval(name);

end % loadModelClass
