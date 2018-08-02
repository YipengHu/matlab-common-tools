function R = determineR_inv(q)

q0=q(1); qx=q(2); qy=q(3); qz=q(4);

m00 = q0^2 + qx^2 - qy^2 - qz^2;
m01 = 2*(qx*qy-q0*qz);
m02 = 2*(qx*qz+q0*qy);

m10 = 2*(qx*qy+q0*qz);
m11 = q0^2 - qx^2 + qy^2 - qz^2;
m12 = 2*(qy*qz-q0*qx);

m20 = 2*(qx*qz-q0*qy);
m21 = 2*(qy*qz+q0*qx);
m22 = q0^2 - qx^2 - qy^2 + qz^2;

R = [m00,m10,m20; m01,m11,m21; m02,m12,m22;];


