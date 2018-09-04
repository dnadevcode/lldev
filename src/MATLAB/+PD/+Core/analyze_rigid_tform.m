function [pivotCoord, angleRadians] = analyze_rigid_tform(tform)
    if isa(tform, 'affine2d')
        t = tform.T;
    elseif isnumeric(tform) && isequal(size(tform), [3 3]) && isequal(tform(:, end), [0; 0; 1])
        t = tform;
    else
        error('Unrecognized transformation format');
    end
    dimensionality = 2;

    % Check for expected symmetry in diagonal and off diagonal
    % elements.
    singularValues = svd(t(1:dimensionality,1:dimensionality));
    % For homogeneous scale, expect all singular values to be equal
    % to each other within roughly eps of the largest singular value present.
    isSimilarityTF = max(singularValues)-min(singularValues) < 10*eps(max(singularValues(:)));
    isRigidTF = isSimilarityTF && abs(det(t)-1) < 10*eps(class(t));
    if not(isRigidTF)
        error('Non-rigid transform');
    end

    invT = inv(t);
    invT(:, end) = [0; 0; 1];


    X = [ ...
        0 0; ...% rotational pivot
        1 0 ... % secondary point to determine rotational angle
    ]; 
    % Append an all ones column to put U in homogeneous
    % coordinates for matrix multiply.
    X = padarray(X,[0 1],1,'post');

    U = X*invT;
    pivotCoord = U(1, 1:2); % coordinate that remains unchanged by transformation
    angleRadians = -atan2(U(2, 2) - U(1, 2), U(2, 1) - U(1, 1)); % angle of rotation the transformation causes
end