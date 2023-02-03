clear;
clc;
warning off;
addpath(genpath('./'));

dsPath = './dataset/';
Incom_rate = {'_Per0.1', '_Per0.2', '_Per0.3', '_Per0.4','_Per0.5', '_Per0.6', '_Per0.7', '_Per0.8', '_Per0.9'};
dataname={'BDGP_fea'};
lambda = [10^-4,10^-2,1,10^2,10^4];
mu = [0, 10^-4,10^-2,1,10^2,10^4];
for dsi = 1:1:length(dataname)
    ResBest = zeros(10,8);
    StdBest = zeros(10,8);
    for ir = 1:length(Incom_rate)
        % load data & make folder
        dataName = dataname{dsi};
        rate = Incom_rate{ir};
        disp(strcat(dataName,rate));
        load(strcat(dsPath,dataName,rate,'.mat'));
        X = data;
        Y = truelabel{1};
        k = length(unique(Y));
        numview = length(X);
        %% para setting
        selectanchor = [1 2 5]*k;
        ACC = zeros(length(selectanchor),length(lambda),length(mu));
        NMI = zeros(length(selectanchor),length(lambda),length(mu));
        Purity = zeros(length(selectanchor),length(lambda),length(mu));
        
        tic
        [X1, H] = findindex(data, index);
        time1 = toc;
        term1 =0;
        id = 1;
        for ichor = 1:length(selectanchor)
            temp_anchor = selectanchor(ichor);
            for il = 1:length(lambda)
                for im = 1:length(mu)
                    temp_lambda = lambda(il);
                    temp_mu = mu(im);
                    tic;
                    [U,V,A,F,iter,obj] = miss_algo(X1,Y,temp_anchor,temp_lambda,temp_mu,H);
                    U = U ./ repmat(sqrt(sum(U .^ 2, 2)), 1, k);
                    time2 = toc;
                    stream = RandStream.getGlobalStream;
                    reset(stream);
                    MAXiter = 1000; % Maximum number of iterations for KMeans
                    REPlic = 20; % Number of replications for KMeans
                    tic;
                    for rep = 1 : 10
                        pY = kmeans(U, k, 'maxiter', MAXiter, 'replicates', REPlic, 'emptyaction', 'singleton');
                        res(rep, : ) = Clustering8Measure(Y, pY);
                    end
                    time3 = toc;
                    runtime(id)  = time1+time2+time3/10;
                    id = id +1;
                    tempRes = mean(res);
                    tempStd = std(res);
                    ACC(ichor, il,im) = tempRes(1);
                    NMI(ichor, il,im) = tempRes(2);
                    Purity(ichor, il,im) = tempRes(3);
                    for tempIndex = 1 : 8
                        if tempRes(tempIndex) > ResBest( ir, tempIndex)
                            if tempIndex == 1
                                newF = F;
                                newU = U;
                                objection = obj;
                            end
                            ResBest(ir, tempIndex) = tempRes(tempIndex);
                            StdBest(ir, tempIndex) = tempStd(tempIndex);
                        end
                    end
                end
                aRuntime = mean(runtime);
                PResBest = ResBest(ir, :);
                PStdBest = StdBest(ir, :);
            end
        end
        
        fprintf('Res:%12.6f %12.6f %12.6f \n',[PResBest(1) PResBest(2) PResBest(3)]);
        clear runtime;
    end
end
