%Clear Memory
clear all;

%Import Dark Corner Correction Map
load('C:\Research\UCSF\GitHub_Repositories\Laser Ablation\dark_corner_correction.mat');

%Import image
file = uigetfile('*.*');
raw_img = load(file);
gray_img = mat2gray(raw_img);
corr_img = gray_img + comp_img;
norm_img = mat2gray(corr_img);
variableName = 'BW';

%Call Adaptive Image Segmenter
imageSegmenter(norm_img);

while ~exist(variableName, 'var')
    % Keep checking if the variable exists in the workspace
    pause(1); % Adjust the pause duration as needed
end

%%
imageSegmenter close
% Display the binary mask image
imshow(BW);
title('Binary Mask');

% Find connected components in the binary mask
cc = bwconncomp(BW);

% Get properties of all connected components
props = regionprops(cc, 'all');

% Prompt the user to click on a region
disp('Click on a region to select it.');
[x, y] = ginput(1); % Wait for user input

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
    assignin('base', 'selectedRegion', selectedRegion);
    disp('Selected region properties have been loaded into the workspace.');
    
    % Display the selected region using its bounding box
    selectedRegionImage = false(size(BW));
    selectedRegionImage(cc.PixelIdxList{clickedComponentIndex}) = true;
    
    figure;
    imshow(selectedRegionImage);
    title('Selected Region');
else
    disp('No region selected.');
end
%%
imwrite(selectedRegionImage,'ROI.tif')
