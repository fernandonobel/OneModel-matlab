function [out] = getFlag(options,flagName)

out = false;
for i = 1:length(options)
    if ~ischar(options{i})
        continue
    end
    
    if strcmp(options{i},flagName)
        out = true;
    end    
end

end

