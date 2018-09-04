function randomReorderings = generate_random_reorderings(seqLen, numRandomReorderings)
    randomReorderings = cell(numRandomReorderings, 1);
    for permNum=1:numRandomReorderings
        [~, perm] = sort(rand(seqLen, 1));
        randomReorderings(permNum) = perm;
    end
end