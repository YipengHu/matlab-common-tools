function  [hFigure,hMenu,hAxes] = initialiseCallbacks(hFigure,hMenu,hAxes,Config)


%% Global variables 
%%
% bug fix
set(0,'recursionlimit',750);

%% tracking system
TSystem.Object = [];
TSystem.Tracking = false;
TSystem.Recording = false;
TSystem.BufferData = {};
TSystem.BufferCounter = 0;

%% sound system
% Sounds = configureSystem('sounds');
Sounds.Status = false;  % test if already being hit

%% assign Menu callbacks 
% system
set(hMenu.System_Initialise,'Callback',@Callback_System_Initialise); 
set(hMenu.System_Disconnect,'Callback',@Callback_System_Disconnect); 
set(hMenu.System_Reset,'Callback',@Callback_System_Reset); 

% track
set(hMenu.Track_Start,'Callback',@Callback_Track_Start);
set(hMenu.Track_Stop,'Callback',@Callback_Track_Stop);
set(hMenu.Track_Save,'Callback',@Callback_SimpleSwitch);
set(hMenu.Track_Record,'Callback',@Callback_SimpleSwitch);
set(hMenu.Track_Pause,'Callback',@Callback_SimpleSwitch);

% controls
set(hMenu.Control_Views,'Callback',@Callback_Control_Views);
set(hMenu.Control_CameraMotion,'Callback',@Callback_SimpleSwitch);


%% figure callback function
set(hFigure,'DeleteFcn',@Callback_Figure_Delete); 

function  Callback_Figure_Delete(~,~)
    % check tracking    
    if  TSystem.Tracking,
        % igitkNDIPolaris.stopTracking(TSystem.Object);
        TSystem.Tracking = false;
        pause(.1);
        igitkNDIPolaris.stopTracking(TSystem.Object);
    end
    % close system
    if  strcmpi(get(hMenu.System_Disconnect,'Enable'),'on'),
        igitkNDIPolaris.disconnect(TSystem.Object);
    end
end


%% menu callback functions

function  Callback_System_Initialise(object,~)

    % load settings
    
    set(hAxes.Text,'String','Initialising tracking system...');  
    TSystem.Object = igitkNDIPolaris.initialise(Config.SerialPort, Config.TrackingToolFile);
    
    set(object,'Enable','off');
    set(hMenu.System_Disconnect,'Enable','on');
    set(hMenu.System_Reset,'Enable','on');
    set(hMenu.Track_Start,'Enable','on');
    
    set(hAxes.Text,'String','Tracking system initialised.');

end

function  Callback_System_Disconnect(object,~)

    % stop tracking first
    if  TSystem.Tracking,
        igitkNDIPolaris.stopTracking(TSystem.Object);
        set(hMenu.Track_Start,'Enable','off');
        set(hMenu.Track_Stop,'Enable','off');
        TSystem.Tracking = false;
    end
    igitkNDIPolaris.disconnect(TSystem.Object);
    
    set(object,'Enable','off');
    set(hMenu.System_Initialise,'Enable','on');
    set(hMenu.System_Reset,'Enable','off');
    set(hMenu.Track_Start,'Enable','off');
    
    set(hAxes.Text,'String','Tracking system disconnected.');

end

function  Callback_System_Reset(~,~)
    if  strcmpi(get(hMenu.System_Disconnect,'Enable'),'on'),
        Callback_System_Disconnect(hMenu.System_Disconnect);
    end
    Callback_System_Initialise(hMenu.System_Initialise);
end


function  Callback_Track_Start(~,~)
    
    %% first check the connection on
    
    % update the timestamp
    % TSystem.PrevTimestamp = datenum(clock);
    
    % start tracking
    igitkNDIPolaris.startTracking(TSystem.Object);
    
    set(hMenu.Track_Start,'Enable','off');
    set(hMenu.Track_Stop,'Enable','on');
    TSystem.Tracking = true;
    
    set(hMenu.Track_Record,'Checked','off');
    set(hMenu.Track_Pause,'Checked','on');
    set(hAxes.ControlLights(2),'facecolor',[1,0,0]);
    TSystem.Recording = false;
    
    % initialise the plot  
    hAxes = initialisePlot(hAxes,hMenu,Config);

    % get the tracked objects
    TrackedVertices = get(hAxes.Tracked,'Vertices');
    TrackedNum = cellfun(@(x)size(x,1),TrackedVertices,'UniformOutput',false);   
     
    % initilise a few parameters
    Q = zeros(4,1);  % original quaternion data
    T = [eye(3);zeros(1,3)];  % 4-by-3 transformation matrix
    while  TSystem.Tracking,
        
        %% get tracking data
        % faster to code in the native while loop
        %  alternatively -> [TrackedFlag,T,Q] = getTransformation(TSystem.Object)
        fprintf(TSystem.Object,'TX 0001');
        reply = fscanf(TSystem.Object,'%c');
        if  length(reply)<49 || strcmp(reply(5:8),'MISS'),
            TrackedFlag = false;
        else
            TrackedFlag = true;
            Q = sscanf(reply(5:28),'%d')./1e4;
            T(4,:) = sscanf(reply(29:49),'%d')./1e2;
            % T = sscanf(reply(5:49),'%d');  Q = T(1:4)./1e4;  t = T(5:7)./1e2;           
            T(1:3,:) = determineR_inv(Q);
        end
                
        %% updating the tracked
        if  TrackedFlag,
            
            %% update the tracked objects here for speed
            TrackedVertices_new = cellfun(@(v,n)v*T(1:3,:)+ones(n,1)*T(4,:), ...
                TrackedVertices,TrackedNum, 'UniformOutput',false);
            set(hAxes.Tracked,{'Vertices'},TrackedVertices_new);  
            
            StatusMsg = 'Tracking...';
            set(hAxes.ControlLights(1),'facecolor',[0,1,0]);                       
                       
            drawnow  % expose update   
            
        else
            %% missing
            StatusMsg = 'Missing...';            
            set(hAxes.ControlLights(1),'facecolor',[1,0,0]);
            pause(0.01);  % regulate the frequency
        end
        %% update message - keep the previouos data - except for the status
        fprintf('Quaternions: %f; %f; %f; %f; \nTraslations: %f; %f; %f; \nStatus:%s \n\n', Q, T(4,:), StatusMsg)
        set(hAxes.Text,'String',sprintf('Status: %s',StatusMsg));
        
        
               
        %% saving the data
        if  strcmpi(get(hMenu.Track_Save,'Checked'),'on') && TrackedFlag,
            
            % save data
            Timestamp = datenum(clock);
            save(fullfile(Config.SaveFolder,[num2str(Timestamp),'.mat']),'Timestamp','T');
            
            % sounds
            beep;pause(.2);beep;pause(.2);beep;
            
            % turn off now
            Callback_SimpleSwitch(hMenu.Track_Save);
            
        end
        
        
        %% recording
        if  strcmpi(get(hMenu.Track_Record,'Checked'),'on') &&  ~TSystem.Recording,  % test if just switch on
            set(hMenu.Track_Pause,'Checked','off');
            TSystem.Recording = true;
            set(hAxes.ControlLights(2),'facecolor',[0,1,0]);
            % set the savings account - no need anymore
        end
        
        if  strcmpi(get(hMenu.Track_Pause,'Checked'),'on') &&  TSystem.Recording,  % test if just switch off
            set(hMenu.Track_Record,'Checked','off');
            TSystem.Recording = false;
            set(hAxes.ControlLights(2),'facecolor',[1,0,0]);
            % write to file
            Timestamp = datenum(clock);
            save(fullfile(Config.SaveFolder,[num2str(Timestamp),'.mat']),'-struct','TSystem','BufferData');
            TSystem.BufferData = {};
            TSystem.BufferCounter = 0;
            
            beep;pause(.2);beep;pause(.2);beep;
            
        end
        
        if  TSystem.Recording,
            TSystem.BufferCounter = TSystem.BufferCounter+1;
            TSystem.BufferData{TSystem.BufferCounter}.Timestamp = datenum(clock);
            TSystem.BufferData{TSystem.BufferCounter}.Data = T;
            % beep;
        end
        
        
    end  % while  TSystem.Tracking,
    
    % temp
    set(hAxes.ControlLights(1),'facecolor',[1,1,1]);
    set(hAxes.Text,'String','Tracking stopped.');

end

function  Callback_Track_Stop(~,~)
    
    % stop tracking
    igitkNDIPolaris.stopTracking(TSystem.Object);
    set(hMenu.Track_Start,'Enable','on');
    set(hMenu.Track_Stop,'Enable','off');
    TSystem.Tracking = false;
    
    set(hAxes.Text,'String','Tracking stopped.');
    
end


function  Callback_SimpleSwitch(object,~)
    
    if  strcmpi(get(object,'Checked'),'on'),
        set(object,'Checked','off');
    else
        set(object,'Checked','on');
    end
    
end


function  Callback_Control_Views(object,~)
    
    % get the event identifier
    eventid = get(object,'UserData');
    % set the flag FIRST!!!
    if  eventid<=4, % mutually exclusive buttons
        if  strcmpi(get(hMenu.Control_Views(eventid),'Checked'),'on'),
            return;
        else  
            set(hMenu.Control_Views(1:4),'Checked','off');
            set(hMenu.Control_Views(eventid),'Checked','on');
        end
        
    elseif  eventid==8,  % Global coordinate - simple switch        
        if  strcmpi(get(object,'Checked'),'on'),
            set(object,'Checked','off');
        else
            set(object,'Checked','on');
        end
        
    end
    % then set views
    hAxes = setAxesView(hAxes,hMenu,eventid);
    
end



end    % main function
