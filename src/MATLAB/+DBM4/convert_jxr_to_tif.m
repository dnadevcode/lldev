function [newNames ] = convert_jxr_to_tif(data)

% https://www.xnview.com/en/nconvert/#downloads

    
    mFilePath = mfilename('fullpath');
    mfolders = split(mFilePath, {'\', '/'});
    if ispc
        catcheFold = fullfile(mfolders{1:end - 4},'DataCache','NConvert','nconvert');
    else
        catcheFold = strcat('/',fullfile(mfolders{1:end - 4},'DataCache','NConvert','nconvert'));
    end
    
    if exist(catcheFold)
        st = catcheFold;
    else
        st = 'nconvert';
    end

    command = strcat([st ' -version']);
%     [test,testmessage] = system(command);
% 
%     isrecognized = isempty(strfind(testmessage,'not recognized'))||isempty(strfind(testmessage,'not found'));
    
% 
%     if exist(catcheFold, 'file')
%         st = catcheFold;
%         se = seFold;
%         isrecognized = 1;    
%     end
          
%           
%     if ~isrecognized
%         disp('Please download https://downloads.openmicroscopy.org/bio-formats/5.5.2/artifacts/bftools.zip unzip and add to path');
%         newNames =[];
%         newInfo = [];
%         return;
%     end
    
% [status,results] = system('badcmd');

if nargin < 1
    data =[];
end
% 
% if nargin < 2
%     multiChannels = [];
% end
% 
% if isempty(multiChannels)
%     opts.Interpreter = 'tex';
%     % Include the desired Default answer
%     opts.Default = 'No';
%     % Use the TeX interpreter to format the question
%     quest = 'Is data multichannel';
%     answer = questdlg(quest,'Multichannel parameter',...
%               'Yes','No',opts)
% 
%     multiChannels = isequal(answer,'Yes');
% end
%  


% data = 'C:\Users\Lenovo\postdoc\DATA\DOTS\Albertas\1';
if isempty(data)
    data = dir(fullfile(uigetdir(),'*.jxr'));
% else
%     data = dir(fullfile(data,'*.czi'));

else
    data = dir(data);
end


newNames = [];
newInfo = [];

for i=1:length(data)
    disp(strcat(['Converting movie ' num2str(i) ' from ' num2str(length(data)) ]))
    name =fullfile(data(i).folder,data(i).name);
    [fd,fm,fe] = fileparts(name);
    nameNew = strrep(name,fe,'.tif');
%     nameNew2 = strrep(name,fe,'.ini');
    
    if exist(nameNew,'file')
        delete(nameNew); % in case already exists tif, remove 
    end
    command = strcat([st ' -out tiff "'  name '"']);
    [a1,b1] = system(command);
    newNames{i} = nameNew;
end
% 
%     if exist(nameNew2,'file')
%         delete(nameNew2); % in case already info, remove
%     end
% %     command = strcat([se ' -nopix -nocore "'  name '" > "' nameNew2 '"']);
%     command = strcat([se ' -nopix "'  name '" > "' nameNew2 '"']);
% 
%     [a2,b2] = system(command);
%     newInfo{i} = nameNew2;
% %     info = rawinfo(name);
%     
%     if multiChannels
%         ch1 = imread(nameNew,1);
%         imwrite(ch1,strcat(name,'_C=0.tif'));
%         ch2 = imread(nameNew,2);
%         imwrite(ch2,strcat(name,'_C=1.tif'));
%     else
% %         d = importdata(nameNew2);
% %         posS = cellfun(@(x) ~isempty(strfind(x,'Information|Image|SizeS')),d);
% %         posS = find(posS);
% %         if ~isempty(posS)
% %             sizeS = strsplit(d{posS},":");
% %             sizeS = str2double(sizeS(end));
% %         else
% %             sizeS = 1;
% %         end
% %         
% % %         posM = cellfun(@(x) ~isempty(strfind(x,'Information|Image|SizeM')),d);
% % %         posM = find(posM);
% % %         if ~isempty(posM)
% % %             sizeM =  strsplit(d{posM},":");
% % %             sizeM = str2double(sizeM(end));
% % %         else
% % %             sizeM = 1;
% % %         end
% %         
% %         posT = cellfun(@(x) ~isempty(strfind(x,'Information|Image|SizeT')),d); % number timeframes
% %         posT = find(posT);
% %         if ~isempty(posT)
% %             sizeT =  strsplit(d{posT},":");
% %             sizeT = str2double(sizeT(end));
% %         else
% %             sizeT = 1;
% %         end
% % %         outputFile = regexprep(name, 'czi','');
% % 
% %         for k=1:sizeS
% %             strn=num2str(k);
% %             % rename the original image file with series number
% %             nameNew2 = strrep(name,'.czi',strcat(['_' strn '.tif']));
% %             if exist(nameNew2, 'file')
% %                 delete(nameNew2);
% %             end
% % 
% %             for n = 1: sizeT 
% %                 imwrite( imread(nameNew,sizeT*(k-1)+n),nameNew2,'WriteMode','append');  
% %             end
%         end
% 
% 
%     end

end

