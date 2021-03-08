function [out] = getOption(options,optionName,defaultValue)

ind = [];

for i = 1:length(options)
    if ~ischar(options{i})
        continue
    end
    
    if strcmp(options{i},optionName)
        ind = i;
    end    
end

if isempty(ind)
    % Default value.
    out = defaultValue;
else
    % User provided value.
    out = options{ind+1};
end

end

