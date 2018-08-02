function   [TRUSProbe,pts] = calibrateUS3D(dirname, slice_size, plotflag)


if  nargin<2 || isempty(slice_size), slice_size = [];      end
if  nargin<3 || isempty(plotflag),   plotflag = true;      end


% load data - erase mode if always off
% [vol,par_rec,track_Rs,track_ts] = igitkUltrasonix.loadDataUS3D(dirname,slice_size,false);
[vol,par_rec] = igitkUltrasonix.loadDataUS3D(dirname,slice_size,false);
if  isempty(vol), pts=[]; return;  end


%% interactivey get the probe points
pts = CalibPointGUI(vol,par_rec);


%% fit a sphere to the points - in mm
% convert to 3d points
if  any(diff(par_rec(1,:))>sqrt(eps)), % single precision
    fprintf('WARNING:The scalings may not be consistent over slices - use the first one\n.'); 
end
% pts(:,1:2) = pts(:,1:2).*par_rec(1);
% px = pts(:,1).*par_rec(1);
pr = pts(:,2).*par_rec(1);
pt = acos(pts(:,3));

cx = pts(:,1).*par_rec(1);
cy = pr.*cos(pt);
cz = pr.*sin(pt);

% find the probe position - "middle slice" 
sphereObj = igitkSpatialObject.Sphere.fit(cx,cy,cz);
% sphereObj.getSurfaceMesh; hold on; plot3(cx,cy,cz,'.'); 

% calculate the axis
t0 = (max(par_rec(2,:))+min(par_rec(2,:))) / 2;
Axis = [0,cos(t0),sin(t0)];

% generate the composite probe geometry
MinPhi = 0;
MaxPhi = pi/2;
hsphere = igitkSpatialObject.Sphere(sphereObj.Origin,Axis,sphereObj.Radius,MinPhi,MaxPhi);
Length = 50; % mm
dOrigin = sphereObj.Origin-[0,0,Length]*hsphere.Axes;
cylinder = igitkSpatialObject.Cylinder(dOrigin,Axis,sphereObj.Radius,Length);
cap = igitkSpatialObject.Ellipse(dOrigin,Axis,sphereObj.Radius);
TRUSProbe = cylinder + hsphere + cap;


if  plotflag,
    TRUSProbe.plotAxes;
    % TRUSProbe.getSurfaceMesh;
    hold on; plot3(cx,cy,cz,'.'); 
end
