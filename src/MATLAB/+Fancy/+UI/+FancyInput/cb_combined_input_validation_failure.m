function [] = cb_combined_input_validation_failure(inputNames, rawInputValues, convertedValues, hasError, errors, fn_cb_error_messages)	
    % CB_COMBINED_INPUT_VALIDATION_FAILURE - failure callback when there is
    %   an error with validating a combination of incompatible inputs
    %
    % Inputs:
    %   inputNames (currently ignored)
    %     the names of the inputs
    %   rawInputValues (currently ignored)
    %     the unconverted raw string input values provided for validation
    %   convertedValues (currently ignored)
    %     the converted values for inputs
    %   hasError
    %     a logical vector with true for cases where there actually was an
    %     error
    %    errors
    %      a cell array of error objects with message fields for error
    %      messages when hasError is true
    %    fn_cb_error_messages (optional...
    %      defaults to Fancy.UI.FancyInput.cb_error_messages)
    %      the callback function to call will the list of error messages
    %       that were created
    %
    % Side-effects:
    %    Whatever side-effects occur from calling fn_cb_error_messages 
    %    with the list of error messages
    %
    % Authors:
    %   Saair Quaderi
    
    if nargin < 6
        import Fancy.UI.FancyInput.cb_error_messages;
		fn_cb_error_messages = @cb_error_messages;
    end
    errorMessages = cellfun(@(me) me.message, errors(hasError), 'UniformOutput', false);
    fn_cb_error_messages(errorMessages);
    h = warndlg('Some inputs combinations were not valid so you will be prompted again. Check commandline for details.', 'Invalid inputs');		
    waitfor(h);
end