ReadME
================

## ANT

This repository contains the SNAP Lab’s code for the Attention Network
Test (ANT).

## Overview

ANT is a MATLAB based- project development for the Attention Network
test (ANT). This reposotory cintains stimuli presentation, for
behevioral and imaging studies, and analysis code.

## Dependencies

MATLAB version ?? Required Toolboxes: - PyschToolBox

## Outline

- ANT overview
- Stimuli Presentation code overview
- Changes for fMRI experiements
- Analysis

## ANT Overview

![Schematic of ANT (Fan
2005)](C:/Users/mmasl/Downloads/ANT_task_design.png) ANT conditions

| Condition | Description |
|:----------|:------------|
| NC        | No Cue      |
| CC        | Center Cue  |
| SC        | Spatial Cue |
| IT        | Incongruent |
| CT        | Congruent   |
| Alerting  | NC - CC     |
| Orienting | CC - SC     |
| Dist Filt | IT - CT     |

The cue is an asterisks. Depending on desired ANT version it can be
either valid or invalid.

## Stimulus Presentation Code

ANT version 1 -\> only valid cues - projects: - Chemobrain - CI fMRI -
iPad

subject button presses (m and z key)

ANT version 2 -\> valid/ invalid cues for behavioral - projects: -POCD

subject button presses (right/ left arrow keys) run ’ANTmain3

ANT version 3(fMRI) -\> valid/invalid cues for fMRI - Projects: - BMT
fMRI button box (2’s & 3’s)

Run in Command Window: - ANTmain3

Variable “trialprop” describes the presentation of each trial

| cue type | targ locn | targ dir | flankers    | flank dir | CTI       | ITI         | cueValidity          | cueLocation          |
|----------|-----------|----------|-------------|-----------|-----------|-------------|----------------------|----------------------|
| Spatial  | Top       | Left     | Congruent   | Right     | see below | V (valid)   | For spatial cues:    | T or B (top/bottom)  |
| Center   | Bottom    | Right    | Incongruent | Left      | see below | I (invalid) | For central/no cues: | C or N (placeholder) |
| None     | —         | —        | —           | —         | —         | —           | —                    | —                    |

**Hemifield options** Left, Right, Center

**Arrow spacing**

    {
      arrspacing = round(.05*degree)*4;
      headwid = round(.6*degree); % .4
      bodywid = round(.3*degree); % .5
      bodyhi = round(round(.2*degree)/4);
    }

**Screen resolution** 1024 x 768

## Data Directory Creation

make a ‘Data’ folder in the same file path as the code & function
folders each block is saved with he subject ID

Here are the variables saved in each .mat file:

- Block start time  
- Block end time  
- response = correct button press  
- Room  
- Date  
- trialch = button press  
- trialprop  
- trialtm = reaction times for each button press

## Random

the psychtoolBox command Screen -\> used for external displays

    {
      screens = Screen('Screens') # get screen number
      screenNumber = max(screens) # for windows the external display is max; IOS its the min of screens
    }

## Important for fMRI presentation

The imaging laptop connects via HDMI to the screen behind the MRI
scanner. Below I include some various things to remember when presenting
the ANT at the scanner.

1.  Button collection The button presses from box for a right handed
    individual index finger (2) arrows are left and middle finger (3)
    arrows are right.

<!-- -->

    {
    try
        trigger = KbName("=+");
        switch whichExp
            case 'f'
                left = KbName("2@");
                right = KbName("3#");
            case 'b'
                left = KbName("LeftArrow");
                right = KbName("RightArrow");
        end

    catch
        trigger = KbName('=+');
        switch whichExp
            case 'f'
                left = KbName('2@');
                right = KbName('3#');
            case 'b'
                trigger = KbName('=+');
                left = KbName('LeftArrow');
                right = KbName('RightArrow');
        end
    end
    }

2.  Trigger the trigger is a notication that the scanner is running. It
    appears as an “=+” sign. The ANT task will not start unless it
    recieves the trigger which aligns the task presentation with the
    slice timming of the images.

<!-- -->

    {
    % === Wait for Trigger === %
    KbQueueCreate(kb_dev_id(1),allowed_keys_trig) ;                  % Create Queue
    KbQueueStart(kb_dev_id(1));
    KbQueueWait(kb_dev_id(1));                                       % Wait for keypress to continue
    KbQueueFlush(kb_dev_id(1));
    KbQueueStop(kb_dev_id(1));
    KbQueueRelease(kb_dev_id(1));
    }

3.  Screen Mirroring This version of the screen setup is specific that
    the projector screen needs to be set on screen mirroring not
    extended display. The script will not run if its not on screen
    mirroring.

## Analysis Code

TrialTime is the orignal code written by Gena.

TrialTime_v4 updated by Michele to include valid/ in valid trials.
Exports excel files

Extract_raw_rts

important part of code were trialprop is compared to trialch

\`\`\` { % Compute behavior for i = 1:numel(response) if
strcmp(trialprop{i,TargDir},‘R’) && strcmp(trialch(i),‘R’) response(i) =
1; elseif strcmp(trialprop{i,TargDir},‘L’) && strcmp(trialch(i),‘L’)
response(i) = 1; end

                if strcmp(SubjID{s},'rr') && r>2
                    if strcmp(trialprop{i,TargDir},'R') && strcmp(trialch(i),'R')
                        response(i) = 1;
                    elseif strcmp(trialprop{i,TargDir},'L') && strcmp(trialch(i),'L')
                        response(i) = 1;
                    end
                end

} ’’’
