function [ ccMax,randomSequences,ccAll ] = compute_correlation(lenShort, lenLong, method, psfsigmawidth,inputData,barcode )
    % 01/12/16 
    % computes correlation coefficients for a given set of random vectors
    % vs. a reference barcode.
    
    evdPar = [];
    corCoefAll = [];
    if nargin < 5
        secondBar = zscore(refCurve);
        secondBarRev = fliplr(refCurve);
    end
    
    numberOfSequences = 1000;

    ccMax = [];
    ccAll = [];
    switch method
        case 'circcirc'
                   
            randomSequences = inputData;
            
            if nargin<6
                [ longSequence ] = Zeromodel.generate_random_sequences(lenLong,1,inputData, psfsigmawidth,'phase');
                longSequence = zscore(longSequence{1});
            else
                longSequence = barcode;
            end
            
         %   longSequenceRev = fliplr(longSequence);

            for iNew=1:numberOfSequences
                
                ccM = Comparison.cc_circ( zscore(randomSequences{iNew}), zscore(longSequence), 'circular', 'circular');
                ccMax= [ccMax max(max(ccM(:)))];
               % ccAll = [ccAll  [cc1 cc2]];
            end
     
        case 'short_stationary'
            lengthOfSequences = lenShort; % since the zero model is in bp resolution, can choose
            %inputData = meanFFTest;
   
            [ randomSequences ] = Zeromodel.generate_random_sequences(2*lengthOfSequences,numberOfSequences,inputData.^2, psfsigmawidth,'stationary');
            for i=1:length(randomSequences)
                randomSequences{i} = zscore(randomSequences{i}(1:end/2));
            end
            
            if nargin<6
                [ longSequence ] = Zeromodel.generate_random_sequences(lenLong,1,inputData, psfsigmawidth,'phase');
                longSequence = zscore(longSequence{1});
            else
                longSequence = barcode;
            end
            
            longSequenceRev = fliplr(longSequence);

            for iNew=1:numberOfSequences
                [cc1,cc2] =  Comparison.cc_fft(randomSequences{iNew},longSequence);
                ccMax= [ccMax max(max(cc1,cc2))];
                ccAll = [ccAll  [cc1 cc2]];

            end
            
        case 'sort_stationary'    
        	lengthOfSequences = lenShort; % since the zero model is in bp resolution, can choose
            [ randomSeq ] = Zeromodel.generate_random_sequences(2*lengthOfSequences,numberOfSequences,inputData, psfsigmawidth,'stationary');
            randomSequences = cell(1,numberOfSequences);
            for kk=1:numberOfSequences
                randomSequences{kk} = zscore(randomSeq{kk}(1:round(end/2)));
            end
          %randomSequences
            
        case 'short'
            lengthOfSequences = lenShort; % since the zero model is in bp resolution, can choose
            %inputData = meanFFTest;

            [ randomSequences ] = Zeromodel.generate_random_sequences(2*lengthOfSequences,numberOfSequences,inputData, psfsigmawidth,'phase');
            
            for i=1:length(randomSequences)
                randomSequences{i} = zscore(randomSequences{i}(1:end/2));
            end
            
            if nargin<6
                [ longSequence ] = Zeromodel.generate_random_sequences(lenLong,1,inputData, psfsigmawidth,'phase');
                longSequence = zscore(longSequence{1});
            else
                longSequence = barcode;
            end
            
            longSequenceRev = fliplr(longSequence);

            for iNew=1:numberOfSequences
                [cc1,cc2] =  Comparison.cc_fft(randomSequences{iNew},longSequence);
                ccMax= [ccMax max(max(cc1,cc2))];
                ccAll = [ccAll;  cc1 cc2];

            end
            
            
        case 'shortPrec'
           % lengthOfSequences = lenShort; % since the zero model is in bp resolution, can choose
            %inputData = meanFFTest;

%             [ randomSequences ] = Zeromodel.generate_random_sequences(2*lengthOfSequences,numberOfSequences,inputData, psfsigmawidth,'phase');
%             for i=1:length(randomSequences)
%                 randomSequences{i} = zscore(randomSequences{i}(1:end/2));
%             end
%             
            randomSequences = inputData;
            
            if nargin<6
                [ longSequence ] = Zeromodel.generate_random_sequences(lenLong,1,inputData, psfsigmawidth,'phase');
                longSequence = zscore(longSequence{1});
            else
                longSequence = barcode;
            end
            
         %   longSequenceRev = fliplr(longSequence);

            for iNew=1:numberOfSequences
                import CA.CombAuc.Core.Comparison.cc_fft;
                [cc1,cc2] = cc_fft(randomSequences{iNew},longSequence);
                ccMax= [ccMax max(max(cc1,cc2))];
                ccAll = [ccAll  [cc1 cc2]];
            end
   
          case 'longPrec'
           % lengthOfSequences = lenShort; % since the zero model is in bp resolution, can choose
            %inputData = meanFFTest;

%             [ randomSequences ] = Zeromodel.generate_random_sequences(2*lengthOfSequences,numberOfSequences,inputData, psfsigmawidth,'phase');
%             for i=1:length(randomSequences)
%                 randomSequences{i} = zscore(randomSequences{i}(1:end/2));
%             end
%             
            randomSequences = inputData;
            
            if nargin<6
                [ longSequence ] = Zeromodel.generate_random_sequences(lenLong,1,inputData, psfsigmawidth,'phase');
                longSequence = zscore(longSequence{1});
            else
                longSequence = barcode;
            end
            
         %   longSequenceRev = fliplr(longSequence);

            for iNew=1:numberOfSequences
                [cc1,cc2] = Comparison.cc_fft(randomSequences{iNew},barcode);
                ccMax= [ccMax max(max(cc1,cc2))];
                ccAll = [ccAll  [cc1 cc2]];
            end
            
        case 'long'
            lengthOfSequences = lenLong; % since the zero model is in bp resolution, can choose
            %inputData = meanFFTest;

            if nargin <6
                [ shortSequence ] = Zeromodel.generate_random_sequences(2*lenShort,1,inputData, psfsigmawidth,'phase');
                shortSequence = zscore(shortSequence{1}(1:end/2));
            else
                shortSequence = barcode;
            end
            
            [ randomSequences ] = Zeromodel.generate_random_sequences(lengthOfSequences,numberOfSequences,inputData, psfsigmawidth,'phase');
            %randomSequences{1}
            for i=1:length(randomSequences)
                randomSequences{i} = zscore(randomSequences{i});
            end
            %shortSequenceRev = fliplr(shortSequence);

            for iNew=1:numberOfSequences
                [cc1,cc2] = Comparison.cross_correlation_coefficients_fft(shortSequence,randomSequences{iNew});
                ccMax= [ccMax max(max(cc1,cc2))];
                %ccAll = [ccAll  [cc1 cc]];
            end
        otherwise
            randomSequences = {};
    end
    

    %figure,hist(ccMax,sqrt(length(ccMax)))

end




