% ex01_3d_allspines: rbfs & ebs

%% example starts here
clear
% load example data
load('./data3d_ex01','cpts','tris');
% produce grid points
sp=.05;
[x0,y0,z0] = meshgrid( 0:sp:1, 0:sp:1, 0:sp:1 );
framef = PatchFrame3D(size(x0));  % for plot use
n0 = [x0(:),y0(:),z0(:)];  clear x0 y0 z0 sp

% assemble control points
p = [cpts{1}.ori;cpts{2}.ori;cpts{3}.ori];
q = [cpts{1}.def;cpts{2}.def;cpts{3}.def];

%% (1) radial basis function splines
% fit spline
lambda=1e-5;
% type = 'tps';   param = []; 
type = 'gauss'; param = .2;
% type = 'mquad'; param = [.1,5];
% type = 'wen';   param = .5; % local

% % apply initial affine 
% T0 = rigid_fit(p,q,'affine');  % initial T0
% tp = rigid_eval(p,T0);
% c = rbfs_fit(tp,q,lambda,type,param);
% n1 = rbfs_eval(tp,rigid_eval(n0,T0),c,type,param);

tic;c = rbfs_fit(p,q,lambda,type,param);toc;
tic;n1 = rbfs_eval(p,n0,c,type,param);toc;

% plot the result
hf=figure; hold on;
plot3(cpts{3}.ori(:,1),cpts{3}.ori(:,2),cpts{3}.ori(:,3),'-b','linewidth',5); 
plot3(cpts{3}.def(:,1),cpts{3}.def(:,2),cpts{3}.def(:,3),'-c','linewidth',5); 
patch('faces',tris,'vertices',cpts{2}.ori,'facecolor','b','facealpha',.2,'edgecolor','none');
patch('faces',tris,'vertices',cpts{2}.def,'facecolor','c','facealpha',.6,'edgecolor','none'); 
patch('faces',framef,'vertices',n0,'facecolor','none','edgecolor','b');
patch('faces',framef,'vertices',n1,'facecolor','none','edgecolor','c');
axis equal


%% (2) elastic body spline
% % options
% nu=.01;  opt=1; sigma=[]; 
% nu=.49;  opt=2; sigma=[]; 
nu=.01;  opt='Gauss'; sigma=.05; 
% nu=[];  opt=4; sigma=[]; 
% nu=[];  opt=5; sigma=[]; 

% % apply initial affine 
% T0 = rigid_fit(p,q,'affine');
% tp = rigid_eval(p,T0);
% w = ebs_fit(tp,q,nu,[],opt,sigma);
% n1 = ebs_eval(tp,rigid_eval(n0,T0),w,nu,opt,sigma);

tic; w = ebs_fit(p,q,nu,[],opt,sigma); toc;
tic; n1 = ebs_eval(p,n0,w,nu,opt,sigma); toc;

%% plot the result
figure, hold on;
plot3(cpts{3}.ori(:,1),cpts{3}.ori(:,2),cpts{3}.ori(:,3),'-b','linewidth',5); 
plot3(cpts{3}.def(:,1),cpts{3}.def(:,2),cpts{3}.def(:,3),'-g','linewidth',5); 
patch('faces',tris,'vertices',cpts{2}.ori,'facecolor','b','facealpha',.2,'edgecolor','none');
patch('faces',tris,'vertices',cpts{2}.def,'facecolor','g','facealpha',.6,'edgecolor','none'); 
patch('faces',framef,'vertices',n0,'facecolor','none','edgecolor','b');
patch('faces',framef,'vertices',n1,'facecolor','none','edgecolor','g');
axis equal
        





