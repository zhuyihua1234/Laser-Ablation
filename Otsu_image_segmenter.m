%Clear Memory
clear all;

%Import Dark Corner Correction Map
load('C:\Research\UCSF\GitHub_Repositories\Laser Ablation\dark_corner_correction.mat');

%Import image
file = uigetfile('*.*');
raw_img = load(file);
gray_img = mat2gray(raw_img);
corr_img = gray_img + 0.1*comp_img;
norm_img = mat2gray(corr_img);
variableName = 'BW';

%%
%Call Adaptive Image Segmenter
imageSegmenter(norm_img);

while ~exist(variableName, 'var')
    % Keep checking if the variable exists in the workspace
    pause(1); % Adjust the pause duration as needed
end

imageSegmenter close

%%
% Shift Segmentation to correct image
BW = imtranslate(BW,[-7.0554,-4.2666]);

% Display the binary mask image
figure;
imshow(BW);
title('Binary Mask');

% Find connected components in the binary mask
cc = bwconncomp(BW);

% Get properties of all connected components
props = regionprops(cc, 'all');

% Prompt the user to click on regions
disp('Click on regions to select them. Press "return" to finish.');

% Initialize an array to store selected regions
selectedRegions = [];

while true
    [x, y] = ginput(1); % Wait for user input
    
    % Check if the user pressed "return"
    if isempty(x)
        break; % Exit the loop if "return" is pressed
    end
    
    % Convert clicked (x, y) coordinates to (row, column) format
    clickedRow = round(y);
    clickedColumn = round(x);
    
    % Find the component index corresponding to the clicked pixel
    clickedComponentIndex = 0;

    for i = 1:cc.NumObjects
        % Check if the clicked coordinates fall within the region's PixelIdxList
        if ismember(sub2ind(size(BW), clickedRow, clickedColumn), cc.PixelIdxList{i})
            clickedComponentIndex = i;
            break;
        end
    end

    % Check if a valid region was clicked
    if clickedComponentIndex > 0
        selectedRegion = props(clickedComponentIndex);
        selectedRegions = [selectedRegions; selectedRegion];
        disp('Selected region properties have been added to the list.');
        
        % Display the selected region using its bounding box
        selectedRegionImage = false(size(BW));
        selectedRegionImage(cc.PixelIdxList{clickedComponentIndex}) = true;
        
        hold on;
        plot(selectedRegion.BoundingBox(1), selectedRegion.BoundingBox(2), 'ro');
        hold off;
    else
        disp('No region selected.');
    end
end

% Display the final segmentation with all selected regions
disp('Displaying the final segmentation.');
finalSegmentation = false(size(BW));
for i = 1:size(selectedRegions, 1)
    selectedRegionIndices = cat(1, selectedRegions.PixelIdxList);
    finalSegmentation(selectedRegionIndices) = true;
end

figure;
imshow(finalSegmentation);
title('Final Segmentation');
%%
dlmwrite('ROI',finalSegmentation,'delimiter','	')
