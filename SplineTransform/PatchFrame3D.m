function   faces = PatchFrame3D(sz)

fi = [1,3,5,2; 
    2,5,8,6; 
    8,7,4,6; 
    7,3,1,4; 
    2,6,4,1; 
    3,7,8,5];  % clockwise convention

faces = zeros(prod(sz-1)*6,4);
ct = 0;
for  yy = 1:sz(1)-1,
    for  xx = 1:sz(2)-1,
        for  zz = 1:sz(3)-1,
            % for each cube
            % eight nodes indices
            nn = [xx,yy,zz;xx+1,yy,zz;xx,yy+1,zz;xx,yy,zz+1;
                xx+1,yy+1,zz;xx+1,yy,zz+1;xx,yy+1,zz+1;xx+1,yy+1,zz+1;];
            ni = sub2ind(sz,nn(:,2),nn(:,1),nn(:,3));
            ct = ct+1;
            % six faces
            faces((ct-1)*6+1:ct*6,:) = ni(fi);
        end
    end
end