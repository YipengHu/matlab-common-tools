function  hAxes = addAxes(hFigure)

%% main axes
hAxes.Axes = axes('Parent',hFigure,'Units','normalized', ...
    'Position',[0,0,1,1], ... % 'ActivePositionProperty','position', ...   % 'OuterPosition',[0,0,1,1],
    'HandleVisibility','callback','NextPlot','replacechildren', ...
    'color',[0,0,0],'XGrid','off','YGrid','off','ZGrid','off');

%% right bottom dialogue
hAxes.Text = uicontrol('Parent',hFigure,'Style','Text', ...
    'Units','normalized','Position',[3/4,0,1/5,.02], ...
    'String','System not initialised.','HorizontalAlignment','right', 'SelectionHighlight','off', ...
    'FontSize',10,'BackgroundColor',[0,0,0],'ForegroundColor',[.34,.42,.64], ...
    'Visible','on');


%% left upper control lights
hAxes.ControlLightAxes = axes('Parent',hFigure,'Units','normalized', ...
    'Position',[0,0.88,0.12,0.12], ... % 'ActivePositionProperty','position', ...   % 'OuterPosition',[0,0,1,1],
    'HandleVisibility','callback','NextPlot','replacechildren', ...
    'color',[0,0,0],'XGrid','off','YGrid','off','ZGrid','off', ...
    'DataAspectRatio',[1,1,1],'XLim',[0,1],'YLim',[0,1],'ZLim',[0,1],'Visible','off');
% lights
shape = 'circle';
p = getLightShape([.1,.8],0.1,shape);
hAxes.ControlLights(1) = patch('Parent',hAxes.ControlLightAxes, 'XData',p(:,1),'YData',p(:,2), ...
    'facecolor',[1,1,1],'edgecolor','none');
hAxes.ControlLights(4) = text('Parent',hAxes.ControlLightAxes,'Position',[.3,.8], 'String','Tracking','Color',[.5,.5,.5]);
p = getLightShape([.1,.5],0.1,shape);
hAxes.ControlLights(2) = patch('Parent',hAxes.ControlLightAxes, 'XData',p(:,1),'YData',p(:,2), ...
    'facecolor',[1,1,1],'edgecolor','none');
hAxes.ControlLights(5) = text('Parent',hAxes.ControlLightAxes,'Position',[.3,.5], 'String','Recording','Color',[.5,.5,.5]);



%% orientation panel
hAxes.OrientationAxes = axes('Parent',hFigure,'Units','normalized', ...
    'Position',[0,0,0.15,0.15], ... % 'ActivePositionProperty','position', ...   % 'OuterPosition',[0,0,1,1],
    'HandleVisibility','callback','NextPlot','replacechildren', ...
    'color',[0,0,0],'XGrid','off','YGrid','off','ZGrid','off', ...
    'DataAspectRatio',[1,1,1],'XLim',[-1,1],'YLim',[-1,1],'ZLim',[-1,1],'Visible','off');
len = 0.8;
hAxes.Orientations(1:3) = line([0,0,-len;0,0,len],[0,-len,0;0,len,0],[-len,0,0;len,0,0],'Parent',hAxes.OrientationAxes,'LineStyle','-');
hAxes.Orientations(4) = text('Parent',hAxes.OrientationAxes,'Position',[1,0,0]*.9,'String','R');
hAxes.Orientations(5) = text('Parent',hAxes.OrientationAxes,'Position',[-1,0,0]*.9,'String','L');
hAxes.Orientations(6) = text('Parent',hAxes.OrientationAxes,'Position',[0,1,0]*.9,'String','I');
hAxes.Orientations(7) = text('Parent',hAxes.OrientationAxes,'Position',[0,-1,0]*.9,'String','S');
hAxes.Orientations(8) = text('Parent',hAxes.OrientationAxes,'Position',[0,0,1]*.9,'String','A');
hAxes.Orientations(9) = text('Parent',hAxes.OrientationAxes,'Position',[0,0,-1]*.9,'String','P');
set(hAxes.Orientations(4:9),'color',[.34,.42,.64],'FontSize',10);



