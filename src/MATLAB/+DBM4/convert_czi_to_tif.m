function convert_czi_to_tif(data, multiChannels)

% https://forum.image.sc/t/bfconvert-command-line-tool/5872
% wget https://downloads.openmicroscopy.org/bio-formats/5.5.2/artifacts/bftools.zip
% unzip bftools.zip 
% ./bftools/bfconvert -version
% add to path

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
else
    data = dir(fullfile(data,'*.czi'));
end


for i=1:length(data)
    disp(strcat(['Converting movie ' num2str(i) ' from ' num2str(length(data)) ]))
    name =fullfile(data(i).folder,data(i).name);
        nameNew = strrep(name,'.czi','.tif');
        nameNew2 = strrep(name,'.czi','.ini');
        
    command = strcat(['bfconvert '  name ' ' nameNew]);
    [a,b] = system(command);

    command = strcat(['showinf -nopix -nocore '  name ' > ' nameNew2 ]);
    [a,b] = system(command);

%     info = rawinfo(name);

    if multiChannels
        ch1 = imread(nameNew,1);
        imwrite(ch1,strcat(name,'_C=0.tif'));
        ch2 = imread(nameNew,2);
        imwrite(ch2,strcat(name,'_C=1.tif'));
    end

end


end

