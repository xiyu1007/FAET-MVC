function [X,Y] = getDARWINData()
    % 假设文件名为 'data.data'，第一行是属性名称，第一列是患者ID，最后一列是类别标签（status）
    filename = 'Datasets\DARWIN\data.csv';
    
    % 读取整个文件内容
    data = readtable(filename, 'Delimiter', ',', 'ReadVariableNames', true,'VariableNamingRule','modify');
    
    % 提取属性名称
    attributeNames = data.Properties.VariableNames;
    % 找到status列的位置
    classColIndex = find(strcmp(attributeNames, 'class'));  % 查找属性名
    % 提取类别标签（status列）
    Y = data{:, classColIndex};

    % 转换类别标签为数值（如果需要）
    Y = categorical(Y);
    Y = dummyvar(Y);

    featureColumns = setdiff(1:width(data), [1, classColIndex]);
    feature = data{:, featureColumns};
    % X = {feature};

    % % 标准化器
    [X_scaled, ~] = Scaler().fit_transform(feature);
    X = {X_scaled};
end



