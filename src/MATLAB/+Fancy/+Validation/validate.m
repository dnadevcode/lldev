function [isValid, reasonInvalid] = validate(value, attributes, classes)
    % validate - generates a validator and validates in one
    %   function
    %  (for when you don't want to reuse the validator and just
    %    want an easy to call function)
    %  see comments in generate_validator for details
	import Fancy.Validation.generate_validator;
    validator = generate_validator(attributes, classes);
    [isValid, reasonInvalid] = validator(value);
end