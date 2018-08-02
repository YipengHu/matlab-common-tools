function   hAxes = initialisePlot(hAxes,hMenu,Config)


% return two types of objects  to be tracked

% test: hf=figure;hAxes.Axes=axes('Parent',hf,'color',[0,0,0]);

%% clear old plotting if any
if  isfield(hAxes,'Static') && ~isempty(hAxes.Static),
    delete(hAxes.Static);
    hAxes.Static = [];
end
if  isfield(hAxes,'Tracked') && ~isempty(hAxes.Tracked),
    delete(hAxes.Tracked);
    hAxes.Tracked = [];
end

%% plotting static objects
hAxes.Static = zeros(8,1);
% get box
[vi,f] = getBoxTemplate;
% device
v = [-25,-100,-25;25,100,25];
hAxes.Static(1) = patch('Parent',hAxes.Axes,'Vertices',[v(vi(:,1),1),v(vi(:,2),2),v(vi(:,3),3)],'Faces',f, ...
    'facecolor','none','edgecolor',[.8,.8,.8],'DiffuseStrength',0);
% reference box
v = [-443.5,-469,-1336;443.5,469,-557];
hAxes.Static(2) = patch('Parent',hAxes.Axes,'Vertices',[v(vi(:,1),1),v(vi(:,2),2),v(vi(:,3),3)],'Faces',f, ...
    'facecolor','none','edgecolor',[.9,.5,.5],'edgealpha',0,'LineStyle','-', ...
    'DiffuseStrength',0,'AmbientStrength',1,'SpecularStrength',0);    
% axis
len = 150;
hAxes.Static(3:5) = line([0,0,0;0,0,len],[0,0,0;0,len,0],[0,0,0;len,0,0],'LineStyle','-');
hAxes.Static(6) = text('Position',[len.*1.1,0,0],'String','x+');
hAxes.Static(7) = text('Position',[0,len.*1.1,0],'String','y+');
hAxes.Static(8) = text('Position',[0,0,len.*1.1],'String','z+');
set(hAxes.Static(3:8), 'Parent',hAxes.Axes, 'Color','y');


%% dynamic objects
hAxes = generateTrackedObjects(hAxes,Config);


%% and finally, lighting now
hAxes.Static(end+1) = light('Parent',hAxes.Axes,'Style','local');
% lighting phong; 

%% viewing settings
set(hAxes.Axes,'DataAspectRatio',[1,1,1], 'Projection','orthographic');  % NB: perspective is not suitable for orthogonal views {orthographic,perspective}
hAxes = setAxesView(hAxes,hMenu,7);  % 7 is reset




