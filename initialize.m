function [P,Z,r] = initialize(H,m,numsample,numview)
%INITIALIZE �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
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

