function output = normalize(a)
% a is a 3X1 vector here
    a = double(a);
    total = sum(a);
    if(total ~= 0)
        if(size(a,1) == 3 && size(a,2) == 1)
            output = inv(total)*[a(1);a(2);a(3)];
        elseif(size(a,2) == 3 && size(a,1) == 1)
            output = inv(total)*[a(1) a(2) a(3)];
        else
            fprintf('error in normalize\n');
            output = [];
        end
    else
        output = a;
    end
    
end