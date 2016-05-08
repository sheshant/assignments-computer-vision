function output = FundamentalMatrix(match1,match2)

    %% so here we begin our algorithm for finding the number of match points
    % we will start with generating matrix
    % equation x2xf11 + x2yf12 + x2f13 + y2xf21 + y2yf22 + y2f23 + xf31 + yf32 + f33 = 0.
    A = [];
    for i = 1:size(match1,1)
        x  = match1(i,1);
        x2 = match2(i,1);
        y  = match1(i,2);
        y2 = match2(i,2);
        A = [A;[x2*x x2*y x2 y2*x y2*y y2 x y 1]];
    end
    
    %% now the svd part 
    %we will  the SVD of A. The unit singular vector corresponding to the
    % smallest singular value is the solucion h. A = UDV' with D diagonal with
    % positive entries, arranged in descending order down the diagonal, then h
    % is the last column of V.
    [~,~,v] = svd(A);
    Fmatrix = reshape(v(:,9),3,3)';
    
    %% next part we have to make output singular
    % for that we will get the svd and make the last element of the S matrix 0
    [U,S,V] = svd(Fmatrix);
    S(3,3) = 0;
    output = U*S*V';
end
