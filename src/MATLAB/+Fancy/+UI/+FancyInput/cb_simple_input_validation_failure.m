function [] = cb_simple_input_validation_failure(inputNames, rawInputValues, convertedValues, hasError, errors, cb_error_messages)
    if nargin < 6
        import Fancy.UI.FancyInput.cb_error_messages;
		cb_error_messages = @cb_error_messages;
    end
    errorMessages = cellfun(@(me) me.message, errors(hasError), 'UniformOutput', false);
    cb_error_messages(errorMessages);
    h = warndlg('Some inputs were not valid so you will be prompted again. Check commandline for details.', 'Invalid inputs');		
    waitfor(h);
end