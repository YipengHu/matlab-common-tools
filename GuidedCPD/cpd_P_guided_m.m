function  [P1,Pt1,PX,L] = cpd_P_guided(X,T,sigma2,outliers,K,ss2)

D = size(X,2);
N = size(X,1)-K; 
M = size(T,1)-K;
const = (2*pi*sigma2)^(D/2) * 1/(1/outliers-1) * (M/N);

% choose in dimensions
if  D==3,
    P = exp( (-1/2/sigma2) .* ( ...
        (ones(M,1)*X(1:N,1)' - T(1:M,1)*ones(1,N)).^2 ...
        + (ones(M,1)*X(1:N,2)' - T(1:M,2)*ones(1,N)).^2 ...
        + (ones(M,1)*X(1:N,3)' - T(1:M,3)*ones(1,N)).^2 ) );
elseif  D==2,
    P = exp( (-1/2/sigma2) .* ( ...
        (ones(M,1)*X(1:N,1)' - T(1:M,1)*ones(1,N)).^2 ...
        + (ones(M,1)*X(1:N,2)' - T(1:M,2)*ones(1,N)).^2 ) );
else
end
E = sum(P,1)+const;
P = P./(ones(M,1)*E);
L = sum(-log(E)) + D*N/2*log(sigma2);

Pall = zeros(M+K,N+K);
Pall(1:M,1:N) = P;
Pall(sub2ind([M+K,N+K],M+1:M+K,N+1:N+K)) = sigma2/ss2;

P1 = sum(Pall,2);
Pt1 = sum(Pall,1)';
PX = Pall*X;


