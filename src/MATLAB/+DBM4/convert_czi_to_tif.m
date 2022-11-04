function [newNames, newInfo ] = convert_czi_to_tif(data, multiChannels)

% https://forum.image.sc/t/bfconvert-command-line-tool/5872
% wget https://downloads.openmicroscopy.org/bio-formats/5.5.2/artifacts/bftools.zip
% unzip bftools.zip 
% ./bftools/bfconvert -version
% add to path
%test
    command = strcat(['bfconvert -version']);
    [test,testmessage] = system(command);
    isnotrecognized = strfind(testmessage,'not recognized');
    
    if ~isempty(isnotrecognized)
        disp('Please download https://downloads.openmicroscopy.org/bio-formats/5.5.2/artifacts/bftools.zip unzip and add to path');
        newNames =[];
        newInfo = [];
    end
    
% [status,results] = system('badcmd');

if nargin < 1
    data =[];
end

if nargin < 2
    multiChannels = [];
end

if isempty(multiChannels)
    opts.Interpreter = 'tex';
    % Include the desired Default answer
    opts.Default = 'No';
    % Use the TeX interpreter to format the question
    quest = 'Is data multichannel';
    answer = questdlg(quest,'Multichannel parameter',...
              'Yes','No',opts)

    multiChannels = isequal(answer,'Yes');
end
 


% data = 'C:\Users\Lenovo\postdoc\DATA\DOTS\Albertas\1';
if isempty(data)
    data = dir(fullfile(uigetdir(),'*.czi'));
% else
%     data = dir(fullfile(data,'*.czi'));
end

newNames = [];
newInfo = [];

for i=1:length(data)
    disp(strcat(['Converting movie ' num2str(i) ' from ' num2str(length(data)) ]))
    name =fullfile(data(i).folder,data(i).name);
    nameNew = strrep(name,'.czi','.tif');
    nameNew2 = strrep(name,'.czi','.ini');
    
    if exist(nameNew,'file')
        delete(nameNew); % in case already exists tif, remove 
    end
    command = strcat(['bfconvert '  name ' ' nameNew]);
    [a1,b1] = system(command);
    newNames{i} = nameNew;

    if exist(nameNew2,'file')
        delete(nameNew2); % in case already info, remove
    end
    command = strcat(['showinf -nopix -nocore '  name ' > ' nameNew2 ]);
    [a2,b2] = system(command);
    newInfo{i} = nameNew2;


%     info = rawinfo(name);

    if multiChannels
        ch1 = imread(nameNew,1);
        imwrite(ch1,strcat(name,'_C=0.tif'));
        ch2 = imread(nameNew,2);
        imwrite(ch2,strcat(name,'_C=1.tif'));
    end

end


end

