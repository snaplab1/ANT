function asciiArtFromImage(imagePath, height, offset)
    % This function calls the jp2a command to create ASCII art from an image.
    % It allows specifying the height of the ASCII output, the input image path,
    % and an offset to shift the ASCII image laterally.
    %
    % Parameters:
    %   imagePath - Path to the input image
    %   height - Desired height of the ASCII output
    %   offset - Number of spaces to offset the ASCII image laterally

    % Validate input
    if nargin < 3
        error('You must provide imagePath, height, and offset as arguments.');
    end
    
    % Construct jp2a command with specified height
    commandStr = sprintf('jp2a --height=%d "%s"', height, imagePath);
    
    % Call jp2a and capture the output
    [status, cmdOut] = system(commandStr);
    
    % Check if the command was executed successfully
    if status ~= 0
        error('Failed to execute jp2a command. Make sure jp2a is installed and accessible.');
    end
    
    % Split the ASCII art into lines
    lines = strsplit(cmdOut, '\n');
    
    % Apply offset by adding spaces to the beginning of each line
    offsetSpaces = repmat(' ', 1, offset); % Create a string of spaces for the offset
    adjustedLines = cellfun(@(line) [offsetSpaces, line], lines, 'UniformOutput', false);
    
    % Display the adjusted ASCII art
    cellfun(@(line) disp(line), adjustedLines);
end