function regressor_table = make_regressor_table(motion_file_path, method_name, outd)

if iscell(motion_file_path), motion_file_path = motion_file_path{1}; end

if ~exist(motion_file_path, 'file'); disp([motion_file_path ' does not exist!']); regressor_table = []; return; end

% extract task name
task_name = extract_taskname(motion_file_path);

% extract subid
subid = regexp(motion_file_path, '(?<=/)\d{6}(?=/)', 'match');
subid = subid{1};

% Define output directory
output_dir = fullfile(outd, subid, 'EVs');
if ~exist(output_dir, 'dir'), mkdir(output_dir); end

switch method_name

    case 'fd_mag_convolved'

        % get hrf model and derivatives
        load('./hrf_models/hrf_model.mat');
        load('./hrf_models/hrf_model_dx1.mat');
        load('./hrf_models/hrf_model_dx2.mat');

        fd_convolved = round(convolve_fd(motion_file_path, hrf_mod, 0.5),3);
        fd_convolved1 = round(convolve_fd(motion_file_path, hrf_mod_dx1, 0.5),3);
        fd_convolved2 = round(convolve_fd(motion_file_path, hrf_mod_dx2, 0.5),3);

        regressor_table = table('Size', [length(fd_convolved), 3], ...
            'VariableNames', {'fd', 'fd_dx1', 'fd_dx2'}, ...
            'VariableTypes', {'double', 'double', 'double'});

        regressor_table.fd = fd_convolved';
        regressor_table.fd_dx1 = fd_convolved1';
        regressor_table.fd_dx2 = fd_convolved2';

        outp = fullfile(output_dir, 'fd_mag_convolved.txt');
        writetable(regressor_table, outp, 'Delimiter', ' ');

    case 'fd_mag_convolved_w_motion_params'

        % load motion parameters
        motion_params = readtable(motion_file_path);

        % get hrf model and derivatives
        load('./hrf_models/hrf_model.mat');
        load('./hrf_models/hrf_model_dx1.mat');
        load('./hrf_models/hrf_model_dx2.mat');

        fd_convolved = round(convolve_fd(motion_file_path, hrf_mod, 0.5),3);
        fd_convolved1 = round(convolve_fd(motion_file_path, hrf_mod_dx1, 0.5),3);
        fd_convolved2 = round(convolve_fd(motion_file_path, hrf_mod_dx2, 0.5),3);

        regressor_table = table('Size', [length(fd_convolved), 15], ...
            'VariableNames', {'fd', 'fd_dx1', 'fd_dx2', 'trans_x', 'trans_y', 'trans_z', 'rot_x', 'rot_y', 'rot_z', 'trans_dx', 'trans_dy', 'trans_dz', 'rot_dx', 'rot_dy', 'rot_dz'}, ...
            'VariableTypes', {'double', 'double', 'double', 'double', 'double', 'double', 'double', 'double', 'double', 'double', 'double', 'double', 'double', 'double', 'double'});


        regressor_table.fd = fd_convolved';
        regressor_table.fd_dx1 = fd_convolved1';
        regressor_table.fd_dx2 = fd_convolved2';
        regressor_table(:,4:end) = motion_params;

        outp = fullfile(output_dir, 'fd_mag_convolved_w_motion_params.txt');
        writetable(regressor_table, outp, 'Delimiter', ' ');

    case 'motion_params_only'

        % load motion parameters
        motion_params = readtable(motion_file_path);

        regressor_table = table('Size', [size(motion_params,1), 12], ...
            'VariableNames', {'trans_x', 'trans_y', 'trans_z', 'rot_x', 'rot_y', 'rot_z', 'trans_dx', 'trans_dy', 'trans_dz', 'rot_dx', 'rot_dy', 'rot_dz'}, ...
            'VariableTypes', {'double', 'double', 'double', 'double', 'double', 'double', 'double', 'double', 'double', 'double', 'double', 'double'});

        regressor_table(:,1:end) = motion_params;

        outp = fullfile(output_dir, 'motion_params_only.txt');
        writetable(regressor_table, outp, 'Delimiter', ' ');

    otherwise

        disp(['Do not recognize method of name ' method_name '. Cannot create regression table for ' subid '...'])
        regressor_table = [];

end
end
