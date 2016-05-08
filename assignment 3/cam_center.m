function center = cam_center(camera)
    %% it will return the camera center 
    center = [];
    if(size(camera,1) ~= 3 && size(camera,2) ~= 4)
        fprintf('error in cam_center\n');
    else
        % camera center is -Minverse*P4
        m = [camera(:,1) camera(:,2) camera(:,3)];
        p4 = camera(:,4);
        center = -inv(m)*p4;
    end
end