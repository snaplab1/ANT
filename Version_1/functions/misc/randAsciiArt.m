function randAsciiArt(asciiMatPath,pauseDuration)
% This function reads in a .mat output file of ascii art produced by
% convrtAllImz2Ascii.m, selects a random ascii art index, and displays
% it on the command line for your amusement..

% load in the contents of the .mat file to a struct called data
data=load(asciiMatPath);

% get the array of ascii data (should be a variable called "asciiImgArray")
asciiArray=data.asciiImgArray;

% Select a random ascii art from asciiArray
%rng("shuffle"); %scramble/randomize the rng
nASCIIs=size(asciiArray,2); % get the total number of ascii art img indexes in asciiArray
ranIdx=randi(nASCIIs); % select a random index..
randASCII=asciiArray{1,ranIdx};

% Display the ASCII art
%cellfun(@(line) disp(line), randASCII);

% Display the adjusted ASCII art with pause
for i = 1:length(randASCII)
    disp(randASCII{i});
    pause(pauseDuration); % Pause for specified duration between lines
end

end