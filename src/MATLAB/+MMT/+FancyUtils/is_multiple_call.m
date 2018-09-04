function tfIsMultipleCall = is_multiple_call()
    % http://undocumentedmatlab.com/blog/controlling-callback-re-entrancy
    s = dbstack();
    tfIsMultipleCall = (numel(s) > 1) && (sum(strcmp(s(2).name, {s(:).name})) > 1);
end