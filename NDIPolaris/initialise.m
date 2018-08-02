function  [s,PortHandle] = initialise(pn,toolfile)

% pn : port name, e.g. 'COM1'

% Yipeng Hu - 2012-2014

%% create the object and set port properties
s = serial(pn);
% check the Device Manager
set(s,'BaudRate',9600,'DataBits',8,'StopBits',1,'Terminator','CR');  % optional: 'Parity','none'
% set short timeout
set(s,'Timeout',.2);
% connect the device
fopen(s);
fprintf('igitkNDIPolaris:Port %s is open.\n',pn);

%% -1- inilisation
% reset the system (soft)
% fprintf(s,'RESET 0');
% pause(1);
% fprintf(fscanf(s,'%c'));
% settings
reply = [];
while  isempty(reply) || ~strcmpi(reply(1:2),'OK'),
    fprintf(s,'COMM 70001');
    reply = fscanf(s,'%c');
end
fprintf('igitkNDIPolaris:System settings configured.\n');

% initialise the system
reply = [];
while  isempty(reply) || ~strcmpi(reply(1:2),'OK'),
    fprintf(s,'INIT ');
    pause(1);
    reply = fscanf(s,'%c');
end
fprintf('igitkNDIPolaris:System initialised.\n');

% test api revision
fprintf(s,'APIREV ');
fprintf('igitkNDIPolaris: %s',fscanf(s,'%c'));


%% -2- request a port handle - Prerequisite Command: PVWR or PHSR
% get port handle - need to repeat until response
reply = [];
while  isempty(reply) || strcmpi(reply(1:2),'ERROR'),
    fprintf(s,'PHSR 00');
    pause(2);
    reply = fscanf(s,'%s');
end
NumPH = str2double(reply(1:2));
if  NumPH,
    fprintf('igitkNDIPolaris:WARNING - Port handles need to be freed: %d\n',NumPH);
end

% assign a port handle to a tool
% PHRQ<SPACE><Hardware Device 8c><System Type*><Tool Type 1c><Port Number 2c><Reserved><CR>
% fprintf(s,'PHRQ:*********1****A4C1');
reply = [];
while  isempty(reply) || strcmpi(reply(1:2),'ERROR'),
    fprintf(s,'PHRQ:*********1****A4C1');
    pause(1);
    reply = fscanf(s,'%s');
end
PortHandle = reply(1:2);
fprintf('igitkNDIPolaris:Port handle requested: %s\n',PortHandle);


%% -3- assign a tool definition file
% PVWR<SPACE><Port Handle 2hexc><Start Address 4hexc><Tool Definition File Data 128hexc><CR>
% toolfile = 'C:\Yipeng\hh_work\mVicra\8700339.rom';
% read in file
fid = fopen(toolfile,'r');
[data,count] = fread(fid);
fclose(fid);
% write into chunks
chunksize = 64;  % in byte
numChunks = ceil(count/chunksize);
% padding
data = [data;zeros(numChunks*chunksize-count,1)];
for  ii = 1:numChunks,
    % convert to hexadecimal characters
    inc = sprintf('%04X',chunksize*(ii-1));
    chunck = sprintf('%02X',data((ii-1)*chunksize+1:ii*chunksize));
    % now call the command
    reply = [];
    while  isempty(reply) || ~strcmpi(reply(1:2),'OK'),
        fprintf(s,['PVWR ',PortHandle,inc,chunck]);
        reply = fscanf(s,'%c');
    end
end
fprintf('igitkNDIPolaris:Tool definition file loaded:\n  %s\n',toolfile);


%% -4- initialise and enable handles
reply = [];
while  isempty(reply) || ~strcmpi(reply(1:2),'OK'),
    fprintf(s,['PINIT ',PortHandle]);
    reply = fscanf(s,'%c');
end
fprintf('igitkNDIPolaris:Port Handle %s initialised.\n',PortHandle);

% return port handle status
fprintf(s,['PHINF ',PortHandle,'0001']);
fprintf(fscanf(s,'%c'));

% enable a port handle
reply = [];
while  isempty(reply) || ~strcmpi(reply(1:2),'OK'),
    fprintf(s,['PENA ',PortHandle,'D']);
    reply = fscanf(s,'%c');
end
fprintf('igitkNDIPolaris:Port Handle %s enabled.\n',PortHandle);
fprintf('igitkNDIPolaris:Initialisation Done.\n\n');





