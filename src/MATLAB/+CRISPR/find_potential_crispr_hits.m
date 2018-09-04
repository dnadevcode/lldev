function [potentialCutAreaStartIdxs, potentialCutAreaDNASeqs] = find_potential_crispr_hits(dnaSeq_5to3, crRnaSeq_5to3, isCircularDNA, maxGuaranteedMismatchesInHits)
    % FIND_POTENTIAL_CRISPR_HITS - finds the start positions in the DNA
    %  sequence of area where one could expect cuts from Cas9 designed to
    %  have a specifed CRISPR-RNA (crRNA) sequence
    %
    % Inputs:
    %  dnaSeq_5to3
    %   the DNA sequence either using Matlab's version of IUPAC codes 
    %   or Matlab's version of uint8 integer codes for the nucleotide
    %   labels
    %  crRnaSeq_5to3
    %   the RNA sequence either using Matlab's version of IUPAC codes 
    %   or Matlab's version of uint8 integer codes for the nucleotide
    %   labels
    %  isCircularDNA
    %    true if the dna sequence should be treated as if it is circular
    %    (e.g. a plasmid DNA that wraps around)
    %  maxGuaranteedMismatchesInHits
    %    how many definite mismatches in nucleotide labels need to be
    %    present relative to the crRNA to exclude a particular subsequence
    %    of DNA from being considered a potential hit for Cas9
    %
    % Outputs:
    %   potentialCutAreaStartIdxs
    %     the start indices for areas of length where potential matches along the DNA
    %     where a potential c
    %   potentialCutAreaDNASeqs
    %
    % Authors:
    %   Saair Quaderi
    import NtSeq.Core.get_bitsmart_ACGT;
    
    if ischar(crRnaSeq_5to3)
        crRnaSeq_5to3 = nt2int(crRnaSeq_5to3);
    end
    needleLen = numel(crRnaSeq_5to3);
    if ((needleLen < 18) || (needleLen > 28)) % 15-25bp gRNA + 3bp PAM sequence
        warning('The CRISPR-RNA sequence (including the PAM) was not between 18-28 nucleotides long)')
    end
   
    
    % note: below line is equivalent to dnaSeqNeedleA = crRnaSeq_5to3
    % since they are in Matlabs uint8 format wherein U for RNA is encoded
    %  as 3 just like T for DNA
    dnaSeqNeedleB = rna2dna(crRnaSeq_5to3); % for hits where crRNA binds to the other strand opposite this 5-3 DNA sequence
    
    dnaSeqNeedleA = seqrcomplement(dnaSeqNeedleB); % for hits where crRNA binds onto the strand with this 5-3 DNA sequence
    
    
    
    dnaSeqHaystack_bitsmart = get_bitsmart_ACGT(dnaSeq_5to3);
    dnaSeqNeedleA_bitsmart = get_bitsmart_ACGT(dnaSeqNeedleA);
    dnaSeqNeedleB_bitsmart = get_bitsmart_ACGT(dnaSeqNeedleB);
    if any(dnaSeqHaystack_bitsmart(:) > uint8(15)) || any(dnaSeqNeedleA_bitsmart(:) > uint8(15)) % uint8(15) = CBT.Core.get_bitsmart_ACGT('N')
        error('Sequences must be gap-free and encode only recognized characters (''-'' AND ''*'' are not permitted.)');
    end
    
    if numel(dnaSeqHaystack_bitsmart) < needleLen
        error('The sequence being searched has fewer basepairs than the complementary RNA sequence');
    end

    dnaSeqLenOriginal = numel(dnaSeqHaystack_bitsmart);
    if isCircularDNA
        dnaSeqHaystack_bitsmart = [dnaSeqHaystack_bitsmart, dnaSeqHaystack_bitsmart(1:(needleLen - 1))];
    end
    dnaSeqLenExtended = numel(dnaSeqHaystack_bitsmart);
    
    if (maxGuaranteedMismatchesInHits >= needleLen)
        error('Number of allowed mismatches must be fewer than there are basepairs in the CRISPR-RNA sequence');
    end
    
    % numBpMatchesNeedleA = sum(rem(floor(double(dnaSeqNeedleA_bitsmart(:))*pow2(1 - 4:0)),2), 2);
    % numBpMatchesNeedleB = sum(rem(floor(double(dnaSeqNeedleB_bitsmart(:))*pow2(1 - 4:0)),2), 2);
    % numBpMatchesHaystack = sum(rem(floor(double(dnaSeqHaystack_bitsmart(:))*pow2(1 - 4:0)),2), 2);
    
    % ambiguousBpsNeedleA = numBpMatchesNeedleA > 1;
    % ambiguousBpsNeedleB = numBpMatchesNeedleB > 1;
    % ambiguousBpsHaystack = numBpMatchesHaystack > 1;
    
    numPartialHaystacks = 1 + dnaSeqLenExtended - needleLen;
    guaranteedMismatchCountsA = zeros(numPartialHaystacks, 1);
    guaranteedMismatchCountsB = zeros(numPartialHaystacks, 1);
    % potentialMismatchCountsA = zeros(numPartialHaystacks, 1);
    % potentialMismatchCountsB = zeros(numPartialHaystacks, 1);
    for startIdx=1:numPartialHaystacks
        partialHaystackIdxs = startIdx - 1 + (1:needleLen);
        
        seqPartialHaystack_bitsmart = dnaSeqHaystack_bitsmart(partialHaystackIdxs);
        % ambiguousBpsHaystackPartial = ambiguousBpsHaystack(partialHaystackIdxs);
        
        seqIntersectionA_bitsmart = bitand(seqPartialHaystack_bitsmart, dnaSeqNeedleA_bitsmart);
        seqIntersectionB_bitsmart = bitand(seqPartialHaystack_bitsmart, dnaSeqNeedleB_bitsmart);
        
        numBpMatchesIntersectionA = sum(rem(floor(double(seqIntersectionA_bitsmart(:))*pow2(1 - 4:0)),2), 2);
        numBpMatchesIntersectionB = sum(rem(floor(double(seqIntersectionB_bitsmart(:))*pow2(1 - 4:0)),2), 2);
        
        guaranteedMismatchesA = (numBpMatchesIntersectionA == 0);
        guaranteedMismatchesB = (numBpMatchesIntersectionB == 0);
        
        guaranteedMismatchCountA = sum(guaranteedMismatchesA);
        guaranteedMismatchCountB = sum(guaranteedMismatchesB);
        
        % potentialMismatchCountA = sum(potentialMismatchesA);
        % potentialMismatchCountB = sum(potentialMismatchesB);

        % potentialMismatchesA = guaranteedMismatchesA | ambiguousBpsNeedleA | ambiguousBpsHaystackPartial;
        % potentialMismatchesB = guaranteedMismatchesB | ambiguousBpsNeedleB | ambiguousBpsHaystackPartial;
        
        guaranteedMismatchCountsA(startIdx) = guaranteedMismatchCountA;
        guaranteedMismatchCountsB(startIdx) = guaranteedMismatchCountB;
        
        % potentialMismatchCountsA(startIdx) = potentialMismatchCountA;
        % potentialMismatchCountsB(startIdx) = potentialMismatchCountB;
    end
    
    potentialEffectiveMatchStartsA = (guaranteedMismatchCountsA <= maxGuaranteedMismatchesInHits);
    potentialEffectiveMatchStartsB = (guaranteedMismatchCountsB <= maxGuaranteedMismatchesInHits);
    
    potentialCutAreaStartIdxsA = find(potentialEffectiveMatchStartsA(:));
    potentialCutAreaStartIdxsB = find(potentialEffectiveMatchStartsB(:));
    
    
    adjToCutSiteA = false(1, needleLen);
    % cleavage site would be between bps 3-4 bp upstream from the 3 bp PAM sequence
    adjToCutSiteA(3 + [3, 4]) = true;
    adjToCutSiteB = fliplr(adjToCutSiteA);
    
    potentialCutAdjIdxsA = mod(bsxfun(@plus, potentialCutAreaStartIdxsA(:) - 1, find(adjToCutSiteA) - 1), dnaSeqLenOriginal) + 1;
    potentialCutAdjIdxsB = mod(bsxfun(@plus, potentialCutAreaStartIdxsB(:) - 1, find(adjToCutSiteB) - 1), dnaSeqLenOriginal) + 1;

    potentialCutAreaDNASeqsA = arrayfun(@(startIdx) dnaSeq_5to3(mod((startIdx - 1) + (1:length(crRnaSeq_5to3)) - 1, dnaSeqLenOriginal) + 1), potentialCutAreaStartIdxsA, 'UniformOutput', false);
    potentialCutAreaDNASeqsB = arrayfun(@(startIdx) dnaSeq_5to3(mod((startIdx - 1) + (1:length(crRnaSeq_5to3)) - 1, dnaSeqLenOriginal) + 1), potentialCutAreaStartIdxsB, 'UniformOutput', false);
    
    potentialCutAreaStartIdxs = unique([potentialCutAreaStartIdxsA; potentialCutAreaStartIdxsB]);
    potentialCutAreaDNASeqs = arrayfun(@(startIdx) dnaSeq_5to3(mod((startIdx - 1) + (1:length(crRnaSeq_5to3)) - 1, dnaSeqLenOriginal) + 1), potentialCutAreaStartIdxs, 'UniformOutput', false);
        
end