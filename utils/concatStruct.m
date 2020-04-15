function [a] = concatStruct(a, b) 
	fields = fieldnames(b);

	for i = 1:numel(fields)
% 		a.(fields{i})(end+1) = b.(fields{i});
        a.(fields{i}) = [a.(fields{i}); b.(fields{i})];
	end
end
