function validator = generate_validator(attributes, classes)
    % generate_validator -
    %  uses the classes and attributes inputs as specifications
    %   to generate a function that will take a single value in as
    %    an argument and return two outputs
    %   (isValid and reasonInvalid)
    %  if the value meets the specifications for a valid value,
    %   isValid will be true and reasonValid will be empty
    %  if the value does not meet the specifications,
    %   isValid will be false and reasonValid will be a string
    %   containing a human-readable reason for why the
    %   the value was considered invalid
    %
    % Disclaimer: if attributes contains unexpected values when
    %   generating the validator, running the validator may result
    %   in an error being thrown so provide attributes
    %   carefully!
    %
    % This function includes a lot of validation options.
    %  To explore all the options, it might be best to just
    %  look through the code below. All the validation options
    %  from matlab's validateattributes are available here
    %  as well but with some minor differences in how they should
    %  be entered. Those options are documented here:
    % http://mathworks.com/help/matlab/ref/validateattributes.html
    %  The main differences are as follows:
    %
    %  Like validateattributes, this validator generator takes 
    %     in a cell array of values specifying valid attributes.
    %     [2] However, unlike validateattributes, individual
    %     attributes can be placed in their individual nested cell
    %     array instead of being specified directly in the
    %     attributes cell array as a string. For attributes which
    %     are specified by a single string, they can be placed
    %     directly in the attributes cell array, but for attributes
    %     which contain multiple components, they must be
    %     grouped into their own cell array
    %
    % e.g. for validateattributes, attributes can be defined like
    %   this:
    %      attributes = {'scalar', '>', 0, '<', 100}
    %    whereas for this function, that would fail.
    %    instead they must be specified as either
    %      attributes = {'scalar', {'>', 0}, {'<', 100}}
    %    or
    %      attributes = {{'scalar'}, {'>', 0}, {'<', 100}}
    %
    %
    %   Additionally, this validator supports an "isa" attribute
    %    which takes a string as the second component of the
    %    attribute to check if it fits a specific class and an
    %    "or" attribute which requires multiple other components
    %    which are subsets of attributes themselves and validates the
    %    value for this attribute if it passes any of the subsets.
    %    this can be used for complex logic.
    % e.g. validate if it's a character or an even integer greater
    %   than ten or an odd integer less than 10:
    %  attributes = {{'or',...
    %    {{'isa', 'char'}},...
    %    {'even', {'>', 10}},...
    %    {'odd', {'<', 10}}...
    %   }}
    %
    %  Like validateattributes, this validator generator can take 
    %     in a cell array of strings specifying valid classes.
    %     For both validateattributes and the validator here.
    %     If the value does not belong to any of the classes
    %     specified the value will not be validated for either.
    %     [1] However if the set of classes provided is empty,
    %     this validator will assume that values all classes
    %     are valid whereas validateattributes will always say
    %     that the value is invalid.
    if nargin < 2
        classes = {};
    end

    function [isValid, reasonInvalid] = validator_fn(value)
	    import Fancy.Validation.class_validator;
	    import Fancy.Validation.attributes_validator;
	
        [classValidated, reasonInvalid] = class_validator(value, classes);
        if not(classValidated)
            isValid = false;
            return;
        end

        [isValid, reasonInvalid] = attributes_validator(value, attributes);
    end
    validator = @validator_fn;
end
