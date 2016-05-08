function [output1,output2] = epipoles(Fmatrix)
    %% here we can get 
    output1 = 0;
    output2 = 0;
    if(size(Fmatrix,1) ~= 3 || size(Fmatrix,2) ~= 3)
        fprintf('error\n');
    else
        %% output 1 correspond to e and output2 correspond to e'
        [~,~,V] = svd(Fmatrix);
        output1 = V(:,3);
        [~,~,V] = svd(Fmatrix');
        output2 = V(:,3);
    end
end
