% main script for ANT fMRI experiment, modeled after Fan et al. 2005 & Madhyastha et al, 2015
% Structure of Data Array:
% trialprop: -------------------------------------------------------------------
%			 | cue type| targ locn | targ dir| flankers | flank dir| CTI | ITI | cueValidity | cueLocation
%            |         |           |         |          |          |           |V (valid)    | for spatial cues:
%			 | Spatial,| Top,      | Left,   |Congruent,| Right,   | see vars  |I (invalid)  | T or B (top/bottom)
%			 | Center, | Bottom	   | Right   |			| Left	   | below	   |C (central)  | for central/no cues:
%	  	     | None	   |     	   | 		 |Incongr.  |		   |		   |N (none)     | C or N (placeholder)
%
% Adapted from ANTmain
% Written by Adam Greenberg, UWM/Psych(Neuro)
% August, 2018
%

% ** Updated by Ethan Duwell on 2-2-24 to address some Windows-specific issues
% Updated by Michele Maslowski on 6/12/2024 to update it for fMRI use


% Updated to current version by Ethan Duwell, MCW
% August 2024
% Updated to include the ability to include invalid cue conditions
%
% Adam's original timing:
% mean of 9sec/trial x 36 trials = 324 sec, + 12 sec final fix + 10 sec initial fix = 346 sec = 5:46 mins
%
%%


clear mex
clear all
more off
diary on
sca
clc;

% Welcome banner
antWelcome

today = datestr(now,'yyyy-mm-dd_HH-MM'); % get current time/date stamp for filename
disp(" ");
disp(today);
disp(" ");

customRes = 0;

% EJD added section below to automate path setting
% Note: this assumes a particular directory structure..
%
% get location of the "main" directory (directory housing this script..)
startDir=pwd; % save initial path..
current_version = 'ANTmain3.m'; % will need to update with versioning..
mlab_dir = fileparts(which(current_version));
% cd to it..
cd(mlab_dir);
% enter data dir and save absolute path..
cd('../Data');
directory = pwd;
% return to code directory..
cd(mlab_dir);

AssertOpenGL;
HideCursor;
%ListenChar(0);
KbName('UnifyKeyNames');
%FlushEvents('keyDown');			% Pre-load and pre-allocate
comp = Screen('Computer');		% get some info. on computer running this script
% [ret, cname] = system('hostname');
Screen('Preference', 'TextRenderer', 1);    % better (slower) text renderer

% Removes the blue screen flash and minimize extraneous warnings.
oldVisualDebugLevel = Screen('Preference', 'VisualDebugLevel', 3);
oldSupressAllWarnings = Screen('Preference', 'SuppressAllWarnings', 1);
Screen('Preference', 'SkipSyncTests', 1);

% Get the screen numbers
%-------------------------------------------------------------------------------
% (EJD EDITED 2-2-24 to adapt to Umfleet windows machine)
% (It appears as though on this machine ?and perhaps all windows machines? the
% external display is the largest value in the screen() output instead of the minimum)
screens = Screen('Screens'); % get the screen #
screenNumber =  max(screens); % switched from min to display on the 2nd screen

%EJD: added to skip sync tests

Screen('Preference', 'SkipSyncTests', 1);
Screen('Preference','SuppressAllWarnings', 1);

% User selects experiment type and hemifield in gui
ExpType = questdlg('Experiment Type','Experiment','Practice','Main','Practice');
whichHemifeild = questdlg('Choose Hemifield','Hemifield','Left','Right','Center','Left');% ejd updated text strings so hemifield is spelled correctly..
whichHemifeild = lower(whichHemifeild(1));
disp(" ");
disp("Experiment type set to:")
disp(ExpType);
disp(" ");
disp("Hemifield set to:")
disp(whichHemifeild);

% User enters a subject id code via a gui.. (EJD added 8/15/24)
subjID = inputdlg({'SubjectID'},'Please enter subject ID', [1 50]);
subjID=subjID{1,1};
disp(" ");
disp("Subject ID set to:")
disp(subjID);


HideCursor;
ListenChar(2);  % stop throwing characters to matlab windows
switch ExpType
    case 'Practice'
        NumTrials = 24;
        %NumTrials = 60;
    case 'Main'
        %NumTrials = 72;
        NumTrials = 84;
end

percentVal=0.60; % Specify the percentage (as decimal value from 0->1) of spatial cues that will be valid
disp(" ");
disp("Proportion of spatial cues that will be valid:");
disp(num2str(percentVal));
room = 'fMRI';

%%%%% SET THESE OPTIONS %%%%%%
% whichHemifeild = 'R';  % Options: Left ['L'], Right ['R'], or Center ['C']
 whichExp = 'fmri';    % Options: behavioral 'b' (will use left/right keys) or 'f' (will use 2 & 3 keys)
 whichExp = lower(whichExp(1));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Use the external screen if avaliable
% if comp.windows==1
% screenNumber = max(screens); % ejd added
% else
% screenNumber = min(screens);
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%=
% degree = 29.703;=        %pixels per degree (at 58cm)
degree = 90; %90
lettersize = round(.6*degree);
Qspacing = round(1.06*degree);

%%%%%% Original values %%%%%%%
% arrspacing = round(.05*degree);
% headwid = round(.06*degree);
% bodyhi = round(headwid/3);
% fixwid = bodyhi*2;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%% Updated values %%%%%%%
arrspacing = round(.05*degree)*4;
headwid = round(.6*degree); % .4
bodywid = round(.3*degree); % .5
bodyhi = round(round(.2*degree)/4);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% arrspacing = round(.05*degree);
% headwid = round(.12*degree); %.1
% bodywid = round(.8*degree); %.8
% bodyhi = round(headwid/4);  %/3

Qsize = round(.1*degree);
fixdim = Qsize;
fixwid = round(round(.06*degree)/3)*2;

%fixwid = bodyhi*2;
black = BlackIndex(screenNumber);
white = WhiteIndex(screenNumber);
grey = [128 128 128];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% choose appropriate resolution
% critstimdisplay=100;  %frame duration in ms
rwidth = 1024;	% requested resolution width
rheight = 768;	% requested resolution height
if customRes
res1 = NearestResolution(screenNumber,rwidth,rheight);
oldres = SetResolution(screenNumber,res1);
end

%seed random number generator
rng('default');
rng("shuffle");
%randn('state',sum(100*clock));
%savedState = randn('state');
s1 = 0;

olddir = pwd;
cd(directory);
% build fileid string: (EJD Updated 8/15/24)
% make it descriptive of this session
% include timestamp to ensure uniqueness
fileid = strcat(directory,'/','ANTv3_sID_',subjID,"_hf_",whichHemifeild,"_expVer_",whichExp,"_",ExpType,"_", today,'.mat');
save('-v7',fileid,'today','room');

try

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% create onscreen window
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%[window, screenrect] = PsychImaging('OpenWindow', screenNumber, grey); % EJD COMMENTED/replaced with section below 8/14/24
% EJD ADDED 8/14/24 to deal with his screen setup on tron while debugging/updating:
%===============================================================================
% ejd attempt to rescale whole double screen into a single screen..
screenrect = Screen('Rect',0);	% get the size of the display screen
if strcmp(comp.machineName,'tron')
  scale_f = 0.5;
  screenrect(3) = screenrect(3) * scale_f;
end
%window = PsychImaging('OpenWindow', screenNumber, grey, screenrect);
[window, screenrect] = PsychImaging('OpenWindow', screenNumber, grey);% Open generic on-screen window
%===============================================================================

ifi = Screen('GetFlipInterval', window);
% Set up alpha-blending for smooth (anti-aliased) lines
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% determine locations for stimuli
[x,y]=RectCenter(screenrect);
xorig = x;
switch whichHemifeild
  case 'l'
    x = x/2;
  case 'r'
    x = x+(x/2);
  case 'c'
    x = x;
end


% cue locations
Qc_x = xorig-round(.08*degree); % center cue x-locn
Qc_y = y-round(.06*degree); % center cue y-locn
Qt_x = x-round(.08*degree); % top cue x-locn
Qt_y = y-Qspacing-round(.06*degree); % top cue y-locn
Qb_x = x-round(.08*degree); % bottom cue x-locn
Qb_y = y+Qspacing-round(.06*degree); % bottom cue y-locn

% now find locations of arrows
xarrow(3) = x;    % x-location of center arrow
xarrow(2) = xarrow(3) - (arrspacing+headwid+bodywid);
xarrow(1) = xarrow(2) - (arrspacing+headwid+bodywid);
xarrow(4) = xarrow(3) + (arrspacing+headwid+bodywid);
xarrow(5) = xarrow(4) + (arrspacing+headwid+bodywid);

% now fixation cross
fixx = [-fixdim fixdim 0 0];
fixy = [0 0 -fixdim fixdim];
fixCoords = [fixx; fixy];

% Screen('FillRect',window,black, screenrect);
Screen(window, 'TextFont', 'Monaco');
% Screen(window, 'TextSize', 12);
Screen(window,'DrawText','Loading stimuli...',xorig-125,y,white);
Screen('Flip', window, GetSecs+ifi);
WaitSecs(.5);

%generate trial structure
cd(olddir);

disp(" ");
disp("Generating trial structure..");
disp(" ");
[trialprop] = ANTtrials2(NumTrials,percentVal); % EJD updated 8/14/24

%save into .mat file
cd(directory);
save(fileid,'trialprop','-append');

% Begin Task
cd(olddir);
[trialtm, trialch, response, blockstart, blockstop]=ANTblocks3(window, trialprop, black, xarrow, x, y, Qc_x, Qc_y, Qt_x, Qt_y, Qb_x, Qb_y, fixCoords, fixwid, headwid, bodywid, bodyhi, ifi, screenNumber,xorig,whichExp);

%save things & finish up
cd(directory);
save(fileid,'trialtm','trialch','response','blockstart','blockstop','-append');
Screen('CloseAll');

%SetResolution(screenNumber,oldres); % ejd replaced with if-statement below..
if customRes==1
  SetResolution(screenNumber,oldres);
end
ListenChar(0);
ShowCursor;
cd(olddir);

try

% Compute/Display Info from this run onto the command line:
%-------------------------------------------------------------------------------
accVal=100*(numel(find(response))/NumTrials);
nTrialsTotal=size(trialprop,1);

centralCueIdx=cell2mat(trialprop(:,1))=='C';
noCueIdx=cell2mat(trialprop(:,1))=='N';
spatialCueIdx=cell2mat(trialprop(:,1))=='S';
invldIdx=cell2mat(trialprop(:,8))=='I';
validIdx=cell2mat(trialprop(:,8))=='V';

congrConIdx=cell2mat(trialprop(:,4))=='C';
incongrConIdx=cell2mat(trialprop(:,4))=='I';

SCcongrConIdx=congrConIdx.*spatialCueIdx;
SCincongrConIdx=incongrConIdx.*spatialCueIdx;

validSCcongrConIdx=SCcongrConIdx.*validIdx;
validSCincongrConIdx=SCincongrConIdx.*validIdx;
invalidSCcongrConIdx=SCcongrConIdx.*invldIdx;
invalidSCincongrConIdx=SCincongrConIdx.*invldIdx;

scValidIdx=spatialCueIdx.*validIdx;
scInvalidIdx=spatialCueIdx.*invldIdx;

nCongrCon=sum(congrConIdx);
nIncongrCon=sum(incongrConIdx);

nSCcongrCon=sum(SCcongrConIdx);
nSCincongrCon=sum(SCincongrConIdx);

nValidSCcongrCon=sum(validSCcongrConIdx);
nValidSCincongrCon=sum(validSCincongrConIdx);
nInvalidSCcongrCon=sum(invalidSCcongrConIdx);
nInvalidSCincongrCon=sum(invalidSCincongrConIdx);

nSpatial=sum(spatialCueIdx);
nSpatialVld=sum(scValidIdx);
nSpatialInvld=sum(scInvalidIdx);
percentSpatial=((sum(cell2mat(trialprop(:,1))=='S'))/size(trialprop,1))*100;

pctSpatialVld=(nSpatialVld/(nSpatialInvld+nSpatialVld))*100;
pctSpatialInvld=(nSpatialInvld/(nSpatialInvld+nSpatialVld))*100;
nCentral=sum(centralCueIdx);
nNoCue=sum(noCueIdx);
pctNoCue=(nNoCue/nTrialsTotal)*100;
pctCentral=(nCentral/nTrialsTotal)*100;

disp(" ");
disp("=======================================================================");
disp("Info from this ANT run:");
disp("=======================================================================");
disp(strcat("Subject's accuracy: ",num2str(accVal)));
disp(strcat("Total number of trials: ",num2str(nTrialsTotal)));
disp(strcat("Total number of congruent trials:",num2str(nCongrCon)));
disp(strcat("Total number of incongruent trials:",num2str(nIncongrCon)));
disp(" ");

disp("Response Buttons:");
disp("------------------");
disp(trialch);
disp("------------------");
disp("Response Times:");
disp("------------------");
disp(trialtm);
disp("------------------");
disp("Response Correctness:");
disp("------------------");
disp(response);
disp("------------------");

disp(" ");
disp("Spatial-Cue-Specific-Info:");
disp(strcat("Total number of spatial cue trials: ",num2str(nSpatial)));
disp(strcat("Total number of valid spatial cue trials: ",num2str(nSpatialVld)));
disp(strcat("Total number of invalid spatial cue trials: ",num2str(nSpatialInvld)));
disp(strcat("Total number of congruent spatial cue trials: ",num2str(nSCcongrCon)));
disp(strcat("Total number of incongruent spatial cue trials: ",num2str(nSCincongrCon)));
disp(strcat("Total number of valid congruent spatial cue trials: ",num2str(nValidSCcongrCon)));
disp(strcat("Total number of valid incongruent spatial cue trials: ",num2str(nValidSCincongrCon)));
disp(strcat("Total number of invalid congruent spatial cue trials: ",num2str(nInvalidSCcongrCon)));
disp(strcat("Total number of invalid incongruent spatial cue trials: ",num2str(nInvalidSCincongrCon)));
disp(strcat("Percentage of trials with spatial cues: ",num2str(percentSpatial)));
disp(strcat("Percentage of spatial cues that were valid: ",num2str(pctSpatialVld)));
disp(strcat("Percentage of spatial cues that were invalid: ",num2str(pctSpatialInvld)));

disp(" ");
disp("Central-Cue-Specific-Info:");
disp(strcat("Total number of central cue trials: ",num2str(nCentral)));
disp(strcat("Percentage of trials with central cues: ",num2str(pctCentral)));

disp(" ");
disp("No-Cue-Specific-Info:");
disp(strcat("Total number of trials with no cue: ",num2str(nNoCue)));
disp(strcat("Percentage of trials with central cues: ",num2str(pctNoCue)));

disp(" ");
disp("Full Trial Structure:");
disp(cell2table(trialprop));
disp("=======================================================================");
disp(" ");
%-------------------------------------------------------------------------------
catch

end
diary off

catch
	  Screen('CloseAll');
    Screen('Preference', 'VisualDebugLevel', oldVisualDebugLevel);
    Screen('Preference', 'SuppressAllWarnings', oldSupressAllWarnings);
  if customRes
	   SetResolution(screenNumber,oldres);
  end
  ListenChar(0);
	ShowCursor;
	cd(olddir);
    fprintf('We''ve hit an error.\n');
    % psychrethrow(psychlasterror);
    psychlasterror
	diary off
    fprintf('This last text never prints.\n');
end

cd(startDir); % return to starting path..
fidChar=char(fileid);
movefile('diary',strcat(fidChar(1:end-4),'_diary'));
clear;% clear up workspace