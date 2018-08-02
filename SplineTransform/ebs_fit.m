function  w = ebs_fit(p,q,nu,lambda,opt,param)
%Compute the coefficients of the elastic body spline (EBS) given data x y
% w = ebs_fit(p,q,nu);
% p: n-by-d, source data matrix (control point)
% q: n-by-d, target data matrix
% nu: parameter of Poisson's ratio
% 
% w = ebs_fit(p,q,nu,lambda,opt);
% lambda: regularisation parameter, [1e-6]
% opt:    force type: opt=[1] for f=c*r(x); opt=2 for f=c/r(x);
%         opt=4 for volume splines; opt=5 for 3d thin plate splines
%
% w = ebs_fit(p,q,nu,lambda,'Gauss',sigma);
% w = ebs_fit(p,q,nu,lambda,3,sigma);
% sigma: parameter std when force type is Gaussian, see ref [2]

% Yipeng Hu (yipeng.hu@ucl.ac.uk), 
% Centre for Medical Image Computing, University College London, 2011.
% This code is for research purpose only.

% Ref: 
% [1] Davis et al (1997), "A Physics-Based Coordinate Transformation for 
%     3-D Image Matching", IEEE TMI, 16(3): 317-328
% [2] Kohlrausch, Rohr & Stiehl (2005), "A New Class of Elastic Body 
%     Splines for Nonrigid Registration of Medical Images", Journal of
%     Mathematical Imaging and Vision 23: 253-280

%% check inputs
% control points
[n,d] = size(p); [m,d2] = size(q);
if  d2~=d || m~=n, fprintf('ERROR: p and q must have the same size. \n'); 
    w=[]; return; 
end
% force type
if  nargin<5 || isempty(opt), opt=1; end  
if  nargin<6, param=[]; end  
% check for the gaussian case
if  strcmpi(opt(1),'g'), opt=3; end
if  opt==3 && isempty(param), error('Gaussian kernel requires parameter Sigma.'); end
% cases using polynomial part
pflag = any(opt==[1,2,4,5]);
% regularisation parameter
if  nargin<4 || isempty(lambda), 
    if  opt==3, lambda=1e-6; else  lambda=0; end
end
if  length(lambda)>1,
    lambda = diag(lambda);
else
    lambda = lambda*eye(n*d);
end
% Poisson's ratio
if  nargin<3 || isempty(nu), nu=0.49; end  % volume preserving as default
if  (nu<0 || nu>0.5) && any(opt==[1,2,3]), 
    fprintf('ERROR: nu must be in [0,0.5]. \n'); w=[]; return; 
end

%% compute the kernel
K = ebs_kernel(p,p,nu,opt,param);
% and the correponding displacements
y = reshape((q-p)',n*d,1);

%% construct the design matrix
if  pflag,
    y = [y;zeros((d+1)*d,1)]; % append the zeros to displacements
    p_rep = zeros(n,d*d);
    for  i=1:d, p_rep(:,d*(i-1)+1:d*i)=(p(:,i))*ones(1,d); end
    P = zeros(n*d,d*d);
    P(logical(repmat(eye(d),n,d))) = p_rep;
    P = [P,repmat(eye(d),n,1)];  % append the Is
    L = [K+lambda,P;P',zeros((d+1)*d)];
else
    L = K+lambda;
end

%% solve the linear equations with svd in case of singular L (w=L\y;)
[U,S,V] = svd(L);
w = U*diag(1./diag(S))*V'*y;


