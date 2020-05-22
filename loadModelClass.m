function [out] = loadModelClass(name)
  %% LOADMODELCLASS Load a ModelClass model.
  %
  % param: name Name of the model to load.
  %
  % return: out ModelClass object.
  
  mp = ModelClassParser([name '.mc']);
  mp.parse();

  out = feval(name);

  
end % loadModelClass
