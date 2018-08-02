function  [status,T,Q] = getTransformation(s)
    
% Yipeng Hu - 2012-2014

T = [eye(3);zeros(1,3)];  % 4-by-3 transformation matrix
Q = zeros(4,1);  % original quaternion data
    
% send and get message
fprintf(s,'TX 0001');
reply = fscanf(s,'%c');

status = length(reply)>=49 & ~strcmp(reply(5:8),'MISS');
if  status,
    Q = sscanf(reply(5:28),'%d')./1e4;
    T(4,:) = sscanf(reply(29:49),'%d')./1e2;
    T(1:3,:) = determineR_inv(Q);
    StatusMsg = 'Tracking';
else
    StatusMsg = 'Missing';
end
% fprintf('Quaternions: %f; %f; %f; %f; \nTraslations: %f; %f; %f; \nStatus:%s \n\n', Q, T(4,:), StatusMsg)
fprintf('Rotation: %f, %f, %f; %f, %f, %f; %f, %f, %f; \nTraslations: %f; %f; %f; \nStatus:%s \n\n', T(1,:),T(2,:),T(3,:), T(4,:), StatusMsg)

% child function here:
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