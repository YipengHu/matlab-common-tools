function  p = convertImage2Global(p0, t_scaling, t_calib, t_tracking)
if any(numel(t_scaling)==[1,2])
    t_scaling = diag([t_scaling(:);ones(3-numel(t_scaling),1)]);
end
R1 = t_tracking(:,1:3)*t_calib(:,1:3)*t_scaling;
t1 = t_tracking(:,1:3)*t_calib(:,4) + t_tracking(:,4);
p = SpatialTransform(p0,[R1,t1]);

function  p = SpatialTransform(p,T)
% t: 3-by-4
% p: 3-by-np
p = T(:,1:3)*p + T(:,4)*ones(1,size(p,2));