function val = bilinear(image,i,j)

    i1 = floor(i);
    i2 = i1+1;
    j1 = floor(j);
    j2 = j1+1;
    
    a11 = image(i1,j1);
    a12 = image(i1,j2);
    a21 = image(i2,j1);
    a22 = image(i2,j2);
    
    val = ((a11*(i2-i) + a21*(i-i1))*(j2-j)) + ((a12*(i2-i) + a22*(i-i1))*(j-j1));
end