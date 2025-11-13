% This is just a simple loop to spit out the character that the trigger is being interpreted as..

% Parameters
% ------------------------------------------------------------------------------
keyOfInterest="=+"; % set to what you think the trigger should be..
% ------------------------------------------------------------------------------

% Start Loop...
% ------------------------------------------------------------------------------
keyPressed=0; % initialize
exitCond=0; % initialize
while exitCond == 0

    % Check for button press
    [keyIsDown,block_vars.currentTime ,keyCode] = KbCheck;  % check button presses

   if keyIsDown == 1
     keyPressed=KbName(keyCode);
     disp(keyPressed);
     if keyPressed == keyOfInterest
     exitCond=1;
     disp("key of interest pressed:")
     disp(keyPressed)
     disp("exiting..")
     end
   end
end
% ------------------------------------------------------------------------------
