function   [T_final,s_final,info] = Point2DCalibration(Ts,ImPs,s0,optimiser)

% Ts: 3-by-4-by-n
% ImPs: n-by-2

if nargin<4, optimiser='lmls'; end

n = size(Ts,3);
ns = length(s0);

%% convert to 3D points
Ps = [ImPs,ones(n,1)]';  % all attach ones

% initilisation - [Rx,Ry,Rz,tx,ty,tz,p0x,p0y,p0z,sx,sy]
x0 = [zeros(1,9),s0];

lb = [];
ub = [];
nonlcon = [];
A=[]; b=[]; Aeq=[]; beq=[];

options = [];
options.Display = 'iter';
options.MaxFunEvals = inf;
options.MaxIter = inf;
switch  optimiser
    case  'lmls'
        options.Algorithm = 'levenberg-marquardt';
        % options.LargeScale = 'on';
        options.FinDiffType = 'central';
        options.DiffMaxChange = 1e4;
        options.DiffMinChange = 1e-8;
        options.TolX = 1e-8;
        options.TolFun = 1e-10;
        x_opt = lsqnonlin(@(x) obj_PointCalibration(x),x0,lb,ub,options);
        
    case 'simplex'
        x_opt = fminsearch(@(x) obj_PointCalibration_scalar(x),x0,options);
        
    case  'pattern'
        x_opt = patternsearch(@obj_PointCalibration_scalar,x0,A,b,Aeq,beq,lb,ub,nonlcon,options);
end

T_final = [LeftRotationMatrix(x_opt(1:3)),x_opt(4:6)'];
s_final = x_opt(10:end);
if  nargout>=4
    info.Ps = Ps;
    info.x_opt = x_opt;
end

    function  f = obj_PointCalibration(x)
        
        T_calib = [LeftRotationMatrix(x(1:3)),x(4:6)'];
        p = x(7:9)';
        s = diag([x(10:end),ones(1,3-ns)]);  %
        
        f = zeros(n,1);
        for  i = 1:n
            % R1 = Ts(:,1:3,i)*R*s; t1 = Ts(:,1:3,i)*t+Ts(:,4,i); f(i) = sqrt(sum(( R1*Ps(:,i)+t1 - p ).^2));
            f(i) = sqrt(sum((convertImage2Global(Ps(:,i),s,T_calib,Ts(:,:,i))-p).^2));
        end
        
    end

    function  f = obj_PointCalibration_scalar(x)
        
        
        T_calib = [LeftRotationMatrix(x(1:3)),x(4:6)'];
        p = x(7:9)';
        s = diag([x(10:end),ones(1,3-ns)]);  %
        
        f = zeros(n,1);
        for  i = 1:n
            % R1 = Ts(:,1:3,i)*R*s; t1 = Ts(:,1:3,i)*t+Ts(:,4,i); f(i) = sqrt(sum(( R1*Ps(:,i)+t1 - p ).^2));
            f(i) = sum((convertImage2Global(Ps(:,i),s,T_calib,Ts(:,:,i))-p).^2);
        end
        f = sqrt(mean(f));
        
    end

%% left-hand rotation
    function  R = LeftRotationMatrix(ang)        
        % Construct the rotation matrix from angles    
        % x-axis
        xsn = sin(ang(1));
        xcn = cos(ang(1));
        xrm = [1,0,0;0,xcn,-xsn;0,xsn,xcn;];
        % y-axis
        ysn = sin(ang(2));
        ycn = cos(ang(2));
        yrm = [ycn,0,ysn;0,1,0;-ysn,0,ycn;];
        % z-axis
        zsn = sin(ang(3));
        zcn = cos(ang(3));
        zrm = [zcn,-zsn,0;zsn,zcn,0;0,0,1;];
        
        R = zrm*yrm*xrm;
        
    end

end   % - function