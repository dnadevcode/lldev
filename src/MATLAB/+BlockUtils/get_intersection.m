function [intersection] = get_intersection(aValues, bValues)
	import BlockUtils.diff_unique_sorted_vectors;
	
    [~, ~, intersection, ~] = diff_unique_sorted_vectors(aValues, bValues);
end