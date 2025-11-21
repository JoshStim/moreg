function make_regressor_table_batch(motion_file_paths, method_name, outp)

if iscell(motion_file_paths), motion_file_paths = motion_file_paths{1}; end

% Open the file for reading
fid = fopen(motion_file_paths, 'r');

% Check if the file was opened successfully
if fid == -1
    error('Cannot open file: %s', motion_file_paths);
end

% Loop through each line in the text file
while ~feof(fid)
    % Read one line (one file path) from the file
    filePath = fgetl(fid);

    % Check if the file path is valid (not empty and not an error)
    if ischar(filePath)
        % Perform your function here, e.g., display the file path
        disp(['Making motion regressor table for ', filePath]);
        make_regressor_table(filePath, method_name, outp);
    end
end

% Close the file
fclose(fid);

end
