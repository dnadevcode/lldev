function [shouldMergeDuplicates] = prompt_should_merge_duplicates()
    choice = menu('How should different theories (defined by name) with identical sequences be handled?', 'They should be left alone', 'They should be merged such that there are no duplicates (Recommended)');
    shouldMergeDuplicates = false;
    if choice == 2
        shouldMergeDuplicates = true;
    end
end