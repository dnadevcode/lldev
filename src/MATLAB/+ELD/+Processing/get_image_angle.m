function [alpha] = get_image_angle(M,find_angle)
%get image angle
    % calculates an estimation of an angle in a picture
    % should figure out angle 0!
    
    % Input
    import ELD.Processing.radon2;

    % M - image
    % find_angle
    % if it is needed to compute a new angle, otherwise default angle is
    % 135
    
    if find_angle == 1

        from = 0; % starting angle
        to = 179; % ending angle
        step = 0.1; % step, the smaller step the better for the problem, but slower
        st1= step;
        %numberofindices = 725; % how many indices do we want in the Radon transform
        % more points chosen should give better results, but longer calculation time?

        theta=from:step:to;

        % Calculate the discrete radon transform radon() along the new axis xp,
        % sometimes called Slant Stacking
        RR = radon2(edge(M),theta); 

        %figure, imagesc(RR);
        %figure, plot(var(RR));

        second_derivative_of_RR = diff(diff(var(RR)));


        % For ploting the second derivative of variance
        figure,plot(theta, [0 second_derivative_of_RR 0]);

        % minimum I is reached at index alpha
        [I, alpha] = min(second_derivative_of_RR);

        
        from = alpha-1; % starting angle
        to = alpha+1; % ending angle
        step = 0.05; % step, the smaller step the better for the problem, but slower

        %numberofindices = 725; % how many indices do we want in the Radon transform
        % more points chosen should give better results, but longer calculation time?

        theta=from:step:to;

        % Calculate the discrete radon transform radon() along the new axis xp,
        % sometimes called Slant Stacking
        RR = radon2(edge(M),theta); 

        %figure, imagesc(RR);
        %figure, plot(var(RR));

        second_derivative_of_RR = diff(diff(var(RR)));


        % For ploting the second derivative of variance
       % figure,plot(theta, [0 second_derivative_of_RR 0]);

        % minimum I is reached at index alpha
        [I, alpha] = min(second_derivative_of_RR);
        
        
        % since we used a step, we can get to the actual angle by multiplying
        alpha = from*st1+alpha*step;
    
    else
        alpha = 135;
    end
    
end

