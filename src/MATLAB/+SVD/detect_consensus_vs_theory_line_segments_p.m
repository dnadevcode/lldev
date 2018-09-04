function [] = detect_consensus_vs_theory_line_segments_p(ts, consensusCurve, theoryCurve)
    % DETECT_CONSENSUS_VS_THEORY_LINE_SEGMENTS_P = Line segment detection consensus vs theory
    %
    % Creates a matrix with comparisons of small segments
    % between a consensus and a theoretical sequence, and highlights
    % similar regions.
    %
    % Authors:
    %   Erik Lagerstedt
    %   Saair Quaderi (refactoring)
    %
    % This is not a final version. There is much code that can be removed and
    % other parts that can be rewritten. It is similar to 
    % cb_linesegmentdetection, but that function is using another (and 
    % possibly worse) algorithm to create the binary matrix.

    %TODO: consolidate with other version
    
    % Dynamic time warp is used to find the
    % direction the barcodes should have. Probably a bit wasteful.

    indelRelCost = 40;
    import SVD.Core.compute_dtw;
    [dtwUnnormalizedDist, ~, ~, ~] = compute_dtw(consensusCurve, theoryCurve, indelRelCost, indelRelCost);
    [dtwUnnormalizedDistFlipped, ~, ~, ~] = compute_dtw(flip(consensusCurve), theoryCurve, indelRelCost, indelRelCost);
    if dtwUnnormalizedDistFlipped < dtwUnnormalizedDist
        consensusCurve = flip(consensusCurve);
    end

    % Here the matrix is created. Each pixel is the cross correlation
    % between two small sections of the two barcodes.
    xs = zeros([numel(consensusCurve), numel(theoryCurve)]);
    fragLeng = 10;
    for idxAlongConsensusCurve = 1:(length(consensusCurve) - fragLeng)
        for idxAlongTheoryCurve=1:(length(theoryCurve) - fragLeng)
            xs(idxAlongConsensusCurve, idxAlongTheoryCurve) = (sum(consensusCurve(idxAlongConsensusCurve:(idxAlongConsensusCurve + fragLeng)) .* theoryCurve(idxAlongTheoryCurve:(idxAlongTheoryCurve + fragLeng))) / (norm(consensusCurve(idxAlongConsensusCurve:(idxAlongConsensusCurve + fragLeng)))*norm(theoryCurve(idxAlongTheoryCurve:(idxAlongTheoryCurve + fragLeng)))));
        end
    end
    
    hPanelA = ts.create_tab('A');
    hAxisA = axes('Parent', hPanelA);
    matA = xs;
    imshow(matA, [], 'Parent', hAxisA);
    
    
    xs0 = xs(1:(end - fragLeng), 1:(end - fragLeng));
    matB = xs0;
    hPanelB = ts.create_tab('B');
    hAxisB = axes('Parent', hPanelB);
    imshow(matB, [], 'Parent', hAxisB);
    
    % Each element in the matrix is set to 1 or 0, to get a black-and-white
    % image, which then can be evaluated.

    % One way of choosing the threshold
    % xs2 = (xs > 0.9);

    % Another way of choosing the threshold
    c = 5;
    valVec = sort(xs(:), 'descend');
    theshValIdx = round(length(valVec) * c * sqrt(2) / min(size(xs)));
    xs2 = (xs > valVec(theshValIdx));
    matC = abs(xs2 - 1);

    hPanelC = ts.create_tab('C');
    hAxisC = axes('Parent', hPanelC);
    colormap(hAxisC, gray());
    imagesc(matC, 'Parent', hAxisA);
    set(hAxisA, ...
        'XTick', [], ...
        'YTick', []);

    xs3 = zeros(size(xs));
    for idxAlongConsensusCurve = 1:(length(consensusCurve) - fragLeng)
        for idxAlongTheoryCurve = 1:(length(theoryCurve) - fragLeng)
            if xs2(idxAlongConsensusCurve, idxAlongTheoryCurve)
                for ijc = 0:(fragLeng - 1)
                    xs3(idxAlongConsensusCurve + ijc, idxAlongTheoryCurve + ijc) = 1;
                end
            end
        end
    end
    xs2 = xs3;
    matD = abs(xs3 - 1);
    
    hPanelD = ts.create_tab('D');
    hAxisD = axes('Parent', hPanelD);
    colormap(hAxisD, gray());
    imagesc(matD, 'Parent', hAxisD);
    set(hAxisD, ...
        'XTick', [], ...
        'YTick', []);


    % Some filters are applied to enhance and detect the lines.
    sigmaTV = 0.5;
    sizeTV = 2;
    x = linspace(-sizeTV / 2, sizeTV / 2, sizeTV);
    gaussFilter = exp(-x .^ 2 / (2 * sigmaTV ^ 2));
    gaussFilter = gaussFilter / sum(gaussFilter);
    xs2 = filter(gaussFilter,1, xs2);
    xs2 = filter(gaussFilter,1, xs2');
    xs2 = xs2';
    matE = abs(xs2 - 1);
    
    hPanelE = ts.create_tab('E');
    hAxisE = axes('Parent', hPanelE);
    colormap(hAxisE, gray());
    imagesc(matE, 'Parent', hAxisE);

    import ThirdParty.RankOrderFilter.RankOrderFilter;
    xs5 = fliplr(RankOrderFilter(xs2,20,30)); %TODO: ang of 45
    xs6 = RankOrderFilter(fliplr(xs2),20,30); %TODO: ang of -45

    sigmaTV = 0.5;
    sizeTV = 2;
    x = linspace(-sizeTV / 2, sizeTV / 2, sizeTV);
    gaussFilter = exp(-x .^ 2 / (2 * sigmaTV ^ 2));
    gaussFilter = gaussFilter / sum(gaussFilter);
    xs5 = filter(gaussFilter,1, xs5);
    sigmaTV = 0.5;
    sizeTV = 2;
    x = linspace(-sizeTV / 2, sizeTV / 2, sizeTV);
    gaussFilter = exp(-x .^ 2 / (2 * sigmaTV ^ 2));
    gaussFilter = gaussFilter / sum(gaussFilter);
    xs6 = filter(gaussFilter,1, xs6);
    [xs7, xs7T, xs7R] = hough(xs5 > 0, 'Theta', -45);

    xs7c = houghlines(xs5, xs7T, xs7R, houghpeaks(xs7, 20), 'FillGap', 10, 'MinLength', 50);

    matF = abs((xs5 > 0) - 1);
    hPanelF = ts.create_tab('F');
    hAxisF = axes('Parent', hPanelF);
    imagesc(matF, 'Parent', hAxisF);
    colormap(hAxisF, gray());
    hold(hAxisF, 'on');
    for it=1:length(xs7c)
        xy = [xs7c(it).point1; xs7c(it).point2];
        plot(hAxisF, xy(:, 1), xy(:, 2), 'LineWidth', 2, 'Color','r');
    end
    hold(hAxisF, 'off');
    set(hAxisF, ...
        'XTick', [], ...
        'YTick', []);

    [xs8, xs8T, xs8R] = hough(xs6 > 0, 'Theta', 45);

    xs8c = houghlines(xs6, xs8T, xs8R, houghpeaks(xs8, 20), 'FillGap', 10, 'MinLength', 50);

    matG = abs((xs6 > 0) - 1);
    hPanelG = ts.create_tab('G');
    hAxisG = axes('Parent', hPanelG);
    imagesc(matG, 'Parent', hAxisG);
    colormap(hAxisG, gray());
    hold(hAxisG, 'on');
    for it=1:length(xs8c)
        xy = [xs8c(it).point1; xs8c(it).point2];
        plot(hAxisG, xy(:, 1), xy(:, 2), 'LineWidth', 2, 'Color', 'r');
    end
    hold(hAxisG, 'off');
    set(hAxisG, ...
        'XTick', [], ...
        'YTick', []);

    gmcc = zeros(length(xs7c), 1);
    tmcc = zeros(length(xs8c), 1);

    % The detected lines are saved and drawn.
    matH = abs(((xs5 + xs6) > 0) - 1);
    
    hPanelH = ts.create_tab('H');
    hAxisH = axes('Parent', hPanelH);
    imagesc(matH, 'Parent', hAxisH);
    colormap(hAxisH, gray());
    hold(hAxisH, 'on');
    
    hPanelI = ts.create_tab('I');
    import Fancy.UI.FancyTabs.TabbedScreen;
    tsI = TabbedScreen(hPanelI);
    for it = 1:length(xs7c)
        xy = [xs7c(it).point1; xs7c(it).point2];
        %CC for the matching fragments
        conSec=consensusCurve(xs7c(it).point1(1,2):xs7c(it).point2(1,2));
        thySec=theoryCurve(xs7c(it).point1(1,1):xs7c(it).point2(1,1));
        if length(conSec)==length(thySec)
            gmcc(it)=sum(conSec.*thySec)/length(conSec);
        else
            if length(conSec)>length(thySec)
                conSec=conSec(1:length(thySec));
            else
                thySec=thySec(1:length(conSec));
            end
            gmcc(it)=sum(conSec.*thySec)/length(conSec);
        end
        hTabTmpI = tsI.create_tab(sprintf('%d', it));
        hPanelTmpI = uipanel('Parent', hTabTmpI);
        hAxisTmpI = axes('Parent', hPanelTmpI);
        plot(hAxisTmpI, conSec);
        hold(hAxisTmpI, 'on');
        plot(hAxisTmpI, thySec, 'r');
        xlabel(hAxisTmpI, gmcc(it));
        hold(hAxisTmpI, 'off');
    end
    
    hPanelJ = ts.create_tab('J');
    import Fancy.UI.FancyTabs.TabbedScreen;
    tsJ = TabbedScreen(hPanelJ);
    
    for it = 1:length(xs8c)
        %CC for the matching fragments
        if xs8c(it).point2(1,1) < xs8c(it).point1(1,1)
            conSec = consensusCurve(xs8c(it).point1(1,2):xs8c(it).point2(1,2));
            thySec = fliplr(theoryCurve(xs8c(it).point2(1,1):xs8c(it).point1(1,1)));
        else
            conSec = consensusCurve(xs8c(it).point2(1,2):xs8c(it).point1(1,2));
            thySec = fliplr(theoryCurve(xs8c(it).point1(1,1):xs8c(it).point2(1,1)));            
        end
        if length(conSec) == length(thySec)
            tmcc(it) = sum(conSec .* thySec) / length(conSec);
        else
            if length(conSec) > length(thySec)
                conSec = conSec(1:length(thySec));
            else
                thySec = thySec(1:length(conSec));
            end
            tmcc(it) = sum(conSec.*thySec)/length(conSec);
        end
        hTabTmpJ = tsJ.create_tab(sprintf('%d', it));
        hPanelTmpJ = uipanel('Parent', hTabTmpJ);
        hAxisTmpJ = axes('Parent', hPanelTmpJ);
        plot(hAxisTmpJ, conSec);
        hold(hAxisTmpJ, 'on');
        plot(hAxisTmpJ, thySec, 'r');
        xlabel(hAxisTmpJ, tmcc(it));
        hold(hAxisTmpJ, 'off');
    end

    % The image is ploted, and the lines are drawn on it. The cross
    % correlation for the region under the line is displayed.
    hPanelK = ts.create_tab('K');
    hAxisK = axes('Parent', hPanelK);
    
    imagesc(abs(xs2-1), 'Parent', hAxisK);
    colormap(hAxisK, gray());
    hold(hAxisK, 'on');
    for it = 1:length(xs7c)
        xy = [xs7c(it).point1; xs7c(it).point2];
        plot(hAxisK, xy(:, 1), xy(:, 2), 'LineWidth', 3, 'Color', 'g');
        text(xs7c(it).point1(1, 1), xs7c(it).point1(1, 2), num2str(gmcc(it)), 'Color', 'g', 'FontWeight', 'bold');
    end
    for it = 1:length(xs8c)
        xy = [xs8c(it).point1; xs8c(it).point2];
        plot(hAxisK, xy(:,1), xy(:,2), 'LineWidth', 3, 'Color', 'r');
        text(xs8c(it).point1(1, 1), xs8c(it).point1(1, 2), num2str(tmcc(it)), 'Color', 'r', 'FontWeight', 'bold');
    end
    hold(hAxisK, 'off');
    set(hAxisK, ...
        'XTick', [], ...
        'YTick', []);

    % [xs5a,xs5b,xs5c]=hough(xs5);
    % [xs6a,xs6b,xs6c]=hough(xs6);
    % xs5=houghlines(xs2,xs5b,xs5c,houghpeaks(xs5a,3));
    % xs6=houghlines(xs6,xs6b,xs6c,houghpeaks(xs6a,3));
    % 
    % sigmaTV = 5;
    % sizeTV = 30;
    % x = linspace(-sizeTV / 2, sizeTV / 2, sizeTV);
    % gaussFilter = exp(-x .^ 2 / (2 * sigmaTV ^ 2));
    % gaussFilter = gaussFilter / sum(gaussFilter);
end