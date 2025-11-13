function create_line_art(input_dir, output_dir,sqrFilterSize)
    % Check if input and output directories exist
    if ~exist(input_dir, 'dir')
        error('Input directory does not exist.');
    end
    if ~exist(output_dir, 'dir')
        mkdir(output_dir);
    end

    % Get a list of all .jpeg files in the input directory
    images = dir(fullfile(input_dir, '*.jpeg'));

    if isempty(images)
        error('No .jpeg images found in the input directory.');
    end

    % Process each image
    for i = 1:length(images)
        % Load image
        img_path = fullfile(input_dir, images(i).name);
        img = imread(img_path);

        % Convert to grayscale
        gray_img = rgb2gray(img);

        % Detect edges to create line art
        line_art = edge(gray_img, 'Canny');

        % Invert the binary image to make lines black and background white
        line_art = ~line_art;

        %sqrFilterSize=5;
        f = ones(sqrFilterSize);
        line_art = filter2(f, line_art);
        % Rescale to range from 0 to 1
        minVal=min(min(line_art));
        maxVal=max(max(line_art));
        line_art=line_art-minVal;
        line_art=(line_art./maxVal).^3;
        line_art=abs(line_art-(max(max(line_art)))); % invert back
        line_art=rescale(line_art,0,255);
        % Convert logical to uint8 for saving
        line_art = uint8(line_art);

        % Save the processed image in the output directory
        [~, name, ~] = fileparts(images(i).name);
        output_path = fullfile(output_dir, [name, '_line_art.jpeg']);
        imwrite(line_art, output_path);
    end
end

