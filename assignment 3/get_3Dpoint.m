function X = get_3Dpoint(x1,x2,P1,P2)

    %% 2Dpoint1 = x and 2Dpoint2 = x'
    % P1 = camera calibration matrix 1 ie it's camera center is origin
    
    c1 = cam_center(P1);
    %c2 = cam_center(P2);
    c1 = [c1;1];
    P1_inv = pinv(P1);
    
    %% if size of both the points is not 3x1 then make it 3x1
    if(size(x1,1) ~= 3)
        x1 = [x1;1];
    end
    if(size(x2,1) ~= 3)
        x2 = [x2;1];
    end
    %% now the camera center 
    % X(?) = P+ x + ?C
    % P' * X(?) = x'
    % ? = (x' - (P' * P+ * x))/(P'C)
    % from this equation we can get the corresponding 3D point
    lambda = ((x2 - (P2*P1_inv*x1))./(P2*c1));
    lambda(isnan(lambda(:,1)),:)=[];
    lambda = mean(lambda);
    X = P1_inv*x1 + lambda*c1;
    X = X/X(4);
    X = [X(1);X(2);X(3)];
end