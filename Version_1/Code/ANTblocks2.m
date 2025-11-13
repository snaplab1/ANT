function [trialtm trialch response blockstart blockstop]=ANTblocks2(window, trialprop, black, xarrow, x, y, Qc_x, Qc_y, Qt_x, Qt_y, Qb_x, Qb_y, fixCoords, fixwid, headwid, bodywid, bodyhi, ifi, screenNumber,xorig,whichExp)

%
% ANTblocks1.m
%
% function for ANT fMRI experiment: executes a block of trials
%
% Structure of Data Array:
%
%			 | cue type| targ locn | targ dir| flankers | flank dir| CTI | ITI |
% trialprop: -------------------------------------------------------------------
%			 | Spatial,| Top,      | Left,   |Congruent,| Right,   | see vars  |
%			 | Center, | Bottom	   | Right   |			| Left	   | below	   |
%	  		 | None	   |     	   | 		 |Incongr.  |		   |		   |
%			 -------------------------------------------------------------------
%
% Written by Adam Greenberg, UWM/Psych(Neuro)
% August, 2018

Screen('Preference', 'SkipSyncTests', 1);
%[xorig,yorig]=RectCenter(screenrect);
white = WhiteIndex(screenNumber);
grey = [128 128 128];

try
    trigger = KbName("=+");
    switch whichExp
        case 'f'
            left = KbName("2@");
            right = KbName("3#");
        case 'b'
            %left = KbName("LeftArrow");
            %right = KbName("RightArrow");
            left = KbName("z");
            right = KbName("m");
    end

catch
    trigger = KbName('=+');
    switch whichExp
        case 'f'
            left = KbName('2@');
            right = KbName('3#');
        case 'b'
            %trigger = KbName('=+');
           % left = KbName('LeftArrow');
           % right = KbName('RightArrow');
            left = KbName('z');
            right = KbName('m');
    end
end

% WaitSecs(1);
%FlushEvents('keyDown');
Screen(window,'DrawText','Welcome to the experiment.  Press SPACE key to begin.',125,300,white);
Screen('Flip', window, GetSecs+ifi);
[kb_dev_id kb_names] = GetKeyboardIndices;                       % Get keyboard ID
KbQueueCreate(kb_dev_id(1));                                     % Create Queue
KbQueueStart(kb_dev_id(1));                                      % Start listening for keypresses
KbQueueWait(kb_dev_id(1));                                       % Wait for keypress to continue
KbQueueRelease(kb_dev_id(1));


% FlushEvents('keyDown');
%KbWait; %move forward after key is pressed
blockstart = GetSecs;
ttime = blockstart;

for tnum = 1:length(trialprop)

	%0) initial fixation
	if tnum==1
		Screen('DrawLines', window, fixCoords, fixwid, black, [xorig y], 2);
		ttime = ttime+2;
		Screen('Flip',window);
	end;

	%1) draw fixation cross & cue (if present)
	switch trialprop{tnum,1}
		case 'C'
			Screen('DrawText', window, '*', Qc_x, Qc_y, black);
		case 'S'
			Screen('DrawLines', window, fixCoords, fixwid, black, [xorig y], 2);
			if trialprop{tnum,2}=='T'
				Screen('DrawText', window, '*', Qt_x, Qt_y, black);
			else
				Screen('DrawText', window, '*',Qb_x, Qb_y, black);
			end;
		case 'N'
			Screen('DrawLines', window, fixCoords, fixwid, black, [xorig y], 2);
	end;
		[VBLTimestamp(tnum,1)] = Screen('Flip',window,ttime);

	%2) 200ms later, draw fix only
	ttime = ttime+0.200;
    %ttime = ttime+2;
	Screen('DrawLines', window, fixCoords, fixwid, black, [xorig y], 2);
	[VBLTimestamp(tnum,2)] = Screen('Flip', window, ttime, 1); % don't clear

	%3) add target to fix after CTI
	ttime = ttime + trialprop{tnum,6}/1000;
	targtime = ttime;
	if trialprop{tnum,3}=='R'
		td=180;
	else
		td = 0;
	end;
	if trialprop{tnum,5}=='R'
		fd=180;
	else
		fd=0;
	end;

	if trialprop{tnum,2}=='T'
		yarrow=Qt_y;
	else
		yarrow=Qb_y;
	end;
	draw_arrow([xarrow(3) yarrow],td,black,[headwid headwid bodywid bodyhi],window)
	draw_arrow([xarrow(1),yarrow],fd,black,[headwid,headwid,bodywid,bodyhi],window)
	draw_arrow([xarrow(2),yarrow],fd,black,[headwid,headwid,bodywid,bodyhi],window)
	draw_arrow([xarrow(4),yarrow],fd,black,[headwid,headwid,bodywid,bodyhi],window)
	draw_arrow([xarrow(5),yarrow],fd,black,[headwid,headwid,bodywid,bodyhi],window)
	[VBLTimestamp(tnum,3)] = Screen('Flip', window, ttime);

    %wait for response (max 2000ms)
	keyIsDown = 0;
    while ~keyIsDown && (GetSecs-(ttime))<(2.000-.5*ifi)
        [keyIsDown, secs, keyCode, deltaSecs] = KbCheck(-1);
		if any(keyCode(trigger))
			keyIsDown = 0;
		end;
    end;

	%4) fix only to wait out ITI
	Screen('DrawLines', window, fixCoords, fixwid, black, [xorig y], 2);
    if keyIsDown
        [VBLTimestamp(tnum,4)] = Screen('Flip', window, []); % flip now (after keypress)
        % check to see if correct button was pressed
        if trialprop{tnum,3}=='L'
			if any(keyCode(left))     % correct key pressed
				response(tnum) = 1;   % correct
			else
				response(tnum) = 0;   % incorrect
			end;
        else
            if any(keyCode(right))     % correct key pressed
				response(tnum) = 1;   % correct
			else
				response(tnum) = 0;   % incorrect
			end;
        end;
        trialtm(tnum) = secs-targtime; % record RT of response
        tmpch = KbName(keyCode);
        trialch(tnum) = tmpch(1); % record button pressed
    else    % timeout (no response)
        [VBLTimestamp(tnum,4)] = Screen('Flip', window, ttime+2-.5*ifi);  % flip 2000ms after target appearance
	end;
	ttime = ttime + 2 + trialprop{tnum,7}/1000;
end;
%on final trial, wait an extra 15 seconds
% while (GetSecs-ttime)<12
% end;
blockstop = GetSecs;
%save('-mat7-binary','/Users/gurariy/Desktop/TimeStamp.m','VBLTimestamp','blockstop','blockstart','ttime');



