function [X,Y] = getADData(DataPath,Group,num_from,filter,seed,trim)
    % X: n*d, Y: N*C
    if nargin < 2
        Group = {'AD','CN','EMCI','LMCI','MCI'};
    end
    DataPath = {
        'Datasets\ADNI\DATA_MRI.csv';
        'Datasets\ADNI\DATA_PET.csv'
        };
    % AD: 148
    % CN: 141
    % EMCI: 116
    % LMCI: 100
    % MCI: 144
    % SMC: 59

    % Group = upper(Group);
    if nargin < 3
        num_from = 15;
    end
    if nargin < 4
        filter = false;
    end
    

    for ii = 1:length(DataPath)
        data = readtable(DataPath{ii,:},'VariableNamingRule','preserve');
        % 将所有 NaN 值替换为 0
        % 遍历每一列
        for k = 1:width(data)
            if isnumeric(data{:,k})  % 如果是数值列
                data{:,k} = fillmissing(data{:,k}, 'constant', 0);  % 将 NaN 替换为 0
            elseif iscellstr(data{:,k}) || isstring(data{:,k})  % 如果是字符串列
                % 替换字符串列中的 NaN 为字符串 '0'
                data{:,k} = fillmissing(data{:,k}, 'constant', '0');
            end
        end

        % data.Group(ismember(data.Group, 'SMC')) = {'MCI'};
        data = data(ismember(data.Group, Group), :); %()子表
        data = sortrows(data, 'Subject'); % 按 Subject 列排序

        if nargin >= 6 && trim
            if ii==1
                % 随机打乱行的顺序
                if nargin >=5
                    rng(seed);
                end
                randOrder = randperm(height(data));  % 获取随机的行索引
                rng('shuffle');
            end
            
            data = data(randOrder, :);  % 按随机顺序重新排列数据
            % data = data(ismember(data.Group, Group), :); %()子表
        
        
            g1 = data(ismember(data.Group, Group{1}), :);
            g2 = data(ismember(data.Group, Group{2}), :);
            n = min(height(g1),height(g2));
            g1 = g1(1:min(height(g1),n),:);
            g2 = g2(1:min(height(g2),n),:);
            data = [g1;g2];
        end

        if ii == 1
            n = size(data,1);
            Y = zeros(n,length(Group));
            for jj=1:n
                groupIndex  = strcmp(Group, data.Group{jj});
                Y(jj,:) = groupIndex;
            end  
        end
        data = data{:,num_from:size(data,2)}; % {}数组
        % % 检查每一行是否全为 0
        % zeroID = all(data == 0, 1);
        % data(:,zeroID) = 1;
        if filter
            filterNum = 0.02;
            data = data(:,mean(data,1) > filterNum);
            fprintf("过滤后的数据维度：%d\n",size(data,2));
        end
        % [data, ~] = Scaler().fit_transform(data);
        X{ii} = data;
    end
end

