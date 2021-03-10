variable x(start = 0);
parameter k(value = 1);

equation der_x == k - x;

% Imagine that we want to perform a ModelClass definition or operation
% that is not currently supported by the syntax.

% We can used the MatlaCode syntax to inject low level matlab code into our
% model definition.
matlabCode
p = obj.getSymbolByName('k');
p.value = 5;
end;