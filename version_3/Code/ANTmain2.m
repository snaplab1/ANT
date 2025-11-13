%main script for ANT fMRI experiment, modeled after Fan et al. 2005 & Madhyastha et al, 2015
% Structure of Data Array:=
%
%			 | cue type| targ locn | targ dir| flankers | flank dir| CTI | ITI |
% trialprop: -------------------------------------------------------------------
%			 | Spatial,| Top,      | Left,   |Congruent,| Right,   | see vars  |
%			 | Center, | Bottom	   | Right   |			| Left	   | below	   |
%	  		 | None	   |     	   | 		 |Incongr.  |		   |		   |
%			 -------------------------------------------------------------------
%
% Written by Adam Greenberg, UWM/Psych(Neuro)====
% August, 2018==
% ** Updated by Ethan Duwell on 2-2-24 to address some Windows-specific issues
% ** Updated by Michele Maslowski on 6/12/2024 to ensure it can function on
% the second screen in the scanner

% mean of 9sec/trial x 36 trials = 324 sec, + 12 sec final fix + 10 sec initial fix = 346 sec = 5:46 mins
%
%%
clear mex
clear all
more off
diary on
sca
clc;

customRes = 0;

%%
% whichExp = questdlg('Choose Experiment','Experiment','Behavioral','fMRI','Behavioral');
% whichExp = lower(whichExp(1));
whichHemifeild = questdlg('Choose Hemifield','Hemifield','Left','Right','Center','Left');% ejd updated text strings so hemifield is spelled correctly..
whichHemifeild = lower(whichHemifeild(1));
spatialCueLoc = 'c'; % options c for center or h for l/r hemifield
NumTrials = 36;
%%

%directory = '/Users/ggurariy/Dropbox/CI_Testing/fMRI/ANT/Data/';
%directory = 'C:\Users\local_umfleetlab\Desktop\SCD_Testing\fMRI\ANT\Data'; % ejd added
directory = '/Users/Shared/ANT/ANT_update_8_14_24/fMRI/ANT/Data/';


if exist(directory) == 0
   cd('../Data');
   directory = pwd;
   cd('../Code');
end

room = 'fMRI';

%if strcmp(comp.machineName,'BME-TBRC-12341')
%    directory = '/Users/ggurariy/Dropbox/CI_Testing/fMRI/ANT/Data/';
%    room = 'GenaImacMCW';
%else
%   directory = '/Users/snap-lab-g/Dropbox/CI_Testing/fMRI/ANT/Data/';
%   room = 'SoundChamber';
%end


%%%%% SET THESE OPTIONS %%%%%%
% whichHemifeild = 'R';  % Options: Left ['L'], Right ['R'], or Center ['C']
 whichExp = 'fmri';    % Options: behavioral 'b' (will use left/right keys) or 'f' (will use 2 & 3 keys)
 whichExp = lower(whichExp(1));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

today = datestr(now,'yyyy-mm-dd_HH-MM'); % get current time/date stamp for filename
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

% ejd added if statment below so the "skipsynctests" call is only run on Mac machines
% I did this because, because this move was only required originally to get around
% errors that arise from timing issues particular to Macs..
%... after doing this however.. Ethan discovered that newer windows machines with
% Intel Iris Graphics have a similar issue that is openly admitted as "unsolvable"
% in "help SyncTrouble".. so.. I put this back the way it was..
% FAIR WARNING THOUGH: sync tests are off..

Screen('Preference', 'SkipSyncTests', 1);
% Get the screen numbers
screens = Screen('Screens');
% Use the external screen if avaliable
screenNumber = max(screens);
% Get the screen numbers
%-------------------------------------------------------------------------------
% (EJD EDITED 2-2-24 to adapt to Umfleet windows machine)
% (It appears as though on this machine ?and perhaps all windows machines? the
% external display is the largest value in the screen() output instead of the minimum)
% screens = Screen('Screens');
% % Use the external screen if avaliable
% if comp.windows==1
% screenNumber = max(screens); % ejd added
% else
% screenNumber = min(screens);
% end
%-------------------------------------------------------------------------------

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

% res1=Screen('Resolutions', screenNumber); %list of all resolutions possible
% res2=find([res1(:).width]==rwidth & [res1(:).height]==rheight);
% res3=unique([res1(res2).hz]);
%
% for r=1:length(res3)
%     rmod(r)=mod(critstimdisplay,1000*(1/res3(r)));  % match frame rate to value stored in critstimdisplay
% end;
% [x,rmin]=min(rmod); % best frequency match
% res4=find([res1(:).width]==rwidth & [res1(:).height]==rheight & [res1(:).hz]==res3(rmin)); % best freq. & size
% [x,rmax]=max([res1(res4).pixelSize]);   % largest pixelSize value of good resolutions
% newres = res1(res4(rmax));
% oldResolution=Screen('Resolution', screenNumber, newres.width, newres.height, newres.hz, newres.pixelSize); %set it
% screenrect = Screen(screenNumber,'Rect');	% get the size of the display screen

%%% get some info. on computer running this script
% if strcmp(comp.machineName,'psy-agreenb-l2')	% this is the fMRI laptop
%     directory = '/Users/snap-lab-g/Desktop/CochlearImplant/ANT/Data/';
%    % directory = '/Users/snap-lab-g/Dropbox/CI_Testing/ANT/Data/';
% 	room = '3Tpremier';
% elseif strcmp(comp.machineName,'psy-agreenb-r1')	% this is the sound booth Mac Mini
%     directory = '/Users/snap-lab-g/Dropbox/iPadStudy/ANT/Data/';
% 	room = '3Tpremier';
% elseif strcmp(comp.machineName,'psy-agreenb-r4')
%     directory = '/Users/gurariy/Google Drive/CI_Grant/ANT/Data/';
% 	  room = 'GenaImac';
% elseif strcmp(comp.machineName,'BME-TBRC-12341')
%     directory = '/Users/ggurariy/Google Drive/CI_Grant/ANT/Data/';
%     room = 'GenaImacMCW';
% elseif strcmp(comp.machineName,'psy-agreenb-r5')
%     %directory = '/Users/snap-lab-g/Desktop/ANT/Data/';
%     directory = '/Users/snap-lab-g/Dropbox/CI_Testing/ANT/Data';
%     room = 'GenaImacMCW';
% else
% %    fprintf('******************************\nYou''re not on a known machine!\n******************************\n');
% %    return;
% end




%seed random number generator
randn('state',sum(100*clock));
savedState = randn('state');
s1 = 0;

olddir = pwd;
cd(directory);
fileid = strcat(directory,'/',today,'.mat');


save(fileid,'today','room');

try

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% create onscreen window
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% window = Screen('OpenWindow',screenNumber,[],screenrect);	% Open window
[window, screenrect] = PsychImaging('OpenWindow', screenNumber, grey);
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
[trialprop] = ANTtrials1(NumTrials);
%save into .mat file
cd(directory);

save(fileid,'trialprop','-append');

%get ready to start (moved to ANTblocks1)
% Screen(window,'DrawText','Welcome to the experiment.  Press ENTER to start.',125,300,white);
% Screen('Flip', window, GetSecs+ifi);

% GO!!!
cd(olddir);
[trialtm trialch response blockstart blockstop]=ANTblocks2(window, trialprop, black, xarrow, x, y, Qc_x, Qc_y, Qt_x, Qt_y, Qb_x, Qb_y, fixCoords, fixwid, headwid, bodywid, bodyhi, ifi, screenNumber,xorig,whichExp);

%save things & finish up
cd(directory);


save(fileid,'trialtm','trialch','response','blockstart','blockstop','-append');



Screen('CloseAll');

%SetResolution(screenNumber,oldres); % ejd replaced with if-statement below..
if customRes==1
  SetResolution(screenNumber,oldres);
end

% Screen('Resolution', screenNumber, oldResolution.width, oldResolution.height, oldResolution.hz, oldResolution.pixelSize);	% restore resolution
ShowCursor;
cd(olddir);
diary off

catch
	Screen('CloseAll');
    Screen('Preference', 'VisualDebugLevel', oldVisualDebugLevel);
    Screen('Preference', 'SuppressAllWarnings', oldSupressAllWarnings);
	if customRes
  SetResolution(screenNumber,oldres);
  end
	ShowCursor;
	cd(olddir);
    fprintf('We''ve hit an error.\n');
    % psychrethrow(psychlasterror);
    psychlasterror
	diary off
    fprintf('This last text never prints.\n');
end;

try
    numel(find(response))/NumTrials
catch

end
% draw_arrow([500,500],180,[0,0,0],[15,15,100,5])
%draw_arrow([xarrow(1),500],180,[0,0,0],[headwid,headwid,bodywid,bodyhi])


