function x2d = project(x3d, K, RT)

P = K * RT;

x2d = P*[x3d ones(size(x3d,1), 1)]';
x2d(1,:) = x2d(1,:) ./ x2d(3,:);
x2d(2,:) = x2d(2,:) ./ x2d(3,:);
x2d = x2d(1:2,:)';