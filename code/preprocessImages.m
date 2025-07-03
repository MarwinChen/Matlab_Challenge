function [images_registered, tforms] = preprocessImages(folderPath)
% preprocessImages 预处理一个文件夹里所有图片
%   [images_registered, tforms] = preprocessImages(folderPath)
%
% 输入:
%   folderPath - 存放卫星图片的文件夹路径
%
% 输出:
%   images_registered - cell array, 存放配准后的图像
%   tforms - cell array, 存放每张图像对应的 geometric transform 对象

%% Step 1 - 获取所有图片文件
% 支持 jpg, png 等格式
imageFiles = dir(fullfile(folderPath, '*.*'));
imageFiles = imageFiles(~[imageFiles.isdir]);

% 筛选常见格式
validExt = {'.jpg','.jpeg','.png','.tif','.tiff'};
imagePaths = {};
for k = 1:numel(imageFiles)
    [~,~,ext] = fileparts(imageFiles(k).name);
    if any(strcmpi(ext, validExt))
        imagePaths{end+1} = fullfile(folderPath, imageFiles(k).name);
    end
end

if isempty(imagePaths)
    error('未在指定文件夹中找到图片文件');
end

%% Step 2 - 读入所有图片并灰度化
images_gray = cell(1, numel(imagePaths));
for i = 1:numel(imagePaths)
    I = imread(imagePaths{i});
    if size(I,3)==3
        I = rgb2gray(I);
    end
    images_gray{i} = I;
end

%% Step 3 - Histogram Matching (亮度匹配)
% 以第一张图为基准
refImage = images_gray{1};
images_matched = cell(1, numel(images_gray));
images_matched{1} = refImage;
for i = 2:numel(images_gray)
    images_matched{i} = imhistmatch(images_gray{i}, refImage);
end

%% Step 4 - Image Registration (配准)
% 将所有图像配准到第一张图

images_registered = cell(1, numel(images_matched));
tforms = cell(1, numel(images_matched));

% 第一张不用变换
images_registered{1} = refImage;
tforms{1} = affine2d(eye(3));

for i = 2:numel(images_matched)
    moving = images_matched{i};

    % 特征检测
    ptsFixed = detectSURFFeatures(refImage, 'MetricThreshold', 500);
    ptsMoving = detectSURFFeatures(moving, 'MetricThreshold', 500);

    % 特征提取
    [featuresFixed, validPtsFixed] = extractFeatures(refImage, ptsFixed);
    [featuresMoving, validPtsMoving] = extractFeatures(moving, ptsMoving);

    % 匹配特征
    indexPairs = matchFeatures(featuresFixed, featuresMoving, ...
        'MatchThreshold', 10, 'MaxRatio', 0.6);

    matchedFixed = validPtsFixed(indexPairs(:,1));
    matchedMoving = validPtsMoving(indexPairs(:,2));

    if size(indexPairs,1) < 3
        warning('第 %d 张图像匹配点过少，跳过配准', i);
        images_registered{i} = moving;
        tforms{i} = affine2d(eye(3));
        continue;
    end

    % 估计变换
    tform = estimateGeometricTransform2D(matchedMoving, matchedFixed, ...
        'similarity', 'MaxDistance', 4);

    % 应用变换
    outputView = imref2d(size(refImage));
    registered = imwarp(moving, tform, 'OutputView', outputView);

    images_registered{i} = registered;
    tforms{i} = tform;
end

fprintf('共完成 %d 张图像的预处理\n', numel(images_registered));

end
