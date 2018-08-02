function   [R,t] = MeanTransformation(Rs,ts)

% compute mean rotation
% Ra = mean(Rs,3); R = Ra*(Ra'*Ra)^(-1/2); %  polar decomposition
[U,~,V] = svd(sum(Rs,3));  R = U*V';   % using SVD - faster

% mean translation
t = mean(ts,2);