function [Files, numFilesProcessed] = getAllFileNamesRec(directory,tag)
% Recursive function to get all file names in a directory and its subdirectories
files = dir(directory);
fileNames = {};
for i = 1:length(files)
    file = files(i);
    if file.isdir && ~strcmp(file.name, '.') && ~strcmp(file.name, '..')
        % If it's a directory, call the function recursively
        subDirectory = fullfile(directory, file.name);
        subFileNames = getAllFileNames(subDirectory);
        fileNames = [fileNames subFileNames];
    elseif ~file.isdir
        % If it's a file, add its full path and name to the list
        filePath = fullfile(directory, file.name);
        fileNames = [fileNames filePath];
    end
end


Files = {}; %initialize the image file list..
pattern = tag;
numFilesProcessed = 0; %initialize 
% Get the ones containing the tag..
for k = 1 : length(fileNames)
    
    % Get this filename.
    thisFileName = fileNames(k);
    % separate the filename away from its path and extension...
    %[~,name_only,exten] = fileparts(thisFileName); 
    %thisFileName = strcat(name_only,exten);

    % See if it contains our required pattern.
    if ~contains(thisFileName, pattern, 'IgnoreCase', true)
        % Skip this file because the filename does not contain the required pattern.
        continue;
    end
    % The pattern is in the filename if you get here, so do something with it.
    %fprintf('Now processing %s\n', thisFileName);

    Files = vertcat(Files,thisFileName);
    numFilesProcessed = numFilesProcessed + 1;	% For fun, let's keep track of how many files we processed.
end
end
