function matrix = get_matrix(image)
%% this function will take colour image and return a matrix of angles

    if(size(image,3) ~= 3)
        fprintf('error in get_matrix\n');
        matrix = [];
    else
        row = size(image,1);
        col = size(image,2);
        matrix = zeros(row,col);
        for i = 1:row
            for j = 1:col
                
%% from here the colour detction begins 
% note the first channel gives red then green then blue and in x y z also x
% represent red then green then blue
% how this it will do first we need to convert rgb to xyz 

                vect = rgb2xyz(double(image(i,j,1)),double(image(i,j,2)),double(image(i,j,3)));
                % got it now normalize the vector 
                vect = normalize(vect);
                if(sum(vect) ~= 0)
                    % make sure it is 1 and 2
                    matrix(i,j) = get_angle([vect(1)-inv(3) vect(2)-inv(3)]);
                end
                
            end
        end
    end
end

                
                