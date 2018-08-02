function  [status,info] = checkDataUS3D(dirname,prevtimestamp,ext)

% return:
% status - number of valid files
% info - DirName; DirTimestamp; FileNames; FileTimestamps


if  nargin<3 || isempty(ext),
    ext = '\*.nii';
else
    ext = ['\*.',ext];
end
status = false;
info.FileNames = {};
info.FileTimestamps = [];

% if any directory yet
list_dir = dir(dirname);
valid_dir = [list_dir.isdir] & ~strcmp('.',{list_dir.name}) & ~strcmp('..',{list_dir.name});
if  ~any(valid_dir), return; end

% find the newst directory
[info.DirTimestamp,max_dirind] = max([list_dir(valid_dir).datenum]);
valid_dirind = find(valid_dir);
% if yet created data directory
info.DirName = [ fullfile(dirname,list_dir(valid_dirind(max_dirind)).name), '\QmitkIGIUltrasonixTool' ];
if  exist(info.DirName,'dir')~=7,return;  end

% if empty
list_file = dir([info.DirName,ext]);
if  length(list_file)<3, return; end

% any valid file - 1:newly modified date 2: empty (inc.folders)
valid_file = [list_file.datenum]>prevtimestamp & [list_file.bytes]>0;
status = nnz(valid_file);  % anyone can make this point desrves a return ;)
if  status,
    info.FileNames = {list_file(valid_file).name};
    info.FileTimestamps = [list_file(valid_file).datenum];
end




% %% --- old code for new directory rules ---
% %% get any newer directory
% list = dir(dirname);
% valid = [list.datenum]>prevtimestamp & [list.isdir] ...
%     & ~strcmp('.',{list.name}) & ~strcmp('..',{list.name});
% if  any(valid),
%     status = nnz(valid);
%     % info.DirName = {list(valid).name};
%     %% now only select the newest
%     if  status==1,
%         info.Timestamp = list(valid).datenum;
%         info.DirName = list(valid).name;
%     else
%     end
% end




