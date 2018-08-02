function    hAxes = generateTrackedObjects(hAxes,Config)


% load transformation
if  isfield(Config,'CalibFile') && ~isempty(Config.CalibFile) && exist(Config.CalibFile,'file'),
    Ts = load(Config.CalibFile);    
else  % default calibration    
    Ts.p2w_R = [0,0,1;0,1,0;1,0,0];
    Ts.p2w_t = [0,0,0];   
end



if  isfield(Config,'TrackedObjectFile') && ~isempty(Config.TrackedObjectFile) && exist(Config.TrackedObjectFile,'file'),
    
    s = load(Config.TrackedObjectFile);
    for  ii = 1:length(s.TrackedSurfaceObjects),
        switch  ii
            case  1,  % probe
                hAxes.Tracked(1) = patch('Parent',hAxes.Axes, ...
                    'Vertices',s.TrackedSurfaceObjects(ii).Vertices,'Faces',s.TrackedSurfaceObjects(ii).Faces, ...
                    'facecolor',[.7,.7,1],'facealpha',1,'edgecolor','none','FaceLighting','phong');
            case  2,  % FOV
                hAxes.Tracked(2) = patch('Parent',hAxes.Axes, ...
                    'Vertices',s.TrackedSurfaceObjects(ii).Vertices,'Faces',s.TrackedSurfaceObjects(ii).Faces, ...
                    'facecolor',[.5,.5,.9],'facealpha',.3,'edgecolor','none','FaceLighting','none');
            otherwise
                hAxes.Tracked(ii) = patch('Parent',hAxes.Axes, ...
                    'Vertices',s.TrackedSurfaceObjects(ii).Vertices,'Faces',s.TrackedSurfaceObjects(ii).Faces, ...
                    'facecolor','none','edgecolor',[1,1,1],'FaceLighting','phong');
        end
    end
    
else  % generate default one
    % a sphere
    Origin = [0,0,0];
    Axis = [0,0,1];
    Radius = 10;
    MinPhi = -pi/2;
    MaxPhi = pi/2;
    hsphere = igitkSpatialObject.Sphere(Origin,Axis,Radius,MinPhi,MaxPhi);
    % Objects{1}.Vertices = hsphere.Vertices;
    % Objects{1}.Faces = hsphere.Faces;
    obj1 = igitkSurface(hsphere);
    hAxes.Tracked(1) = patch('Parent',hAxes.Axes, 'Vertices',obj1.Vertices,'Faces',obj1.Faces, ...
        'facecolor',[.7,.7,1],'facealpha',1,'edgecolor','none','FaceLighting','phong');
    
    %
    Degree_fov = 160;
    Depth_fov = 150;
    n = 20;
    t = linspace(-Degree_fov/2,Degree_fov/2,n-2)' .*pi./180 - pi/2;
    FovPts = [ Origin(2)+[0;Depth_fov.*cos(t);0], ...
        ones(n,1)*Origin(1), ...
        Origin(3)+[0;Depth_fov.*sin(t);0] ];
    hAxes.Tracked(2) = patch('Parent',hAxes.Axes, 'XData',FovPts(:,1),'YData',FovPts(:,2),'ZData',FovPts(:,3), ...
        'facecolor',[.5,.5,.9],'facealpha',.3,'edgecolor','none','FaceLighting','none');    
end


%% apply calibration transformation
TrackedVertices = get(hAxes.Tracked,'Vertices');
TrackedNum = cellfun(@(x)size(x,1),TrackedVertices,'UniformOutput',false);

TrackedVertices_new = cellfun(@(v,n)v*Ts.p2w_R+ones(n,1)*Ts.p2w_t, ...
    TrackedVertices,TrackedNum, 'UniformOutput',false);
set(hAxes.Tracked,{'Vertices'},TrackedVertices_new);

