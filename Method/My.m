function [pred,F,Loss] = My(X,c,params)
    max_iter = 100;
    iter_tol = 1e-3;
    rho = 1e-4;
    rho_max = 1e8;
    rho_rate = 2;
    %%
    % warning('off');
    % profile on
   
    [n, ~, M, d] = getDataInfo(X);
    Loss = NaN(3,max_iter);

    a = params(1);
    b = params(2);
    t = params(3);
    X = TransposeXY(X);
    t = t * c;

    %% INIT
    Fm = cell(M,1);
    Fm(:) = {zeros(t,n)};

    C = cell(M,1);
    C(:) = {eye(t,t)};
    F = zeros(t,n);

    A = cell(M,1);
    for m=1:M
        A{m} = eye(d(m),t);
    end

    G = zeros(t, n, M + 1);
    R = G;


    %% 辅助变量
    tensorFR = G;
    rho2 = rho / 2;
    
    % I = eye(n);

    %% RUN
    for iter = 1:max_iter
        %% =========================Clients===========================
        % A
        for m=1:M
            [U,~,V] = svd(X{m}*Fm{m}', "econ");
            A{m} = U * V';
        end

        % Fm
        term2 = a + b + rho2;
        for m=1:M
            term1 = a * A{m}' * X{m} + b* C{m} * F + rho2 * (G(:,:,m) + (R(:,:,m)/rho));
            Fm{m} = term1 / term2;
        end

        %% =========================Server============================
        % C
        for m=1:M
            [U,~,V] = svd(Fm{m} * F', "econ");
            C{m} = U * V';
        end

        % F
        term1 = rho2 + b * M;
        term2 = rho2* ( G(:,:,M+1) + (R(:,:,M+1)/rho) );
        for m=1:M
            term2 = term2 + b* C{m}' * Fm{m};
        end
        F = term2 / term1;

        % G
        % size = [d, N, M]
        tensorFR(:,:,M+1) = F - (R(:,:,M+1)/rho);
        for m=1:M
            tensorFR(:,:,m) = Fm{m} - (R(:,:,m)/rho);
        end
        ref = 1 / rho;
        [G, ~] = TNN(tensorFR,ref,2);

        % R
        R(:,:,M+1) = R(:,:,M+1) + rho*( G(:,:,M+1) - F );
        for m=1:M
            R(:,:,m) = R(:,:,m) + rho*( G(:,:,m) - Fm{m} );
        end

        rho = min(rho_max,rho_rate*rho);
        rho2 = rho / 2;

        %% 收敛
        err1 = norm(G(:,:,M+1) - F,inf);
        for m=1:M
            err1 = max(norm(G(:,:,m) - Fm{m},inf),err1);
        end
        Loss(1,iter) = err1;
        if err1 < iter_tol && iter > 2 
            break;
        end

    end
    rng('default')
    rng(42);  % Set random seed for reproducibility
    % plot(Loss(1,:));
    [pred,F] = SpectralClustering(F', c, 1);
end
