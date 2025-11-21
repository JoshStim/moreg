function fd = get_fd(regressor_path)

%% Load motion data
movement = table2array(readtable(regressor_path));

%% extract subid from motion path
%[~,filename,~] = fileparts(regressor_path);
subid = regressor_path(37:42);
taskname = regressor_path(end-37:end-24);

%% Calculate framewise displacement
% convert deg to mm
movement(:,4:6) = (movement(:,4:6) * pi/180) * 50;
% calculate diff for rotations
movement(:,10:12) = [zeros(1,3); diff(movement(:,10:12),[],1)];
fd = sum(abs(movement(:,7:end)),2);

end

