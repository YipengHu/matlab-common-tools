function   GUI(Config)


if  nargin<1,  Config = []; end

if  ~isfield(Config,'TrackingToolFile') || isempty(Config.TrackingToolFile),
    error('No TrackingToolFile in Config found');
end
if  ~isfield(Config,'SerialPort') || isempty(Config.SerialPort),
    error('No SerialPort in Config found');
end
if  ~isfield(Config,'SaveFolder') || isempty(Config.SaveFolder),
    error('No SerialPort in Config found');
end

%% generate the figure
hFigure = figure( 'NumberTitle','off', 'Name', ...
    'igitkNDIPolaris Tracker - FOR RESEARCH PURPOSES ONLY - UCL Centre for Medical Image Computing 2013', ...
    'Units','normalized', 'DockControls','off', 'Position',[.1,.1,.8,.8], ...
    'MenuBar','none', 'Toolbar','none', 'color',[0,0,0], ...
    'Visible','off','Renderer','OpenGL');  %


%% add the menu
hMenu = addMenu(hFigure);

%% add the axes
hAxes = addAxes(hFigure);

%% set callbacks now
hFigure = initialiseCallbacks(hFigure,hMenu,hAxes,Config);

%% for test
if  1,
    % warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
    javaFrame = get(hFigure,'JavaFrame');
    javaFrame.setFigureIcon(javax.swing.ImageIcon('C:\Yipeng\hh_work\igitk\res/cmic_logo_hex_600dpi_transparency.png'));
end

set(hFigure,'visible','on');