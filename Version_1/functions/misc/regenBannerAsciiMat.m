% This script calls convrtAllImz2Ascii to allow you to regenerate the .mat
% file containing the asciis you want to store..

%% Set your desired parameters..
%imgDir="/home/eduwell/SynologyDrive/SNAP/projects/ANT_update_8_14_24/functions/misc/asciiBannerIms";
imgDir="/home/eduwell/SynologyDrive/SNAP/projects/ANT_update_8_14_24/functions/misc/testOut4";

height=25;
%height=12;
offset=26;
tag=".jpeg";
saveMat=1;
outMatFile="asciiArt.mat";

%% Run the call to convrtAllImz2Ascii
asciiImgArray = convrtAllImz2Ascii(imgDir,height, offset,tag,saveMat,outMatFile);

% clean up workspace..
clear;
