function  [P1, Pt1, PX, L] = cpd_P_m(X,T, sigma2 ,outliers)


[N,D] = size(X); 
M = size(T,1);

const = (2*pi*sigma2)^(D/2) * 1/(1/outliers-1) * (M/N);

% choose in dimensions
if  D==3,
    P = exp( (-1/2/sigma2) .* ( ...
        (ones(M,1)*X(:,1)' - T(:,1)*ones(1,N)).^2 ...
        + (ones(M,1)*X(:,2)' - T(:,2)*ones(1,N)).^2 ...
        + (ones(M,1)*X(:,3)' - T(:,3)*ones(1,N)).^2 ) );
elseif  D==2,
    P = exp( (-1/2/sigma2) .* ( ...
        (ones(M,1)*X(:,1)' - T(:,1)*ones(1,N)).^2 ...
        + (ones(M,1)*X(:,2)' - T(:,2)*ones(1,N)).^2 ) );
else
end
E = sum(P,1)+const;
P = P./(ones(M,1)*E);

P1 = sum(P,2);
Pt1 = sum(P,1)';
PX = P*X;

L = sum(-log(E)) + D*N/2*log(sigma2);

