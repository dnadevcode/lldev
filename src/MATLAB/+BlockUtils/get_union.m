function [union] = get_union(aValues, bValues)
	import BlockUtils.diff_unique_sorted_vectors;
	
    [~, ~, ~, union] = diff_unique_sorted_vectors(aValues, bValues);
end