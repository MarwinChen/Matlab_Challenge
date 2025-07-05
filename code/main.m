%% main.m

% 定义路径
folderPath = '..\Datasets\Privat\Chongming Island';

% 预处理
[images_registered, tforms] = preprocessImages(folderPath);

% 比较两张图
I1 = images_registered{1};
I2 = images_registered{end-1};

% 差分
[diffImage, BW_clean, changeRatio] = computeDifference(I1, I2);

% 可视化
generateVisualizations(I1, I2, diffImage, BW_clean);

% 变化类型
changeType = analyzeChangeType(BW_clean);

fprintf('变化区域占比：%.2f%%\n', changeRatio*100);
fprintf('变化类型：%s\n', changeType);
