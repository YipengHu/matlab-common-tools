function  stopTracking(s)

% Yipeng Hu - 2012-2014

%% start tracking
reply = [];
while  isempty(reply) || ~strcmpi(reply(1:2),'OK'),
    fprintf(s,'TSTOP ');
    reply = fscanf(s,'%c');
end
fprintf('igitkNDIPolaris:Tracking stopped.\n\n');