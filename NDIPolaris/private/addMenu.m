function   hMenu = addMenu(hFigure)


%% System
hMenu.System = uimenu('Parent',hFigure,'Label','SYSTEM');
hMenu.System_Initialise = uimenu('Parent',hMenu.System,'Label','Initialise System');
hMenu.System_Disconnect = uimenu('Parent',hMenu.System,'Label','Disconnect System','Enable','off');

hMenu.System_Reset = uimenu('Parent',hMenu.System,'Label','Reset System','Enable','off','Separator','on');

% hMenu.System_Settings = uimenu('Parent',hMenu.System,'Label','Settings','Enable','off','Separator','on');


%% Tracking
hMenu.Track = uimenu('Parent',hFigure,'Label','TRACK');

hMenu.Track_Start = uimenu('Parent',hMenu.Track,'Label','Start Tracking','Enable','off');
hMenu.Track_Stop = uimenu('Parent',hMenu.Track,'Label','Stop Tracking','Enable','off');

hMenu.Track_Save = uimenu('Parent',hMenu.Track,'Label','Save','Checked','off','Accelerator','s','Separator','on');

hMenu.Track_Record = uimenu('Parent',hMenu.Track,'Label','Record','Checked','off','Accelerator','r','Separator','on');
hMenu.Track_Pause = uimenu('Parent',hMenu.Track,'Label','Pause','Checked','on','Accelerator','p','Separator','off');


%% Data
hMenu.Data = uimenu('Parent',hFigure,'Label','DATA');

hMenu.Data_Load = uimenu('Parent',hMenu.Data,'Label','Load','Enable','off');


%% Control
hMenu.Control = uimenu('Parent',hFigure,'Label','CONTROL');

% userdata = eventid
hMenu.Control_View = uimenu('Parent',hMenu.Control,'Label','View','Separator','on');
hMenu.Control_Views(1) = uimenu('Parent',hMenu.Control_View,'Label','3D View','Accelerator','1','Checked','on','UserData',1);
hMenu.Control_Views(2) = uimenu('Parent',hMenu.Control_View,'Label','Y-Z','Accelerator','2','UserData',2);
hMenu.Control_Views(3) = uimenu('Parent',hMenu.Control_View,'Label','X-Z','Accelerator','3','UserData',3);
hMenu.Control_Views(4) = uimenu('Parent',hMenu.Control_View,'Label','X-Y','Accelerator','4','UserData',4);

% hMenu.Control_Views(8) = uimenu('Parent',hMenu.Control,'Label','Global Coordinate','UserData',8);

hMenu.Control_Views(5) = uimenu('Parent',hMenu.Control,'Label','Zoom In','Accelerator','i','Separator','on','UserData',5);
hMenu.Control_Views(6) = uimenu('Parent',hMenu.Control,'Label','Zoom Out','Accelerator','o','UserData',6);
hMenu.Control_Views(7) = uimenu('Parent',hMenu.Control,'Label','Reset View','Accelerator','v','UserData',7);

set(hMenu.Control_Views,'Interruptible','off','BusyAction','cancel');

hMenu.Control_Option = uimenu('Parent',hMenu.Control,'Label','Options','Separator','on');
hMenu.Control_CameraMotion = uimenu('Parent',hMenu.Control_Option,'Label','Camera Motion','Checked','on');
