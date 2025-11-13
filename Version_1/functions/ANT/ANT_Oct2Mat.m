%% ANT - check, convert & save %%
% This script does the following:
% 1. Stores original ANT files in 'orig' folder
% 2. Finds complete files - files with 72 (behav) or 36 (mri) responses
% 3. Saves complete files in subject main dir using '-v7' format (allows files to be opened in MATLAB)
clear

%% === Set these variables === %%%

expType = 'mri';          % Which experiment: behavioral ('behav') or fMRI ('mri') % **PAR YOU MAY NEED TO UPDATE**
SubjID  = {'01BP0513',  '01MV0906',  '02BP1112'};    % Subjects to run % **PAR YOU MAY NEED TO UPDATE**

%%
%mainDir = 'Dropbox';
mainDir = '/SynologyDrive/SNAP/projects/chemoBrain'; % **PAR YOU MAY NEED TO UPDATE**
%dataSubDir='forChris/behavioral/ANT/Data'; % for behavioral
dataSubDir='forChris/fMRI/ANT/Data'; % for fMRI % **PAR YOU MAY NEED TO UPDATE**

addpath(genpath(mainDir));

% Make sure you're not in MATLAB
if exist('OCTAVE_VERSION', 'builtin') == 0
   error('This script must be run in Octave.')
end

% Set dir and num trials
currentDir = pwd; 
switch expType
    case 'behav'
        %DataDir = fullfile(getenv('HOME'),mainDir,'CI_Testing/Behavioral/ANT/Data/');
        DataDir = fullfile(getenv('HOME'),mainDir,dataSubDir);
        numTrials = 72;
    case 'mri'
        %DataDir = fullfile(getenv('HOME'),mainDir,'CI_Testing/fMRI/ANT/Data/');
        DataDir = fullfile(getenv('HOME'),mainDir,dataSubDir);
        
        numTrials = 36;
end

% Loop through subjects
for iSubj = 1:numel(SubjID)

    disp(strcat('Subject:',SubjID{iSubj}))

    % Navigate to subject dir
    cd(fullfile(DataDir,SubjID{iSubj}));

    % Check if 'orig' folder exists, otherwise create folder and move the .mat files
    if ~isfolder('orig');

        mkdir('orig');                     % Make 'orig' folder
        origDir  = fullfile(pwd,'orig');   % Store orig directory
        myDir    = dir('*.mat');           % Store all .mat files
        numfiles = length(myDir);          % Number of .mat files

        % Move all .mat files into orig folder
        for i = 1:numfiles
            movefile(myDir(i).name,origDir);
        end

        % Navigate to 'orig' folder
        cd(origDir);
    else
        % If this folder already exists, kill script
        %error('This subject may have already been processed.');
    end

    % Loop through .mat files
    for iFile = 1:numfiles

        cd(origDir)                      % Make sure you're in 'orig'
        MyfileName = myDir(iFile).name;  % Store file name
        load(MyfileName);                % Load file name
        cd ..                            % Move back 1 directory

        % Check to make sure file is complete, if it is then save -v7
        try
            if numel(trialtm) == numTrials || numel(trialtm) == numTrials-1;
                save('-v7',MyfileName,'trialtm','trialprop','trialch','today','room','response','blockstop','blockstart')
                disp(strcat(MyfileName,' saving.'))
            else
                disp(strcat(MyfileName,' is incomplete and will not be saved.'))
            end
        catch
            disp(strcat(MyfileName,' is incomplete and will not be saved.'))
        end
        clear trialtm trialprop trialch today room response blockstop blockstart
    end

end

% Return to main folder
cd(currentDir)