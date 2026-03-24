function D = pd2(A, B)
    if nargin < 2 || isempty(B)
        B = A;
    end

    A2 = sum(A.^2, 2);
    B2 = sum(B.^2, 2);

    D = A2 + B2' - 2 * (A * B');
    D = max(D, 0);   % 数值稳定性
    D = sqrt(D);
end