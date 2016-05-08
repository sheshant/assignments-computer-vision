function angle = get_angle(m)
% here we are taknig m = 1x2

    angle = 0;
    if(size(m,1) ~= 1 || size(m,2) ~= 2)
        fprintf('Error in angle\n');
    else
        if(m(1) >= 0 && m(2) >= 0)
            % first quadrant
            angle = atand(m(2)/m(1));
        elseif(m(1) < 0 && m(2) >= 0)
            % second quadrant
            angle = 180 + atand(m(2)/m(1));
        elseif(m(1) < 0 && m(2) < 0)
            % third quadrant
            angle = 180 + atand(m(2)/m(1));
        elseif(m(1) >= 0 && m(2) < 0)
            % fourth quadrant
            angle = 360 + atand(m(2)/m(1));
        else
            fprintf('Error in angle2  (%f,%f)\n',m(1),m(2));
        end
    end  
end
