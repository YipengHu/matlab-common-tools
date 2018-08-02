function   [probe,image,pts] = calibrateUS3D(dirname,vdims_out,slice_size,plotflag)


if  nargin<3 || isempty(slice_size), slice_size = [];      end
if  nargin<4 || isempty(plotflag),   plotflag = true;      end

%% read in the files
if  ~any(strcmp(dirname(end),{'\','/'})), dirname=[dirname,'\']; end
list_file = dir([dirname,'\*.nii']);
filenames = {list_file.name};

%% load data - erase mode if always off
% [vol,par_rec,track_Rs,track_ts] = igitkUltrasonix.loadDataUS3D(dirname,slice_size,false);
% [vol,par_rec] = igitkUltrasonix.loadDataUS3D(dirname,slice_size,false);
[vol,par_rec,slice_size] = igitkUltrasonix.loadFilesUS3D(filenames,dirname,slice_size,'motor_position.txt',false);
if  isempty(vol), probe=[]; image=[]; pts=[]; return;  end


%% interactivey get the probe points
pts = CalibPointGUI(vol,par_rec);


%% get image coordinates only
[image.cxi,image.cyi,image.czi] = igitkUltrasonix.getCoordinates(slice_size,par_rec,vdims_out);


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
probe.Origin = sphereObj.Origin;
probe.Radius = sphereObj.Radius;

% calculate the axis
t0 = (max(par_rec(2,:))+min(par_rec(2,:))) / 2;
probe.Axis = [0,cos(t0),sin(t0)];



if  plotflag,
    
    % generate the composite probe geometry
    % semi-sphere
    MinPhi = 0;
    MaxPhi = pi/2;
    sphereObj = igitkSpatialObject.Sphere(sphereObj.Origin,probe.Axis,sphereObj.Radius,MinPhi,MaxPhi);
    % cylinder
    Length = 50; % mm
    dOrigin = sphereObj.Origin-[0,0,Length]*sphereObj.Axes;
    cylinder = igitkSpatialObject.Cylinder(dOrigin,probe.Axis,sphereObj.Radius,Length);
    cap = igitkSpatialObject.Ellipse(dOrigin,sphereObj.Axes,sphereObj.Radius);
    TRUSProbe = cylinder + sphereObj + cap;
    % TRUSProbe.getSurfaceMesh;
    sp = 5;
    [cyi,cxi,czi] = ndgrid(image.cyi(1:sp:end),image.cxi(1:sp:end),image.czi(1:sp:end));  % for plot
    
    % plot
    TRUSProbe.plotAxes;
    hold on; plot3(cyi(:),cxi(:),czi(:),'black.');
    % fit points
    hold on; plot3(cx,cy,cz,'.');
    
end
