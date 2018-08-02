function   hAxes = setAxesView(hAxes,hMenu,eventid)

% set(hAxes.Axes,'DataAspectRatio',[1,1,1], 'Projection','orthographic',...  % 'perspective',...
%     'CameraTarget',mean(get(hAxes.Static(2),'Vertices')), ...
%     'CameraPosition',[-500,1000,-1200], ...
%     'CameraUpVector',[-1,0,0], 'CameraViewAngle',60);

% check if anything plotted yet
if  ~isfield(hAxes,'Static') || isempty(hAxes.Static), return; end

%% get current property
% order - {'CameraTarget','CameraPosition','CameraUpVector','CameraViewAngle'}
CameraProperties = {'CameraTarget','CameraPosition','CameraUpVector','CameraViewAngle'};
currentProperties = get(hAxes.Axes,CameraProperties);


%% get target properties
% get target position
CameraD = 600;
viewid = find(strcmpi(get(hMenu.Control_Views,'Checked'),'on'));
switch  viewid,
    case  1,  % 3D view
        targetProperties = { mean(get(hAxes.Tracked(2),'Vertices')), ...  % centre of the FOV
            [-500,800,-1000], ...
            [-1,0,0], ...
            currentProperties{4} };
    case  {2,3,4},  % image plane view
        ObjectIndex = viewid+1;
        if  ~isfield(hAxes,'Imaging') || isempty(get(hAxes.Imaging(ObjectIndex),'CData')),  % to be changed for the case where no imaging available - YH-2013-11 
            fprintf('setAxesView:Imging data not available yet.\n');
            fprintf('setAxesView:Reset to 3D view.\n');
            set(hMenu.Control_Views(eventid),'Checked','off');
            set(hMenu.Control_Views(1),'Checked','on');
            return;
        end
        ViewData = get(hAxes.Imaging(ObjectIndex),'UserData');
        targetProperties = { ViewData(1,:), ...  % centre
            ViewData(1,:)+ViewData(2,:)*CameraD, ...  % Axes
            ViewData(3,:), ...  % UpVector
            currentProperties{4} };
end
%% update in any case

% centre alo can be: mean(get(hAxes.Static(2),'Vertices'))
switch  eventid,
    case  1,  % 3D view        
    case  2,  % transverse
    case  3,  % sagittal
    case  4,  % coronal
    case  5,  % zoom in
        targetProperties{4} = currentProperties{4}-5;
    case  6,  % zoom out
        targetProperties{4} = currentProperties{4}+5;
    case  7,  % reset
        targetProperties{4} = 30;
    otherwise
        fprintf('setAxesView: Unknown eventid - No.%d\n',eventid);
        return;
end

%% set lighting position 
set(hAxes.Static(end),'Position',targetProperties{2});

%% set the range for ViewAngle
if  targetProperties{4}>=80,
    targetProperties{4}=80;
    set(hMenu.Control_Views(5),'Enable','on');
    set(hMenu.Control_Views(6),'Enable','off');
elseif  targetProperties{4}<=5,
    targetProperties{4}=5;
    set(hMenu.Control_Views(5),'Enable','off');
    set(hMenu.Control_Views(6),'Enable','on');
else
    set(hMenu.Control_Views(5),'Enable','on');
    set(hMenu.Control_Views(6),'Enable','on');
end


%% first set the orientation axes
camoffpos = targetProperties{2}-targetProperties{1};
set( hAxes.OrientationAxes, {'CameraTarget','CameraPosition','CameraUpVector'}, ...
    {[0,0,0],camoffpos./norm(camoffpos),targetProperties{3}} );


%% if no camera motion required - set directly
if  eventid==7 || strcmpi(get(hMenu.Control_CameraMotion,'Checked'),'off'),
    set(hAxes.Axes,CameraProperties,targetProperties);
    return;
end

%% otherwise to motion
total_time = 0.1;
num_frame = 10;
frame_rate = total_time/num_frame;
alphavalues = 1-abs(linspace(-1,1,num_frame+1));
time = 1/num_frame:1/num_frame:1;
diffProperties = cellfun(@(p0,p1)p1-p0,currentProperties,targetProperties,'UniformOutput',false);
for  ii = 1:num_frame,
    tempProperties = cellfun(@(p0,pd)p0+pd*time(ii),currentProperties,diffProperties,'UniformOutput',false); 
    set(hAxes.Axes,CameraProperties,tempProperties);
    % set the frame
    set(hAxes.Static(2),'edgealpha',alphavalues(ii+1));
    pause(frame_rate);  % pause refreshes, drawnow
end


%% - obsolete as the interpolation of vectors not useful
%% nested function to calculate the intermediate camera properties
% tempProperties = getIntermediateProperties(currentProperties,targetProperties,time);
% function  ps = getIntermediateProperties(ps0,ps1,t)
% % order - {'CameraTarget','CameraPosition','CameraUpVector','CameraViewAngle'}
% ps{4} = ps0{4}+(ps1{4}-ps0{4})*t;
% ps{1} = ps0{1}+(ps1{1}-ps0{1})*t;
% ps{2} = ps0{2}+(ps1{2}-ps0{2})*t;
% 
% % simple interpolation for the directinal vector so 
% ps{3} = ps1{3}; % t=1
% % [U,~,V] = svd(ps1{3}+ps0{3}*(1-t));  ps{3} = U*V';
% ps{3} = ps0{3}+(ps1{3}-ps0{3})*t;  % ps{3} = ps{3}/norm(ps{3});



