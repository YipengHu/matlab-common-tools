function  K = ebs_kernel(p,x,nu,opt,param)
%Compute the kernel matrix for elastic body spline (EBS)
% K = ebs_kernel(x,y,nu,opt);
% p: n-by-d, control point matrix
% x: m-by-d, data matrix
% nu: parameter of Poisson's ratio
% opt: force type: opt=1 for f=c*r(x); opt=2 for f=c/r(x); 
%      opt=3 for Gaussian force: K = ebs_kernel(p,x,nu,3,sigma);
%      opt=4 for volume splines; opt=5 for 3d thin plate splines

% Yipeng Hu (yipeng.hu@ucl.ac.uk), 
% Centre for Medical Image Computing, University College London, 2011.
% This code is for research purpose only.

% Ref: 
% [1] Davis et al (1997), "A Physics-Based Coordinate Transformation for 
%     3-D Image Matching", IEEE TMI, 16(3): 317-328
% [2] Kohlrausch, Rohr & Stiehl (2005), "A New Class of Elastic Body 
%     Splines for Nonrigid Registration of Medical Images", Journal of
%     Mathematical Imaging and Vision 23: 253-280


[m] = size(x,1);
[n,d] = size(p); 

% use cell representing submatrices
xd = zeros(3,m,n);
for i=1:d,
    xd(i,:,:) = ones(m,1)*p(:,i)' - x(:,i)*ones(1,n);
end
% construct the cell
xd = mat2cell(reshape(xd,[m*3,n]),3*ones(m,1),ones(n,1));
% apply basis function using cellfun
switch  opt,
    case  1,
        K = cellfun(@(y) basis1(y,nu,d), xd, 'UniformOutput',false);
    case  2,
        K = cellfun(@(y) basis2(y,nu,d), xd, 'UniformOutput',false);
    case  3,
        K = cellfun(@(y) basis_gauss(y,nu,d,param), xd, 'UniformOutput',false);
    case  4,  % redundant implementation
        K = cellfun(@(y) basis_vol(y,d), xd, 'UniformOutput',false);
    case  5,  % redundant implementation
        K = cellfun(@(y) basis_tps(y,d), xd, 'UniformOutput',false);
    otherwise
        fprintf('EBS:%s is not a valid kernel. \n\n',upper(opt));
        K=[];return;
end
% convert back
K = cell2mat(K); 


%% nested cell functions

%% for the force in the form of f=c*r(x)
function  g = basis1(y,nu,d)
alpha = 12*(1-nu)-1;
sqr = y'*y;
g = (alpha*sqr*eye(d)-y*y'*3) .* realsqrt(sqr);

%% for the force in the form of f=c/r(x)
function  g = basis2(y,nu,d)
beta = 8*(1-nu)-1;
r = realsqrt(y'*y);
if  r==0, r=1e-8; end
g = beta*r*eye(d)-y*y'./r;

%% for the Gaussian force
function  g = basis_gauss(y,nu,d,sigma)
s2 = sigma.^2; 
r2 = y'*y;
if  r2==0, r2=1e-8; end  % add small value to avoid /0 
r = realsqrt(r2);
rhat = r/(sqrt(2)*sigma);

c1 = erf(rhat)/r;
c2 = sqrt(2/pi)*sigma*exp(-rhat.^2)/r2;

g = ( (4*(1-nu)-1)*c1 - c2 + s2*c1/r2 ) * eye(d) ...
    + ( c1/r2 + 3*c2/r2 - 3*s2*c1/(r2*r2) ) * (y*y');

%% for volume splines (VS)
function  g = basis_vol(y,d)
g = (y'*y)^(3/2) * eye(d);

%% 3D thin plate splines
function  g = basis_tps(y,d)
g = realsqrt(y'*y) * eye(d);

