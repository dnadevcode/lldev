function [complement] = get_complement(potentialValues, values)
	import BlockUtils.diff_unique_sorted_vectors;
	
    [complement, ~, ~, ~] = diff_unique_sorted_vectors(potentialValues, values);
end