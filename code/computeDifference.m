function [diffImage, BW_clean, changeRatio] = computeDifference(I1, I2)

% 差分
diffImage = abs(double(I1) - double(I2));

% 二值化
BW = imbinarize(uint8(diffImage), 'adaptive', 'ForegroundPolarity','bright');

% 去噪
BW_clean = bwareaopen(BW, 50);

% 变化比例
changeRatio = sum(BW_clean(:)) / numel(BW_clean);

end
