function  disconnect(s)

% Yipeng Hu - 2012-2014

portname = s.Port;
fclose(s);
delete(s);
fprintf('igitkNDIPolaris:Port %s disconnected.\n\n',portname);

% clear s