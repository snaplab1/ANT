function asciiImgArray = convrtAllImz2Ascii(imgDir,height, offset,tag,saveMat,outMatFile)
% This function converts all images within a directory into ascii art
% depictions of the images using the unix shell program jp2a and saves
% the output ascii arts in a cell array output saved within a .mat file.
% This .mat file can then be read in by other programs and the ascii art
% can be displayed without jp2a as a dependency.
%
% Input Parameters:
% imgDir     - "path/to/directory/containing/your/images"
% height     - Desired height of the ASCII output
% offset     - Number of spaces to offset the ASCII image laterally
% tag        - a substring pattern tag to indicate which images in the imgDir
%              you want processed (e.g. for all jpegs you could do: ".jpeg")
% saveMat    - 1 indicates you want to save an output .mat file 0=don't save a .mat
% outMatFile - output file name for .mat output (if desired.. if not set to
%              "" or any other string placeholder
% Output Parameters:
% asciiImgArray - cell array output (1xN) variable containing each of the N
% number of output asciis
%
% Dependencies:
% 1) This function depends on the unix shell program jp2a being installed:
% To install jp2a on Linux(Debian/Ubuntu/Mint) run:
% sudo apt install jp2a
% To install jp2a via brew on a Mac:
% brew install jp2a
%
% 2) This function also depends on the following other matlab functions
% being present on your path:
%   - asciiFrmImz2mat.m
%
% Created by EJ Duwell, PhD. (2/23/2024)

% Save start path location
startPath=pwd;

% go to image directory
cd(imgDir);

% get list of all the .jpeg files present and read them in
[imFiles] = getAllFileNamesTag_octave(imgDir,tag);

% preallocate output cell array
asciiImgArray=cell(1,size(imFiles,1));

% Loop through the image paths in imFiles
% Run each through asciiFrmImz2mat
% Store the outputs in outputArray
for ii = 1:size(asciiImgArray,2)
    imagePath=imFiles{ii,1};
    asciiOut = asciiFrmImz2mat(imagePath, height, offset); % feed image into asciiFrmImz2mat.m
    asciiImgArray{1,ii}=asciiOut; % store ascii art output in outputArray
end

% Save output to .mat file if desired
if saveMat==1
save(outMatFile,"asciiImgArray",'-mat');
end

% Return to starting path location/wrap up..
cd(startPath);

end
