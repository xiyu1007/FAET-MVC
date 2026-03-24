function onehot = label2onehot(y)
    % LABEL2ONEHOT 将类别标签转换为 one-hot 编码
    %
    % 输入:
    %   y - 类别标签向量/矩阵，值应为整数
    %
    % 输出:
    %   one-hot 编码矩阵
    
    % 将输入展平为列向量
    y = y(:);
    
    % 确定类别数
    num_class = numel(unique(y));
    % 样本数
    n = length(y);
    % 创建 one-hot 矩阵
    onehot = zeros(n, num_class);
    % 使用 sub2ind 进行高效赋值
    indices = sub2ind([n, num_class], (1:n)', y);
    onehot(indices) = 1;
end