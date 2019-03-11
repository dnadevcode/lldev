
movie3d = ones(10,20,10);
[cRot, rRot] = meshgrid((1:20), (1:10));

rowStartIdxs = 1;
rowEndIdxs = 10;
colIdxs=10;

%edgeIdxs = cat(3, [rowStartIdxs, colIdxs], [rowEndIdxs, colIdxs]);
kymoMolEdgeIdxs{1} = repmat( cat(3, [1, 10], [10, 10]),10,1,1);
 
kymo.avgL = 2;
sets.preprocessing.kymoEdgeDetection.sideDist = 2;

kymoMolEdgeIdxs2{1} = repmat( cat(3, [4, 10], [7, 10]),10,1,1);

% pretest 

%% Test 1: 0 angle
import AB.Processing.extract_kymos;
[flattenedKymos,layeredKymos, kymosMasks, kymosCenterXYCoords] = extract_kymos(movie3d, rRot, cRot, kymoMolEdgeIdxs,kymo.avgL, sets);

%assert(isequal(size(flattenedKymos),size(ones(10,5))))

assert(isequal(flattenedKymos{1},ones(10,10+4)))

  
%% Test 2: 0 angle
import AB.Processing.extract_kymos;
[flattenedKymos,layeredKymos, kymosMasks, kymosCenterXYCoords] = extract_kymos(movie3d, rRot, cRot, kymoMolEdgeIdxs2,kymo.avgL, sets);

%assert(isequal(size(flattenedKymos),size(ones(10,5))))

assert(isequal(flattenedKymos{1},ones(10,8)))
