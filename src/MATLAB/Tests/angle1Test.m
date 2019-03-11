% test paramars
rotationSettings.numAngleCandidates = 180*20;
rotationSettings.angleOffset = 0;

for k=1:5
    i = 50 +(k-1)*20;
    % simulate some movie with some molecules
    movieIn{k} = rand(512,512,20);

    movieIn{k}(150:(150+i),250,:) = 2;
    movieIn{k} = imgaussfilt(movieIn{k},2.3);
end

expSolution = 0;

import AB.Processing.get_rotation_angle;



% preconditions

%% Test 1: 0 angle
[actSolution] = get_rotation_angle(movieIn{1}, rotationSettings);
assert(abs(actSolution-expSolution) <= 0.1)

%% Test 2: 0 angle
[actSolution] = get_rotation_angle(movieIn{2}, rotationSettings);
assert(abs(actSolution-expSolution) <= 0.1)


%% Test 3: 0 angle
[actSolution] = get_rotation_angle(movieIn{3}, rotationSettings);
assert(abs(actSolution-expSolution) <= 0.1)


%% Test 4: 0 angle
[actSolution] = get_rotation_angle(movieIn{4}, rotationSettings);
assert(abs(actSolution-expSolution) <= 0.1)


%% Test 5: 0 angle
[actSolution] = get_rotation_angle(movieIn{5}, rotationSettings);
assert(abs(actSolution-expSolution) <= 0.1)

