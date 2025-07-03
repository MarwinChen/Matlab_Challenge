function generateVisualizations(I1, I2, diffImage, BW_clean)

% 并排显示原图
figure;
imshowpair(I1, I2, 'montage');
title('Original Images');

% 差分图
figure;
imshow(diffImage, []);
title('Difference Image');

% overlay
overlayImage = imoverlay(I1, BW_clean, [1 0 0]);
figure;
imshow(overlayImage);
title('Change Mask Overlay');

% Pie chart
changeRatio = sum(BW_clean(:)) / numel(BW_clean);
figure;
pie([changeRatio, 1-changeRatio]);
legend('Changed','Unchanged');
title('Change Ratio');

end
