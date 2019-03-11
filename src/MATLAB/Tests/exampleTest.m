function tests = exampleTest
    % follows https://se.mathworks.com/help/matlab/matlab_prog/write-function-based-unit-tests-.html

    tests = functiontests(localfunctions);

end

function testRealSolution(testCase)
    import AB.Processing.extract_kymos;
    [flattenedKymos,layeredKymos, kymosMasks, kymosCenterXYCoords] = extract_kymos(movie3d, rRot, cRot, kymoMolEdgeIdxs,kymo.avgL, sets);

    actSolution = quadraticSolver(1,-3,2);
    expSolution = [2 1];
    verifyEqual(testCase,actSolution,expSolution)
end

