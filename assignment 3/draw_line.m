function [X,Y] = draw_line(image,lines)
%% drawing begins 
%y = mx+c ie y = 
    X = [];
    Y = [];
    row = size(image,1);
    col = size(image,2);
    for j = 1:size(lines,1);
        l = lines(j,:);
        for i = 1:col
            y = (-l(3)-l(1)*i)/l(2);
            if (y > 1 && y < row)
                y = round(y);
                X = [X; y];
                Y = [Y; i];
            end
        end
        
    end
end
        
        
