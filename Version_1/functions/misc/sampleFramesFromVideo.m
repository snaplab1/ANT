function sampleFramesFromVideo(videoFilePath, samplingRate, outputDir)
    % Check if the output directory exists, create it if it doesn't
    if ~exist(outputDir, 'dir')
        mkdir(outputDir);
    end

    % Construct the ffmpeg command
    ffmpegCommand = sprintf('ffmpeg -i %s -vf "fps=%d" %s/frame%%d.jpeg', videoFilePath, samplingRate, outputDir);

    % Execute the ffmpeg command to extract frames
    system(ffmpegCommand);
end

