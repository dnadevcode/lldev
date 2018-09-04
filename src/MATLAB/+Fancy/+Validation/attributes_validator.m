function [isValid, reasonInvalid] = attributes_validator(value, attributes)
    % attributes_validator - validates a value with a set of
    %   attributes using AND logic
    %  see comments in generate_validator for details
	import Fancy.Validation.attribute_validator;
	
    if not(iscell(attributes)) && ischar(attributes)
        attributes = {attributes};
    end
    numAttributes = length(attributes);
    for attributeNum=1:numAttributes
        attribute = attributes{attributeNum};
        if isempty(attribute)
            continue;
        end
        [attributeValidated, reasonInvalid] = attribute_validator(value, attribute);
        if not(attributeValidated)
            isValid = false;
            return;
        end
    end
    isValid = true;
    reasonInvalid = '';
end