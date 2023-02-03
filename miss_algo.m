function [UU,V,A,Z_temp,iter,obj,gamma] = miss_algo(X,Y,m,lambda,mu,H)
% m      : the number of anchor. the size of F is m*n.
% lambda : the hyper-parameter of regularization term.
% X      : n*di

%% initplize
maxIter = 100 ; % the number of iterations
numview = length(X);
numsample = size(Y,1);
k = length(unique(Y));

gamma = ones(numview,1)/numview;
Z_temp = {};
[P,Z,r] = initialize(H,m,numsample,numview);
A = cell(1,numview);
f = zeros(m,1);
tao = zeros(1,numview);
F = zeros(m,numsample);
F(:,1:m)= eye(m);
flag = 1;
iter = 0;
%%
while flag
    iter = iter + 1;
    %% optimize A
    for v = 1:numview
        M = X{v} * Z{v}';
        [Unew,~,Vnew] = svd(M,'econ');
        A{v} = Unew*Vnew';
    end

    
    %% optimize F
    M = zeros(numsample,m);
    for v = 1:numview
        M = M+Z{v}'*P{v}';
    end
    [Unew,~,Vnew] = svd(lambda*M,'econ');
    F = (Unew*Vnew')';
    

    
    %% optimize Z_v
    for v = 1:numview
        temp1 = gamma(v)^2*A{v}'*X{v};
        temp2 = lambda * P{v}'*F;
        for j = 1:numsample
            for i = 1:m
                f(i) = (temp1(i,j)+temp2(i,j))/(gamma(v)^2*r{v}(j)+lambda+mu);
            end
            Z{v}(:,j) = EProjSimplex_new(f);
        end
    end
    

    %% optimize P
        for v = 1:numview
            W = F * Z{v}';
            [Unew,~,Vnew] = svd(W,'econ');
            P{v} = Unew*Vnew';
        end
        

    %% optimize gamma
    sum1 = 0;
    for v =1:numview
        tao(v) = norm(X{v} - A{v} * (Z{v}.*repmat(r{v},m,1)),'fro')^2;
        sum1 = sum1 + 1/tao(v);
    end
    %%
    for v = 1:numview
        gamma(v) = 1/tao(v);
        gamma(v) = gamma(v)/sum1;
    end
    
    %% objection
    term1 = 0;
    for v = 1:numview
        term1 = term1 + gamma(v)^2* tao(v) +lambda*norm(P{v}*Z{v}-F,'fro')^2 + mu*norm(Z{v},'fro')^2;
    end
    obj(iter) = term1;
    Z_temp{iter} = F;
    
    if (iter>9) && (abs((obj(iter-1)-obj(iter))/abs(obj(iter-1)))<1e-6 || iter>maxIter || abs(obj(iter)) < 1e-6)
        [UU,~,V]=svd(F','econ');
        UU = UU(:,1:k);
        flag = 0;
    end
end



