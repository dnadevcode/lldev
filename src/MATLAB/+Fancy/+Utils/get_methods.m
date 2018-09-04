function [classMethodsStruct] = get_methods(className, methodNames)
    % GET_METHODS - Returns a struct containing fields which point to
    %   references to the methods the fieldnames are associated with for
    %   the class
    %
    % Inputs:
    %  className
    %     the name of a class
    %  methodNames (optional)
    %     cell array of method names for methods to include from the class
    %     (if not provided, all methods for the class are retrieved)
    %
    % Outputs:
    %   classMethodsStruct
    %     a struct with fields pointing to methods for the class
    %
    % Authors:
    %   Saair Quaderi
    
    if nargin < 2
        methodNames =  methods(className)';
    else
        methodNames = intersect(methodNames(:)', methods(className)');
    end
    classMethodsStruct = struct;
    for methodNameCell = methodNames
        methodName = methodNameCell{1};
        classMethodsStruct.(methodName) = str2func([className '.', methodName]);
    end
end