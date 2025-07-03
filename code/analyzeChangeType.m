function changeType = analyzeChangeType(BW_clean)

areaPixels = sum(BW_clean(:));

if areaPixels > 10000
    changeType = 'Large Change';
else
    changeType = 'Small Change';
end

disp(['Detected Change Type: ', changeType]);

end
