function [theorySequence, matchSequence] = import_sequences()


[theoryFilename, dirpath] = uigetfile( ...
{  '*.mat;*.fasta','Sequence files (*.mat, *.fasta)'; ...
   '*.mat','MAT-files (*.mat)'; ...
   '*.fasta', 'FASTA-files (*.fasta)'}, ...
   'Select file with theoretical sequence', ...
   'MultiSelect', 'off');

aborted = isequal(dirpath, 0);
if aborted
    return;
end

dot = regexp(theoryFilename,'\.');
switch(theoryFilename(dot+1:end))

case 'mat'
    theoryFilepath = fullfile(dirpath, theoryFilename);

    theoryData = load(theoryFilepath);
    theoryData = theoryData.theoreticalData;

    theorySequence = theoryData.completeDNASequence;

case 'fasta'
    theoryFilepath = fullfile(dirpath, theoryFilename);
    [MoleculeHeader, theorySequence] = fastaread(theoryFilepath);

    otherwise
    disp('Cannot process file type. Please use a .mat or .fasta file.')
end

prompt = {'Enter the target sequence:'};
dlg_title = 'Input';
num_lines = 1;
defaultans = {'TCGA'};
matchSequence = inputdlg(prompt,dlg_title,num_lines,defaultans);
matchSequence = matchSequence{1};

end