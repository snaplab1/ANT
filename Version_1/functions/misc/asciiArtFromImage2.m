function asciiArtFromImage2(imagePath, height, offset, pauseDuration)
    % This function calls the jp2a command to create ASCII art from an image.
    % It allows specifying the height of the ASCII output, the input image path,
    % an offset to shift the ASCII image laterally, and a pause duration between lines.
    %
    % Parameters:
    %   imagePath - Path to the input image
    %   height - Desired height of the ASCII output
    %   offset - Number of spaces to offset the ASCII image laterally
    %   pauseDuration - Duration of pause between lines (in seconds)

    % Validate input
    if nargin < 4
        error('You must provide imagePath, height, offset, and pauseDuration as arguments.');
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
    
    % Display the adjusted ASCII art with pause
    for i = 1:length(adjustedLines)
        disp(adjustedLines{i});
        pause(pauseDuration); % Pause for specified duration between lines
    end
end