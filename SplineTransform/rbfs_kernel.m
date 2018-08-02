function  K = rbfs_kernel(x,y,type,param)
%Compute the kernel matrix for rdfs
% K = rbfs_kernel(x,y,type,param);
% x: n-by-d data matrix, as control points
% y: m-by-d data matrix
% type: a string indicating the type of kernel
%      'tps'    - thin plate splines
%      'gauss'  - Gaussian
%      'mquad'  - multiquadratics
%      'wen31'  - Wendland's function with d=3, k=1 (local compact support)
% param: a vector containing parameters of the kernel
%      'tps'    - no parameter
%      'gauss'  - param(1)=sigma
%      'mquad'  - param(1)=mu, param(2)=c 
%                 NB if mu<0 rbf becomes inverse multiquadratics
%      'wen31'  - param(1)=alpha

% Yipeng Hu (yipeng.hu@ucl.ac.uk), 
% Centre for Medical Image Computing, University College London, 2011.
% This code is for research purpose only.

[n,d] = size(x); 
[m] = size(y,1);

% compute r^2, stored in K
K = zeros(n,m);
for i=1:d,
    K = K + (x(:,i)*ones(1,m)-ones(n,1)*y(:,i)').^2;
end

switch  lower(type(1:3)),
    case  'tps',
        if  d==2,
            % adding small value for log(0) may be here
            K = K.*log(realsqrt(K));
        elseif  d==3,
            K = -realsqrt(K);
        end
    case  'gau',
        sigma = param(1);
        K = exp(K./(-sigma^2*2));
    case  'mqu',
        mu=param(1); c=param(2);
        K = (K+c^2).^mu;
    case  'wen', 
        alpha = param(1);
        K = realsqrt(K)./alpha;
        K = (1-K).^4.*(4*K+1).*(K<1);   
    case  'loc',
        K = (1-K).^3;
    otherwise
        fprintf('RBFS:%s is not a valid kernel... \n\n',upper(type));
        K=[];
end



