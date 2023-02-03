function [P,Z,r] = initialize(H,m,numsample,numview)
%INITIALIZE 此处显示有关此函数的摘要
%   此处显示详细说明
r = cell(1,numview);
Z = cell(1,numview);
rand('twister',721);
for v = 1: numview
    r{v} = H(:,v)';
    P{v} = eye(m);
    Z{v} = zeros(m,numsample); 
    Z{v}(1,:) = 1;
end
end

