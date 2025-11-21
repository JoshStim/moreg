function fd_convolved = convolve_fd(motion_path, hrf, thresh)

if ~exist(motion_path, 'file')
    disp([motion_path ' does not exist!'])
    fd_convolved = [];
    return
end

fd = get_fd(motion_path);
fd_thresh = zeros(1, length(fd));
fd_thresh(fd >= thresh) = fd(fd >= thresh);

fd_convolved = conv(fd_thresh, hrf, 'full');
fd_convolved = fd_convolved(1:length(fd));

end

