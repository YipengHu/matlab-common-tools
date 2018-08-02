function  startTracking(s)

% Yipeng Hu - 2012-2014


%% start tracking
reply = [];
while  isempty(reply) || ~strcmpi(reply(1:2),'OK'),
    fprintf(s,'TSTART ');
    reply = fscanf(s,'%c');
end
fprintf('igitkNDIPolaris:Tracking started...\n\n');