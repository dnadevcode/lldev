classdef SortedCollectionManager < handle
    % SORTEDCOLLECTIONMANAGER - Manages a collection such that it is sorted
    %  using an associated score which is a finite, real, double
    %
    % Authors:
    %  Saair Quaderi (SQ)
    
    properties (GetAccess = protected, SetAccess = protected)
        FnEntryValueHasher
        EntryScoreTreeSet
        EntryHashToEntryValueMap
        ScoreHashToEntryHashesMap
        EntryHashToScoreMap
    end
    
    methods(Access = public)
        function [sscm] = SortedCollectionManager(fn_entry_value_hasher)
            % SORTEDCOLLECTIONMANAGER (constructor)
            %   Constructs a SortedCollectionManager
            %
            % Inputs:
            %   fn_entry_value_hasher
            %     a hashing function that converts an entry value to a
            %      string hash value
            %
            % Outputs:
            %   A new SortedCollectionManager object

            import java.util.TreeSet;
            import Fancy.Utils.data_hash;
            
            if nargin < 1
                warning('A hashing function was not provided. Defaulting to DataHash');
                fn_entry_value_hasher = @data_hash;
            end
            validateattributes(fn_entry_value_hasher, {'function_handle'}, {'scalar'});
            
            sscm.FnEntryValueHasher = fn_entry_value_hasher;

            sscm.EntryScoreTreeSet = java.util.TreeSet;
            sscm.EntryHashToEntryValueMap = containers.Map();

            sscm.EntryHashToScoreMap = containers.Map();
            sscm.ScoreHashToEntryHashesMap = containers.Map();
        end
        
        function [entryValueExists, entryValueHash] = has_entry(sscm, entryValue)
            % HAS_ENTRY - Returns whether the entry value provided is
            %   present in the collection managed by the
            %   SortedCollectionManager
            %
            % Inputs:
            %    sscm
            %     the SortedCollectionManager object
            %    entryValue
            %     the entry value
            %
            %  Outputs:
            %    entryValueExists
            %      true if an entry within the collection managed by the
            %       SortedCollectionManager is associated with the same
            %       hash as the entry value provided
            %    entryValueHash
            %      the hash of the entry value provided
            entryValueHash = sscm.get_entry_hash(entryValue);
            entryValueExists = sscm.EntryHashToEntryValueMap.isKey(entryValueHash);
        end

        function [entryValuesExists, entryValueHashes] = has_entries(sscm, entryValues)
            % HAS_ENTRIES - Returns whether the entry values provided are
            %   present in the collection managed by the
            %   SortedCollectionManager
            %
            % Inputs:
            %    sscm
            %     the SortedCollectionManager object
            %    entryValues
            %     cell array of entry values
            %
            %  Outputs:
            %    entryValuesExists
            %      logical vector with true for entry values whose hashes
            %        are found in the hashes of the values present within
            %        the collection managed by the SortedCollectionManager
            %    entryValueHashes
            %      cell array of the hashes of the entry values provided
            validateattributes(entryValues, {'cell'}, {'vector'});
            numEntries = numel(entryValues);
            entryValueHashes = cell(numEntries, 1);
            entryValuesExists = false(numEntries, 1);
            for entryNum=1:numEntries
                [entryValuesExists(entryNum), entryValueHashes{entryNum}] = sscm.has_entry(entryValues{entryNum});
            end
        end
        
        function [] = add_entry_with_score(sscm, entryValue, entryScore)
            % ADD_ENTRY_WITH_SCORE - Adds an entry value and its associated
            %   score
            %
            % Inputs:
            %    sscm
            %     the SortedCollectionManager object
            %    entryValue
            %     the entry value to add
            %    entryScore
            %     the finite, real, double entry value score on which the
            %       collection will be sorted
            
            validateattributes(entryScore, {'double'}, {'nonnan', 'real', 'finite', 'scalar'});
            entryValueHash = sscm.get_entry_hash(entryValue);
            [entryExists] = sscm.has_entry_with_hash(entryValueHash);
            if entryExists
                entryScorePrev = sscm.get_entry_score(entryValue);
                if (entryScorePrev ~= entryScore)
                    warning('Entry was already present with a different score which has not been overwritten. Remove entry and add again if you wish to update the value.');
                end
            else
                sscm.EntryHashToEntryValueMap(entryValueHash) = entryValue;
                sscm.EntryHashToScoreMap(entryValueHash) = entryScore;
                [entryScoreExists] = sscm.has_entry_score(entryScore);
                entryScoreHash = sscm.get_entry_hash(entryScore);
                if not(entryScoreExists)
                    sscm.EntryScoreTreeSet.add(entryScore);
                    sscm.ScoreHashToEntryHashesMap(entryScoreHash) = {entryValueHash};
                else
                    scoreEntryValueHashes = sscm.ScoreHashToEntryHashesMap(entryScoreHash);
                    sscm.ScoreHashToEntryHashesMap(entryScoreHash) = [scoreEntryValueHashes; {entryValueHash}];
                end
            end
        end

        function [] = add_entries_with_scores(sscm, entryValues, entryScores)
            % ADD_ENTRIES_WITH_SCORES - Adds entry values and their
            %   associated scores
            %
            % Inputs:
            %    sscm
            %     the SortedCollectionManager object
            %    entryValues
            %     cell array of the entry values to add
            %    entryScore
            %     array or cell array of finite, real, double entry value
            %       scores on which the collection will be sorted (must
            %       contain the same number of scores as entry values)
            validateattributes(entryValues, {'cell'}, {'vector'});
            numEntries = numel(entryValues);
            numEntryScores = numel(entryScores);
            if numEntries ~= numEntryScores
                error('There must be the same number of entry values as entry scores');
            end
            if not(iscell(entryScores))
                validateattributes(entryScores, {'double'}, {'nonnan', 'real', 'finite', 'vector'});
                entryScores = num2cell(entryScores(:));
            end
            cellfun(@sscm.add_entry_with_score, entryValues, entryScores);
        end

        function [entryScore] = get_entry_score(sscm, entryValue)
            % GET_ENTRY_SCORE - Returns the entry score associated with
            %   the entry value provided, if the entry value's hash is
            %   present as a hash of an entry value in the collection 
            %   managed by the SortedCollectionManager (and NaN if it is
            %   not present)
            %
            % Inputs:
            %    sscm
            %     the SortedCollectionManager object
            %    entryValue
            %     the entry value
            %
            % Outputs:
            %    entryScore
            %     the score for the entry value (or NaN if unknown)
            entryScore = NaN;
            entryValueHash = sscm.get_entry_hash(entryValue);
            if sscm.EntryHashToScoreMap.isKey(entryValueHash)
                entryScore = sscm.EntryHashToScoreMap(entryValueHash);
            end
        end

        function [entryScores] = get_entry_scores(sscm, entryValues)
            % GET_ENTRY_SCORES - Returns the entry scores associated with
            %   the entry values provided, if the entry value's hash is
            %   present as a hash of an entry value in the collection 
            %   managed by the SortedCollectionManager (and NaN if it is
            %   not present)
            %
            % Inputs:
            %    sscm
            %     the SortedCollectionManager object
            %    entryValues
            %     cell array of the entry values
            %
            % Outputs:
            %    entryScores
            %     array of scores for the entry values
            %     (with NaNs when score is unknown)
            entryScores = cellfun(@sscm.get_entry_score, entryValues);
        end
        
        function [entryValues] = get_entry_values_for_score(sscm, entryScore)
            % GET_ENTRY_VALUES_FOR_SCORE - returns the entry values
            %  within the collection managed by the SortedCollectionManager
            %  which are associated with the provided entry score value
            %
            %  Inputs:
            %    sscm
            %     the SortedCollectionManager object
            %    entryScore
            %     the score for some entry value
            %
            %  Outputs:
            %    entryValues
            %      cell array of entry values within the collection managed
            %       by the SortedCollectionManager that are associated with
            %       the provided entry score
            validateattributes(entryScore, {'double'}, {'nonnan', 'real', 'finite', 'scalar'});
            entryScoreHash = sscm.get_entry_hash(entryScore);
            entryValues = cell(0,1);
            entryScoreExists = sscm.ScoreHashToEntryHashesMap.isKey(entryScoreHash);
            if entryScoreExists
                scoreEntryValueHashes = sscm.ScoreHashToEntryHashesMap(entryScoreHash);
                entryValues = cellfun(@(hash) sscm.EntryHashToEntryValueMap(hash), scoreEntryValueHashes, 'UniformOutput', false);
            end
        end

        function [] = remove_entry(sscm, entryValue)
            % REMOVE_ENTRY - Removes an entry value (and its associated
            %   score if it is the only entry with that score)
            %
            % Inputs:
            %    sscm
            %     the SortedCollectionManager object
            %    entryValue
            %     the entry value to remove
        
            entryValueHash = sscm.get_entry_hash(entryValue);
            [entryExists] = sscm.has_entry_with_hash(entryValueHash);
            if entryExists
                entryScore = sscm.get_entry_score(entryValue);
                entryScoreHash = sscm.get_entry_hash(entryScore);
                entryHashesForScore = sscm.ScoreHashToEntryHashesMap(entryScoreHash);
                entryHashesForScore = setdiff(entryHashesForScore, {entryValueHash});
                sscm.EntryHashToEntryValueMap.remove(entryValueHash);
                sscm.EntryHashToScoreMap.remove(entryValueHash);
                if isempty(entryHashesForScore)
                    sscm.EntryScoreTreeSet.remove(entryScore);
                    sscm.ScoreHashToEntryHashesMap.remove(entryScoreHash);
                else
                    sscm.ScoreHashToEntryHashesMap(entryScoreHash) = entryHashesForScore;
                end
            else
                warning('Entry was not removed since it was not present');
            end
        end

        function [] = remove_entries(sscm, entryValues)
            % REMOVE_ENTRIES - Removes entry values (and their associated
            %   scores if they no longer have an existing entry)
            %
            % Inputs:
            %    sscm
            %     the SortedCollectionManager object
            %    entryValues
            %     cell array of the entry values to remove
            validateattributes(entryValues, {'cell'}, {'vector'});
            cellfun(@(entryValue) sscm.remove_entry(entryValue), entryValues);
        end
        
        function [entryValues, entryValueScores] = get_score_sorted_entries(sscm)
            % GET_SCORE_SORTED_ENTRIES - Returns all the entry values
            %  sorted by their scores
            %
            % Inputs:
            %    sscm
            %     the SortedCollectionManager object
            %
            %  Outputs:
            %    entryValues
            %      cell array of all entry values within the collection
            %       managed by the SortedCollectionManager
            %    entryValueScores
            %      array of all scores associated with the entry values 
            %      outputed
            entryScores = sscm.java_Object_arr_2_double_arr(sscm.EntryScoreTreeSet.toArray());
            entryScores = entryScores(:);
            entryValues = arrayfun(@(entryScore) sscm.get_entry_values_for_score(entryScore), entryScores, 'UniformOutput', false);
            entryValueScores = arrayfun(@(numEntries, entryScore) repmat({entryScore}, [numEntries, 1]), cellfun(@numel, entryValues), entryScores, 'UniformOutput', false);
            entryValues = vertcat(entryValues{:});
            entryValueScores = cell2mat(vertcat(entryValueScores{:}));
        end
        
        function [entryValueScores, scoreEntries] = get_lowest_k_scores(sscm, k)
            % GET_LOWEST_K_SCORES - Returns the lowest k scores and the
            %  entry values associated with each from the collection
            %
            % Inputs:
            %    sscm
            %     the SortedCollectionManager object
            %    k
            %     the number of lowest scores to get
            %
            %  Outputs:
            %    entryValueScores
            %      array of lowest k unique scores (NaN if less than k
            %       unique scores are present) 
            %    scoreEntries
            %      cell array of cell arrays of entry values associated
            %      with each of the scores
            
            validateattributes(k, {'numeric'}, {'nonnegative', 'integer', 'scalar'});
            entryValueScores = NaN(k, 1);
            scoreEntries = cell(k, 1);
            iterator = sscm.EntryScoreTreeSet.iterator();
            for idx=1:k
                if(not(iterator.hasNext()))
                    return;
                end
                entryScore = iterator.next();
                scoreEntryValues = sscm.get_entry_values_for_score(entryScore);
                entryValueScores(idx) = entryScore;
                scoreEntries{idx} = scoreEntryValues;
            end
        end

        function [nextLowestScore] = get_next_lowest_score(sscm, refScore)
            % GET_NEXT_LOWEST_SCORE - Returns the lowest score higher
            %  than a reference score value
            %
            % Inputs:
            %    sscm
            %     the SortedCollectionManager object
            %    refScore
            %     the reference score
            %
            %  Outputs:
            %    nextLowestScore
            %      a double with the value of the lowest score higher than 
            %      the reference score or an empty array if no score
            %      higher than the reference score exists
            nextLowestScore = sscm.EntryScoreTreeSet.higher(refScore);
        end
    end
    
    methods(Access = protected)
        function [entryValueHash] = get_entry_hash(sscm, entryValue)
            % GET_ENTRY_HASH - calculates the hash of an entry value
            %
            %  Inputs:
            %    sscm
            %     the SortedCollectionManager object
            %    entryValue
            %     the entry value
            %
            %  Outputs
            %    entryValueHash
            %       the hash of the entry value as computed by the entry
            %       value hasher of the SortedCollectionManager
            entryValueHash = sscm.FnEntryValueHasher(entryValue);
            if isempty(entryValueHash) || not(ischar(entryValueHash)) || not(isrow(entryValueHash))
                error('The hashing function is failing to generate a nonempty hash string');
            end
        end

        function [entryScoreExists] = has_entry_score(sscm, entryScore)
            % HAS_ENTRY_SCORE - returns whether the entry score is present
            %  within the collection managed by the SortedCollectionManager
            %
            %  Inputs:
            %    sscm
            %     the SortedCollectionManager object
            %    entryScore
            %     the score for some entry value
            %
            %  Outputs:
            %    entryScoreExists
            %      true if an entry within the collection managed by the
            %       SortedCollectionManager has the entryScore provided
            validateattributes(entryScore, {'double'}, {'nonnan', 'real', 'finite', 'scalar'});
            entryScoreHash = sscm.get_entry_hash(entryScore);
            entryScoreExists = sscm.ScoreHashToEntryHashesMap.isKey(entryScoreHash);
        end

        function [entryValueExists, entryValue] = has_entry_with_hash(sscm, entryValueHash)
            % HAS_ENTRY_WITH_HASH - returns whether an entry within the
            %   collection managed by the SortedCollectionManager is
            %    associated with the entry value hash provided
            %
            %  Inputs:
            %    sscm
            %     the SortedCollectionManager object
            %    entryValueHash
            %     the hash of some entry value
            %
            %  Outputs:
            %    entryValueExists
            %      true if an entry within the collection managed by the
            %       SortedCollectionManager is associated with the provided
            %       hash
            %    entryValue
            %      the value of the entry within the collection managed by
            %      SortedCollectionManager that is associated with the
            %       provided hash if such an entry is present and an empty
            %       0x1 cell array otherwise
            
            entryValueExists = sscm.EntryHashToEntryValueMap.isKey(entryValueHash);
            entryValue = cell(0,1);
            if entryValueExists
                entryValue = sscm.EntryHashToEntryValueMap(entryValueHash);
            end
        end
       
    end
    
    methods(Static = true)
        function [doubleArr] = java_Object_arr_2_double_arr(javaObjArray)
            % JAVA_OBJECT_ARR_2_DOUBLE_ARR - converts java Object array of
            %  values that can be cast to a Java Double into a matlab array
            %  of doubles
            %
            % Inputs:
            %   javaObjArray
            %    the java Object array
            %
            % Outputs:
            %   doubleArr
            %    an array of doubles
            import java.lang.Double;
            doubleArr = arrayfun(@(tmp1) feval(@(tmp2) tmp2.doubleValue(), Double(tmp1)), javaObjArray);
        end
    end

end