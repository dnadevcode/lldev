function maxBallCountsInAnyBin = simulate_balls_in_boxes(ballCount, boxCount, slidingBinWidth_pixels, numSimulations)
    %
    % Simulates "balls in boxes"
    %
    % Input:
    % ballCount = number of balls
    % boxCount = number of boxes
    % slidingBinWidth_pixelss = size of "sliding" bins (units of pixels)
    % numSimulations = number of simulations
    %
    % Output:
    % vector, containing XHat values (maximum number of balls found in any
    % bin for each of the simulations)

    % Simulate
    randBoxPlacements = floor(boxCount * rand(ballCount, numSimulations)) + 1; % place r balls in random boxes
    
    % Count number of balls in each box
    histBoxMatrix = zeros(boxCount, numSimulations);
    for simIdx = 1:numSimulations
        histBoxMatrix(:, simIdx) = hist(randBoxPlacements(:, simIdx), 1:boxCount);
    end
    % Bin data, i.e. apply a "sliding" bin of size D to the data
    % (using fft)
    histBinMatrix = zeros(boxCount, numSimulations);
    windowVec = [ones(slidingBinWidth_pixels, 1); zeros(boxCount - slidingBinWidth_pixels, 1)];
    fftWindowVec = fft(windowVec);
    for simIdx = 1:numSimulations
        histBinMatrix(:, simIdx) = ifft(conj(fftWindowVec) .* fft(histBoxMatrix(:, simIdx)));      
    end
    histBinMatrix = round(histBinMatrix); % round to nearest integer as
                                          % fft produces double precision as output
    % count the number of balls in bin with the largest number of balls for
    %  each simulation
    maxBallCountsInAnyBin = max(histBinMatrix, [], 1);
end

