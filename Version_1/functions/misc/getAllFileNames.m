function fileNames = getAllFileNames(directory)
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
end