function [isValid, reasonInvalid] = class_validator(value, classes)
    % class_validator - validates a value as belonging to at least
    %    one of the classes provided (OR logic) unless no classes
    %    are provided in which case the value is always considered
    %    valid
    %  see comments in generate_validator for details
    %  note this can also be implemented with "or"+"isa" logic
    %    using attributes (so this is just provided for convenience
    %    and more consistency with validateattributes)
    if not(iscell(classes)) && ischar(classes)
        classes = {classes};
    end
    isValid = false;
    numClasses = length(classes);
    if numClasses > 0
        classes = classes(:);
        classMatchFound = false;
        for classNum=1:numClasses
            if isa(value, classes{classNum})
                classMatchFound = true;
                break;
            end
        end
        if not(classMatchFound)
            classesStr = strjoin([{''}; classes; {''}], ''', ''');
            classesStr = classesStr(4:end - 3);
            reasonInvalid = ['it does not belong to any of these valid classes: ', classesStr];
            return;
        end
    end
    isValid = true;
    reasonInvalid = '';
end