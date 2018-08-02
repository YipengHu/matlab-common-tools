
function G=cpd_G(x,y,beta)

% alternative to the original

if nargin<3, error('cpd_G.m error! Not enough input parameters.'); end;

k=-2*beta^2;
m=size(x,1); n=size(y,1);
G = zeros(m,n);

if  isequal(x,y),  % using the symmetry property
    for  i=1:m,
        for  j=1:i,
            G(i,j) = exp(sum((x(i,:)-y(j,:)).^2)/k);
        end
    end
    G = G + G';
    G(logical(eye(m))) = G(logical(eye(m)))./2;
    return;
end

% mainly for evaluation
for  j=1:n,
    for  i=1:m,
        G(i,j) = exp(sum((x(i,:)-y(j,:)).^2)/k);
    end
end


% %%  -----
% G=repmat(x,[1 1 m])-permute(repmat(y,[1 1 n]),[3 2 1]);
% G=squeeze(sum(G.^2,2));
% G=G/k;
% G=exp(G);