% Updated for CRCC proj by Michele Maslowski
% 11/3/2025
% This script does the following:
%   (1) Load .mat files for each of the 6 runs
%   (2) Removes bad trials
%   (3) Generates timing info and exports as .txt files
%   (4) Plots behavioral data (RT and % correct)

% Experimental Design:
%   10 seconds fix | trial(n): cue (200ms) | CTI | Target (2000ms response window) | ITI | 12 secs fixation before experiment ends

clear all
close all

%% Check/Set These Variables
%===========================================================================
% Options
TxtGenReg = 1;           % Generate .txt files with start times
TxtGenDur = 1;           % Generate duration modulated .txt files A*B:C A=start time, B = amplitude modulation, C = duration
DurMod = {":"};          % How to treat durantion modulated trials: {"*1:"};
%LocOrClust = 'loc';     % Options: 'clu' save .txt files on cluster *must be connected through SSHFS*, or 'loc' save files locally
pltBH_subj  = 0;         % Plot behavioral data? RTs and percent correct (1 or 0)
pltBH_group = 0;
saveplt     = 0;             % Save plot (to local folder)?
Alerts      = 'on';           % Toggle alerts
whichStudy  = 'MRI';     % MRI or Behav 
saveFig     = 1; 
    Fmt = '-png';
    qOpt = '-q50';
    mOpt = '-m5';
%===========================================================================
saveGroupData = 1;
    switch whichStudy
        case 'Behav'
            groupDir = 'C:\Users\mmasl\OneDrive - Marquette University\Desktop\SNAP LAB\CRCC_beh_data\raw data\'; % 
        case 'MRI'         
            %****** CHANGE to the file path on where the data is stored **%
            groupDir = 'C:\Users\mmasl\OneDrive - Marquette University\Desktop\SNAP LAB\CRCC_beh_data\raw data\';  
    end

% Subject & scan info

% something wrong w "02TM0526"
SubjID   = {"01AM0902", "01AW1002", "01BP0513","01JB0223", "01JZ0719", "01MJ0412", "01RE1013","01TM1018","01TR0606", "02AM0425","02AW0324", "02BP1112","02JB0603", "02JZ0401", "02MJ0823","02RE0317","02TR0920"}; % **PAR YOU MAY NEED TO UPDATE**
ScanDays = [1];          % Scan Days
errB     = 'std';        % errorbars: use ste or std % **PAR YOU MAY NEED TO UPDATE**

Nruns    = 6;           % Set which runs to process, or leave empty for script to find runs automatically

% Exlusion criteria
RTless       = .200;     % Exlude trials with RTs less than RTless.
CT_SC_check  = .94;      % Exlude subjects who perform worse than CT_SC_check % on congruent, spatial cue trials.
RemWrongResp = 1;        % Set to 1 to remove incorrect trials

currentPath = pwd;
cp_split    = split(currentPath,'/');


switch whichStudy
    case 'MRI'
        % *** change file path *** &
        DataFolder  = "C:\Users\mmasl\OneDrive - Marquette University\Desktop\SNAP LAB\CRCC_beh_data\raw data\"; % **PAR YOU MAY NEED TO UPDATE**
    case 'Behav'
        
        DataFolder  = "/Users/Shared/ANT/ANT_update_8_14_24/Behavioral/ANT/Data/"; 
end

%% Set timing and other info

% Timing & trial info
NumTrials    = 84;      % Number of trials per run
RespWin      = 2000;    % Response window
CuePres      = 200;     % Time cue is on the screen
PreFix       = 10000;   % 10 sec fixation at start of run
PostFix      = 12000;   % 12 sec fixation at end of run
IdealRunTime = 346;     % Run should last 346 seconds

% trialprop info (these are the columns in the trialprop variable)
CueCol   = 1;           % Cue condition (SC, NC, CC) in 1st column of trialprop
TargLoc  = 2;           % Target location (top, bottom) in 2nd column
TargDir  = 3;           % Target direction (left, right) in the 3rd column
TarCol   = 4;           % Target condition (IT, CT) in 4th column
FlankDir = 5;           % Flanker direction (right, left) in the 5th column
CTI      = 6;           % CTI is stored in the 6th column
ITI      = 7;           % ITI is stored in the 7th column

%% Initiate analysis loop

% Loop through subjects
for s = 1:numel(SubjID)
    
    RT_Subj = struct();
    RTs = struct();
    AccuracyStore = [];

    % Store performance for spatial cue & congruent trials
    SC_CT_store = [];
    
    % Loop through scan days (day 1 or day 2)
    for d = ScanDays
         
        % Go to behavioral files and load dir info
        BHdata_dir = strcat(DataFolder,SubjID{1,s}); % Path to behavioral fMRI files
        cd(BHdata_dir);          % Go to behavioral data
        files = dir('*.mat');    % Store filenames
        
        nameStore = [];
        for i = 1:numel([files.datenum])
            if startsWith(files(i).name,'._')
               nameStore(i) = 1;
            else
               nameStore(i) = 0;
            end
        end
        files([find(nameStore)]) = [];
        
        SaveFolder = fullfile(DataFolder,SubjID{1,s});
        
        % Check number of runs; display warning if not equal to 6
          Nruns = numel([files.datenum]);
        
        % Preallocate
        RTs.SC{d}=[];
        RTs.CC{d}=[];
        RTs.NC{d}=[];
        RTs.IT{d}=[];
        RTs.CT{d}=[];
        RTs.SC_CT{d}=[];
        RTs.CC_CT{d}=[];
        RTs.NC_CT{d}=[];
        RTs.SC_IT{d}=[];
        RTs.CC_IT{d}=[];
        RTs.NC_IT{d}=[];
        
        % Loop through runs
        for r = 1:Nruns
            
            % Go to behavioral data
            cd(BHdata_dir);   
            
            % load data file for run(r)
            load(files(r).name)
            
            % Compute behavior
            for i = 1:numel(response)
                if strcmp(trialprop{i,TargDir},'R') && strcmp(trialch(i),'R')
                    response(i) = 1;
                elseif strcmp(trialprop{i,TargDir},'L') && strcmp(trialch(i),'L')
                    response(i) = 1;
                end

                if strcmp(SubjID{s},'rr') && r>2
                    if strcmp(trialprop{i,TargDir},'R') && strcmp(trialch(i),'R')
                        response(i) = 1;
                    elseif strcmp(trialprop{i,TargDir},'L') && strcmp(trialch(i),'L')
                        response(i) = 1;
                    end
                end

            end

            if strcmp(SubjID{s},'ew')
                if r == 2 || r == 3
                    response(36) = 0;
                    trialtm(36) = 0;
                end
            end
            

            if strcmp(SubjID{s},'rh')
                if r == 6
                    response(36) = 0;
                    trialtm(36) = 0;
                end
            end

            % Set & check number of trials
            nTrials = size(trialprop,1);
            if strcmp(Alerts,'on')
                if exist('response') == 0  % Check if response variable exists
                    wrnmsg = strcat('The response variable is missing. Would you like to continue?');
                    resp = questdlg(wrnmsg,'Warning','Yes','No','No');
                    if strcmp(resp,'No')
                        return
                    end
                elseif exist('response') == 1 && sum(response) == 0 && strcmp(SubjID{s},'MMG')==0% Check responses
                    wrnmsg = strcat('There are no correct responses. Would you like to continue?');
                    resp = questdlg(wrnmsg,'Warning','Yes','No','No');
                    if strcmp(resp,'No')
                        return
                    end
                end
            end
            
            % Loop through trials
            for i = 1:nTrials
                
                % Store trial starts(i); timelocked to cue (TrialStart) & timelocked to target (TargetStart)
                if i == 1
                    % Trial starts; cue appears
                    TrialStart{d}(r,i) = PreFix;  % First trial begins after 10 seconds
                    TimeCount = PreFix;
                    
                    % Target appears
                    TargetStart{d}(r,i) = PreFix + CuePres + cell2mat(trialprop(i,CTI)); % First target appears after prefix + Cue presentation + CTI
                else
                    % Trial starts; cue appears
                    TrialStart{d}(r,i) = TimeCount;
                    
                    % Target appears
                    TargetStart{d}(r,i) = TimeCount + CuePres + cell2mat(trialprop(i,CTI));
                end
                
                % Update trial time (add ITI, CTI, RespWin, Cuepress)
                TimeCount = TimeCount + cell2mat(trialprop(i,CTI)) + RespWin + CuePres + cell2mat(trialprop(i,ITI));
                
            end % NumTrials
            
            % Convert ms to secs
            TrialStart{d}(r,:) = TrialStart{d}(r,:)/1000;
            TargetStart{d}(r,:) = TargetStart{d}(r,:)/1000;
            
            % Store behavioral data
            RT{d}(r,:) = trialtm;               % Reaction time
            RT{d}(r,RT{d}(r,:)==0) = NaN;       % Replace zeros with NaNs
            if strcmp(SubjID{s},'MMG') && d == 2 
                for accu = 1:numel(response)
                    if strcmp(trialch(accu),'7') && strcmp(trialprop(accu,3),'R')
                        response(1,accu) = 1;
                    elseif strcmp(trialch(accu),'8') && strcmp(trialprop(accu,3),'L')
                        response(1,accu) = 1;
                    else
                        response(1,accu) = 0;
                       
                    end
                end
            end
            
           AccuracyStore{s}(d,r) =  numel(find(response==1))/size(trialprop,1);
           disp(strcat('run',num2str(r),':', num2str(numel(find(response==1))/numel(find(trialtm>0)))))
            CorrResp{d}(r,:) = response;        % Correct/incorrect
             
            % Find trial indices for different conditions
            SC{d}(r,:) = find(~cellfun(@isempty,strfind(trialprop(:,CueCol),'S'))); % Spatial Cue
            CC{d}(r,:) = find(~cellfun(@isempty,strfind(trialprop(:,CueCol),'C'))); % Central Cue
            NC{d}(r,:) = find(~cellfun(@isempty,strfind(trialprop(:,CueCol),'N'))); % No cue
            IT{d}(r,:) = find(~cellfun(@isempty,strfind(trialprop(:,TarCol),'I'))); % Incongruent targets
            CT{d}(r,:) = find(~cellfun(@isempty,strfind(trialprop(:,TarCol),'C'))); % Congruent targets
            
            SC_CT{d}(r,:) = find(~cellfun(@isempty,strfind(trialprop(:,CueCol),'S')) & ~cellfun(@isempty,strfind(trialprop(:,TarCol),'C')));
            CC_CT{d}(r,:) = find(~cellfun(@isempty,strfind(trialprop(:,CueCol),'C')) & ~cellfun(@isempty,strfind(trialprop(:,TarCol),'C')));
            NC_CT{d}(r,:) = find(~cellfun(@isempty,strfind(trialprop(:,CueCol),'N')) & ~cellfun(@isempty,strfind(trialprop(:,TarCol),'C')));
            SC_IT{d}(r,:) = find(~cellfun(@isempty,strfind(trialprop(:,CueCol),'S')) & ~cellfun(@isempty,strfind(trialprop(:,TarCol),'I')));
            CC_IT{d}(r,:) = find(~cellfun(@isempty,strfind(trialprop(:,CueCol),'C')) & ~cellfun(@isempty,strfind(trialprop(:,TarCol),'I')));
            NC_IT{d}(r,:) = find(~cellfun(@isempty,strfind(trialprop(:,CueCol),'N')) & ~cellfun(@isempty,strfind(trialprop(:,TarCol),'I')));
            
            % Find Spatial cue & Congruent trials, for subject exclusion
            SC_CT_store = horzcat(SC_CT_store,response(SC_CT{d}(r,:)));
            
            % Deal with bad trials %
            if RemWrongResp                                             % If remove wrong responses
                IncorrTrials = find(CorrResp{d}(r,:) == 0);             % Find incorrect trial indices
            else
                IncorrTrials = [];
            end
            RTs2short = find(RT{d}(r,:) < RTless);                      % Find trials with short response times (<RTless)
            Trials2Rem{d}{r} = [IncorrTrials,RTs2short];                % Combine bad trial indices (short RT and incorrect) and remove bad trials
            if ~isempty(Trials2Rem{d}{r})                               % If bad trials exist
                Trials2Rem{d}{r} = unique(Trials2Rem{d}{r});            % Remove duplicate indices
            end
            
            % Store RTs for ANT scores
            Conditions = {"SC","CC","NC","IT","CT","SC_CT","CC_CT","NC_CT","SC_IT","CC_IT","NC_IT"}; % Labels for conditions
            for cc = 1:numel(Conditions)                                                             % Loop through conditions
                RT_store = eval(Conditions{1,cc});                                                   % Store indices for the condition
                RT_idx = RT_store{d}(r,:);                                                           % Extract indices for this day/run
                RT_idx(ismember(RT_idx,Trials2Rem{d}{r})) = [];                                % Remove bad trials from indices
                RTs.(Conditions{cc}){d}=horzcat(RTs.(Conditions{cc}){d},trialtm(RT_idx));            % Store RTs in single matrix
                RT_Subj.(Conditions{cc})(d) = nanmean(RTs.(Conditions{cc}){d});
            end
  
            % Generate text files with condition start times for GLM
            if TxtGenReg
                
                % Go to path (local or cluster)
%                 switch LocOrClust
%                     case 'loc'
%                         cd(strcat('/Users/gurariy/Documents/Gena/Research/IPad/MR_Data/',SubjID{1,s},'/day',num2str(d),'/fMRI_BH')); % Path to behavioral fMRI files
%                     case 'clu'
%                         cd(strcat('/Users/gurariy/MountPoint/iPadStudy/',SubjID{1,s},'/day',num2str(d),'/preprocessing'));
%                 end
                cd(SaveFolder)
                
                % Set labels
                Conditions = {"SC","CC","NC","IT","CT"};      % Labels for conditions
                StartTime = {"Trial","Target"; "cue","tar"};  % {labels for variable; labels for .txt}
                
                % Loop through conditions
                for c = 1:numel(Conditions)
                    
                    % Loop through cue start and target start times
                    for t = 1:size(StartTime,1)
                        
                        % On the first run, open .txt file
                        if r ==1
                            StrName{c,t} = strcat(Conditions{1,c},"_",StartTime{2,t},".txt");
                            testxt{c,t} = fopen(StrName{c,t},'w');
                        end
                        
                        % Store cell array in temp variable
                        LoopStore = eval(Conditions{1,c});
                        
                        % Store trial indices
                        TrialIdxs = LoopStore{d}(r,:);
                        
                        % Remove indices of bad trials
                        TrialIdxs(ismember(LoopStore{d}(r,:),Trials2Rem{d}{r})) = [];
                        
                        % Write start times to .txt
                        TimeStore = eval(strcat(StartTime{1,t},"Start"));                  % Store start times in temp variable (for cue or target)
                        toprint = TimeStore{d}(r,TrialIdxs);                               % Grab only good trials
                        fprintf(testxt{c,t},'%s \n',strjoin(strsplit(num2str(toprint))));  % write to text file 
                    end % t
                end % c
                
            end % if TxtGen
            
            if TxtGenDur
                
%                 switch LocOrClust
%                     case 'loc'
%                         cd(strcat('/Users/gurariy/Documents/Gena/Research/IPad/MR_Data/',SubjID{1,s},'/day',num2str(d),'/fMRI_BH')); % Path to behavioral fMRI files
%                     case 'clu'
%                         cd(strcat('/Users/gurariy/MountPoint/iPadStudy/',SubjID{1,s},'/day',num2str(d),'/preprocessing'));
%                 end
                cd(SaveFolder)
                
                Conditions = {"NC","CC","SC"};
                
                % Loop through conditions
                for c = 1:numel(Conditions)
                    
                    % On the first run, open .txt file
                    if r ==1
                        StrName1{c,1} = strcat(Conditions{1,c},"_dm.txt");
                        testxt1{c,1} = fopen(StrName1{c,1},'w');
                    end
                    
                    % Get start times of good trials
                    LoopStore = eval(Conditions{1,c});                                    % Store cell array in temp variable
                    TrialIdxs = LoopStore{d}(r,:);                                        % Store trial indices
                    TrialIdxs(ismember(LoopStore{d}(r,:),Trials2Rem{d}{r})) = [];         % Remove indices of bad trials
                    toprint = TrialStart{d}(r,TrialIdxs);                                 % Grab start times of good trials
                    
                    %if ~isempty(toprint)
                        % Create strings with start time & duration. A*B:C A=start time, B = amplitude modulation, C = duration
                        for dm = 1:numel(toprint)
                            dmstore{1,dm} = strcat(num2str(toprint(dm)),DurMod{1,1},num2str([CuePres+cell2mat(trialprop(TrialIdxs(dm),CTI))]/1000));
                        end
                        
                        % Write start times & durations to .txt
                        if exist('dmstore')
                            fprintf(testxt1{c,1},'%s ',dmstore{:}); % write to text file
                        else
                            fprintf(testxt1{c,1},'%s ',''); % write to text file
                        end
                    %end
                    fprintf(testxt1{c,1},'\n');
                    clear dmstore
                end % c
               
                % Close .txt files on the last condition of last run
                if c == numel(Conditions) && r == Nruns
                    fclose('all');
                end
            end
            
            % Store start times for executive control conditions (congruent/incongruent)
            %if TxtGenDur
                Conditions = {"IT","CT"};
                for c = 1:numel(Conditions)
                    LoopStore = eval(Conditions{1,c});                                    % Store cell array in temp variable
                    TrialIdxs = LoopStore{d}(r,:);                                        % Store trial indices
                    TrialIdxs(ismember(LoopStore{d}(r,:),Trials2Rem{d}{r})) = [];         % Remove indices of bad trials
                    toprint = TargetStart{d}(r,TrialIdxs);                                % Grab only good trials
                    toprintRT = RT{d}(r,TrialIdxs);
                    ECstore{c}{r,:} = toprint;
                    ECstoreRT{c}{r,:} = toprintRT;
                end
            %end
            
            % clear variables
            clear response trialprop trialtm RTs2short IncorrTrials TimeIdxs toprint TimeStore LoopStore TrialIdxs SC_CT
            
        end % NumRuns
        
        % Generate .txt files for congruent/incongruent conditions start times & duration
        if TxtGenDur
            
%             switch LocOrClust
%                 case 'loc'
%                     cd(strcat('/Users/gurariy/Documents/Gena/Research/IPad/MR_Data/',SubjID{1,s},'/day',num2str(d),'/fMRI_BH')); % Path to behavioral fMRI files
%                 case 'clu'
%                     cd(strcat('/Users/gurariy/MountPoint/iPadStudy/',SubjID{1,s},'/day',num2str(d),'/preprocessing'));
%             end
            cd(SaveFolder)
            
            % Figure out duration to use for distractor filtering glm
            RTmu = nanmean(RT{d}(:));       % Average RT across all runs
            RTmin = min(RT{d}(:));          % Minimum RT across all runs
            MinMuDiff = (RTmu-RTmin)/2;     % Take 1/2 of difference
            ECdur = RTmin + MinMuDiff;      % Duration to use
            if ECdur < .5                   % Make sure it is at least .5
                ECdur = .5;
            end
            
            % Generate .txt files for congruent/incongruent conditions 
            Conditions = {"IT","CT"};
            for c = 1:numel(Conditions)
                StrName2 = strcat(Conditions{1,c},"_dm.txt");
                testxt2 = fopen(StrName2,'w');
                for r = 1:size(ECstore{c},1)
                    for dm = 1:numel(ECstore{c}{r})
                        %dmstore2{1,dm} = strcat(num2str(ECstore{1,c}{r,1}(1,dm)),DurMod{1,1},num2str(round(ECdur,1)));
                        dmstore2{1,dm} = strcat(num2str(ECstore{1,c}{r,1}(1,dm)),DurMod{1,1},num2str(round(ECstoreRT{1,c}{r,1}(1,dm),1)))
                    end
                    
                    if ~(isempty(ECstore{1,c}{r,1}))
                        fprintf(testxt2,'%s ',dmstore2{:}); % write to text file  
                    else
                        fprintf(testxt2,'%s ',' '); 
                    end
                    fprintf(testxt2,'\n');
                    clear dmstore2
                end
                fclose('all');
            end 
        end % TxtGenDur
        clear ECstore
    end % scan days 


   if saveGroupData
    cd(groupDir)
    save(SubjID{1,s} + "_Data.mat", 'RT_Subj', 'AccuracyStore', 'RTs');
   % save([strcat(SubjID{1,s}), '_Data.mat'], 'RT_Subj', 'AccuracyStore', 'RTs')
    %writetable(RTs_table, [SubjID{1} '_RTs.xlsx']);
    %writecell(AccuracyStore, [SubjID{1} 'Accuracy.xlsx'])
   end
   clear RT_Subj
end 
