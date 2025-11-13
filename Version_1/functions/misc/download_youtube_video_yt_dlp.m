function download_youtube_video_yt_dlp(url, output_file)
    % Check if yt-dlp is installed
    [status, ~] = system('which yt-dlp');
    if status != 0
        error('yt-dlp is not installed on your system. Please install it first.');
    end

    % Build the command string
    command = sprintf('yt-dlp -o "%s" "%s"', output_file, url);

    % Execute the command
    status = system(command);

    % Check if the download was successful
    if status == 0
        fprintf('Video downloaded successfully to %s\n', output_file);
    else
        error('Failed to download video. Please check the URL or output path.');
    end
end

