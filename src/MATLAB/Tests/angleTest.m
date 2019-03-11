function tests = angleTest
    % follows https://se.mathworks.com/help/matlab/matlab_prog/write-function-based-unit-tests-.html

    tests = functiontests(localfunctions);

end

function testAngle1(testCase)
    rotationSettings.numAngleCandidates = 180*20;
    rotationSettings.angleOffset = 0;

    % simulate some movie with some molecules
    movieIn = rand(512,512,20);
    
    movieIn(150:3000,250,:) = 2;
    movieIn = imgaussfilt(movieIn,2.3);
    %figure,imshow(movieIn,[])
    
	import AB.Processing.get_rotation_angle;
    [actSolution] = get_rotation_angle(movieIn, rotationSettings);
    
    expSolution = 0;
    verifyEqual(testCase,actSolution,expSolution,'AbsTol', 0.1)
end

