function  c = rbfs_fit(x,y,lambda,type,param)
%Compute the coefficients of radial basis function (rbfs) splines
% c = rbfs_fit(x,y,lambda,type,param);
% x and y: the same n-by-d data matrix, so y=f(x);
% lambda: approximating parameter, interpolation when set to 0, or a vector
%         with size of n-by-1 when weighting each control point
% type: a string indicating the type of kernel
%      'tps'    - thin plate splines
%      'gauss'  - Gaussian
%      'mquad'  - multiquadratics
%      'wen31'  - Wendland's function with d=3, k=1 (local compact support)
% param: a vector containing extra parameters wrt the type
%      'tps'    - no further parameter
%      'gauss'  - param(1)=sigma
%      'mquad'  - param(1)=mu, param(2)=c 
%                 NB if mu<0 rbf becomes inverse multiquadratics
%      'wen31'  - param(1)=alpha

% Yipeng Hu (yipeng.hu@ucl.ac.uk), 
% Centre for Medical Image Computing, University College London, 2011.
% This code is for research purpose only.

[n,d] = size(x); [m,d2] = size(y);
if  d2~=d || m~=n, 
    fprintf('x and y must have the same size. \n'); 
    c=[]; return; 
end

if  nargin<3 || isempty(lambda), lambda=1e-5; end
if  length(lambda)>1,
    lambda = diag(lambda);
else
    lambda = lambda*eye(n);
end
if  nargin<4, type='tps'; end
if  nargin<5, param=[]; end

% if use the polynomial part
pflag = strcmpi(type,'tps') || (strcmpi(type,'mquad') && param(1)>0);

% compute the kernel
K = rbfs_kernel(x,x,type,param);

% solve the linear equations for coefs with svd in case of singular L
if  pflag,  % use the polynomial part
    % compute the kernel
    P = [ones(n,1),x];
    D = [K+lambda,P;P',zeros(d+1)];
    y = [y;zeros(d+1,d)];    
    [U,S,V] = svd(D);
    c = U*diag(1./diag(S))*V'*y;
    % c = D \ y;
else      
    [U,S,V] = svd(K+lambda);
    c = U*diag(1./diag(S))*V'*(y-x);
    % c = (K+lambda) \ (y-x);
end




