function [camera1,camera2] = get_Camera(Fmatrix)
    % this function will return camera calibration matrix for both the
    % cameras
    camera1 =  [1 0 0 0;
                0 1 0 0;
                0 0 1 0];
    camera2 = [];
    %% we are assuming that the camera calibration matrix is identity matrix
    % P' = [M | m]; where e' = m and e = M?1  m.
    [~,e2] = epipoles(Fmatrix);
    for i = 1:3
        c = cross(e2,Fmatrix(:,i));
        camera2 = [camera2 c];
    end
    camera2 = [camera2 e2];
end
