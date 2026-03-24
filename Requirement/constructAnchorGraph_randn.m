function [S, anchors] = constructAnchorGraph(X, k, varargin)
    % X : cell , n *dm
    % k : 锚点个数
    sigma = [];
    targetDim = 100;
    sampleSize = 15000;
    iter = 40;
    for i = 1:2:length(varargin)
        switch lower(varargin{i})
            case 'sigma'
                sigma = varargin{i+1};
            case 'targetdim'
                targetDim = varargin{i+1};
            case 'samplesize'
                sampleSize = varargin{i+1};
            case 'iter'
                iter = varargin{i+1};
        end
    end
    
    rng(42);
    warning('off')
    nViews = numel(X);
    S = cell(1, nViews);
    anchors = cell(1, nViews);
    
    %% 主循环
    for m = 1:nViews
        Xm = X{m};
        [n, d] = size(Xm);
        if ~isa(Xm,'single')
            Xm = single(Xm);
        end
        %% ===== 锚点 =====
        if d > 2000 && n > 10000
            % 投影矩阵
            R = randn(d, targetDim, 'single') / sqrt(targetDim);
            % 采样 or 全量
            if n > sampleSize
                idx = randperm(n, sampleSize);
                Xp = Xm(idx,:) * R;
            else
                idx = [];
                Xp = Xm * R;
            end
            % K-means（低维）
            [~, C] = kmeans(Xp, k, 'Start','plus','MaxIter',iter,'Replicates',1, 'EmptyAction', 'singleton');
            % 最近邻回原空间
            Dtmp = pdist2(C, Xp);
            [~, id] = min(Dtmp, [], 2);
            if isempty(idx)
                anchors{m} = Xm(id,:);
            else
                anchors{m} = Xm(idx(id),:);
            end
        else
            [~, anchors{m}] = kmeans(Xm, k, 'Start','plus','MaxIter',iter,'Replicates',1, 'EmptyAction', 'singleton');
        end
        
        % D = pd2(X{m}, anchors{m});
        D = pdist2(Xm, anchors{m}, 'euclidean');

        if isempty(sigma)
            minD = min(D, [], 2);
            sigma_m = median(minD(minD > 0));
            if sigma_m == 0, sigma_m = mean(D(:)); end
        else
            sigma_m = sigma;
        end
        
        W = exp(-D.^2 / (2*sigma_m^2));
        % W = double(W);
        S{m} = W ./ max(sum(W,2), 1);
    end
end