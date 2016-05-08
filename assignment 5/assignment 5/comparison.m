function matrix = comparison(k1,k2)
    
    row = size(k1,1);
    col = size(k2,2);
    matrix = zeros(size(k1));
    if(size(k1) ~= size(k2))
        fprintf('error in comparison\n');
    else
        for i = 1:row
            for j = 1:col
                %% comparison begins for principal curvature 
                m1 = k2(i,j);
                m2 = k1(i,j);
                if(m1 < 0 && m2 < 0)
                    matrix(i,j) = 1;
                elseif(m1 < 0 && m2 == 0)
                    matrix(i,j) = 2;
                elseif(m1 < 0 && m2 > 0)
                    matrix(i,j) = 3;
                elseif(m1 == 0 && m2 < 0)
                    matrix(i,j) = 4;
                elseif(m1 == 0 && m2 == 0)
                    matrix(i,j) = 5;
                elseif(m1 == 0 && m2 > 0)
                    matrix(i,j) = 6;
                elseif(m1 > 0 && m2 < 0)
                    matrix(i,j) = 7;
                elseif(m1 > 0 && m2 == 0)
                    matrix(i,j) = 8;
                elseif(m1 > 0 && m2 > 0)
                    matrix(i,j) = 9;
                end
            end
        end
    end
end
