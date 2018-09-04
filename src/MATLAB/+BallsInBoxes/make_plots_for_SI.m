function [] = make_plots_for_SI(hAxisBallsInBoxes, boxCount, slidingBinWidth_pixels, numSimulations, ballCounts, xDelta)
    if nargin < 1
        hAxisBallsInBoxes = [];
    end
    if isempty(hAxisBallsInBoxes)
        hFig = figure('Name', 'Balls In Boxes');
        hPanel = uipanel('Parent', hFig);
        import Fancy.UI.FancyTabs.TabbedScreen;
        ts = TabbedScreen(hPanel);
        hTabBallsInBoxes = ts.create_tab('Balls in Boxes');
        hPanelBallsInBoxes = uipanel('Parent', hTabBallsInBoxes);
        hAxisBallsInBoxes = axes('Parent', hPanelBallsInBoxes);
    end
    if nargin < 2
        boxCount = [];
    end
    if isempty(boxCount)
        boxCount = 10; % number of boxes
    end
    if nargin < 3
        slidingBinWidth_pixels = [];
    end
    if isempty(slidingBinWidth_pixels)
        slidingBinWidth_pixels = 4; % size of "sliding" bins (units of pixels)
    end
    if nargin < 4
        numSimulations = [];
    end
    if isempty(numSimulations)
        numSimulations = 10000; % number of simulations
    end
    if nargin < 5
         ballCounts = [30, 40, 50]; % number of balls for each set
    end
    if nargin < 6
        xDelta = [];
    end
    if isempty(xDelta)
        xDelta = 0.1; % delta x value for Gumbel fits
    end
    
    
    % Plot rho(m) based on simulations for placing r balls in n boxes
    % and counting (m) the number of balls in the "sliding" bin
    % with the largest number of balls.


    numIterations = length(ballCounts);

    import ThirdParty.DistinguishableColors.distinguishable_colors;
    colorChoices = distinguishable_colors(numIterations);
    

    function [gumbelPDF] = fit_gumbel_pdf_moment_matching(maxBallCountsInAnyBin, xTheory)
        % Fit Gumbel PDF to data (moment matching)
        
        meanMaxBallCountsInAnyBin = mean(maxBallCountsInAnyBin);
        stdMaxBallCountsInAnyBin = std(maxBallCountsInAnyBin);

        gammap = double(eulergamma);                   % The Euler-Mascheroni constant (0.5772)
        betap = stdMaxBallCountsInAnyBin * sqrt(6)/pi;   % first parameter in Gumbel PDF
        mup = meanMaxBallCountsInAnyBin - (betap * gammap);     % second parameter in Gumbel PDF
        z = (xTheory - mup) / betap;
        gumbelPDF = exp(-(z+exp(-z)))/betap;
        
    end
    function [gumbelPDF_ML] = fit_gumbel_pdf_max_likelihood(maxBallCountsInAnyBin, xTheory)
        % Fit Gumbel PDF to data (maximum likelihood)
        
        fitParam = fitdist(-maxBallCountsInAnyBin', 'ExtremeValue');
        mup = -fitParam.mu;
        betap = fitParam.sigma;
        z = (xTheory-mup)/betap;
        gumbelPDF_ML = exp(-(z+exp(-z)))/betap;
    end

    function [gevPDF] = fit_generalized_evd_max_likelihood(maxBallCountsInAnyBin, xTheory)
        % Fit generalized extreme value distribution (maximum likelihood)
        fitParam = fitdist(maxBallCountsInAnyBin', 'GeneralizedExtremeValue');
        pd = makedist('GeneralizedExtremeValue', 'k', fitParam.k, 'sigma', fitParam.sigma, 'mu', fitParam.mu);
        gevPDF = pdf(pd, xTheory);
    end
    

    % Loop over all choices of number of balls
    hSims = gobjects(1, numIterations);
    hFits = gobjects(1, numIterations);
    import BallsInBoxes.simulate_balls_in_boxes;
    for iterationNum = 1:numIterations
        ballCount = ballCounts(iterationNum);
        
        xTheory = 0:xDelta:(slidingBinWidth_pixels * ballCount);
        
        % Make simulation and histogram
        maxBallCountsInAnyBin = simulate_balls_in_boxes(ballCount, boxCount, slidingBinWidth_pixels, numSimulations); % i.e. XHat
        histXHat = hist(maxBallCountsInAnyBin, 0:slidingBinWidth_pixels*ballCount);
        rho_sim = histXHat / sum(histXHat);


        % % Fit Gumbel PDF to data (moment matching)
        % gumbelPDF = fit_gumbel_pdf_moment_matching(maxBallCountsInAnyBin, xTheory);

        % % Fit Gumbel PDF to data (maximum likelihood)
        % gumbelPDF_ML = fit_gumbel_pdf_max_likelihood(maxBallCountsInAnyBin, xTheory);

        % Fit generalized extreme value distribution (maximum likelihood)
        gevPDF = fit_generalized_evd_max_likelihood(maxBallCountsInAnyBin, xTheory);
        
        % Plot 
        set(hAxisBallsInBoxes, 'FontSize', 14);
        % Histogram based on simulations
        X = 0:slidingBinWidth_pixels*ballCount;
        hSims(iterationNum) = plot(hAxisBallsInBoxes, X, rho_sim, '-', 'LineWidth', 2, 'Color', colorChoices(iterationNum, :));
        hold(hAxisBallsInBoxes, 'on');
        
        % % Gumbel PDF, moment matching
        % hFits(iterationNum) = plot(hAxis, xTheory, gumbelPDF, ':', 'linewidth', 2, 'Color', colorChoices(iterationNum, :)); hold on;
        
        % % Gumbel PDF, maximum likelihood
        hFits(iterationNum) = plot(hAxisBallsInBoxes, xTheory, gevPDF, '--', 'LineWidth', 2, 'Color', colorChoices(iterationNum, :));
        hold(hAxisBallsInBoxes, 'on');
        
        % % Generalized extreme value fit 
        % hFits(iterationNum) = plot(hAxis, xTheory, gevPDF, '-.', 'linewidth', 2, 'Color', colorChoices(iterationNum, :)); hold on;


        % Calculate mean and std dev
        meanMaxBallCountsInAnyBin = mean(maxBallCountsInAnyBin);
        stdMaxBallCountsInAnyBin = std(maxBallCountsInAnyBin);
        
        % Mean and std dev 
        heightStdDevBar = max(rho_sim)/2;
        x = [1, 1] .* meanMaxBallCountsInAnyBin;
        y = [0, heightStdDevBar * 2];
        plot(hAxisBallsInBoxes, x, y, '--', 'Color', colorChoices(iterationNum, :));
        hold(hAxisBallsInBoxes, 'on');
        x = ([-1, 1] .* stdMaxBallCountsInAnyBin) + meanMaxBallCountsInAnyBin;
        y = heightStdDevBar*[1, 1];
        plot(hAxisBallsInBoxes, x, y, '--', 'Color', colorChoices(iterationNum, :));
        hold(hAxisBallsInBoxes, 'on');
    end

    ylabel(hAxisBallsInBoxes, 'Normalized histogram');
    xlabel(hAxisBallsInBoxes, 'Number of balls in most-filled bin');
    maxXForPlot = max(ballCounts);  % max x-value for plot
    maxYForPlot = 0.3;              % max y-value for plot
    axis(hAxisBallsInBoxes, [0, maxXForPlot, 0, maxYForPlot]);
    sLegends = arrayfun(...
        @(ballCount) sprintf('r = %d', ballCount), ...
        ballCounts, ...
        'UniformOutput', false);
    legend(hSims, sLegends);
    hold(hAxisBallsInBoxes, 'off');
end