function [diff] = get_diff(aValues, bValues)
	import BlockUtils.diff_unique_sorted_vectors;
	
    [diff, ~, ~, ~] = diff_unique_sorted_vectors(aValues, bValues);
end