%Import Dark Corner Correction Map
load('C:\Research\UCSF\GitHub_Repositories\Laser Ablation\dark_corner_correction.mat');

%Import image
file = uigetfile('*.*');
raw_img = load(file);
norm_img = mat2gray(raw_img);
corr_img = norm_img + comp_img;
grayImage = mat2gray(corr_img);

selectedVariable = 'R'
%%
% Calculate the means for both lesion and sound
th = 0.2;
threshold = th*max(grayImage(:));
th_mask = grayImage > threshold;

meanGL = mean2(grayImage(th_mask));

% Get image dimensions
[rows,cols,channels] = size(grayImage);

if selectedVariable == 'R',
    % Reflectance

    % Define the transformation equation
    transformationEquation = @(x) (x - meanGL)/x; 
elseif selectedVariable == 'T',
    transformationEquation = @(x) (abs((meanGL - x)/meanGL));
else
    error('No variable selected.');
end

% Apply the equation to each pixel
for row = 1:rows
    for col = 1:cols
        for channel = 1:channels
            contrast_img(row, col) = transformationEquation(grayImage(row, col));
        end
    end
end


% Set contrast threshold
if selectedVariable == 'R',
    threshold = 0.10;
elseif selectedVariable == 'T',
    threshold = 0.10;
else
    error('No variable selected.');
end

% Create a mask for pixels with intensity above X
mask = contrast_img > threshold;

% Initialize the output image with zeros
outputImage = zeros(size(contrast_img), 'like', contrast_img);

% Apply the mask to the output image
outputImage(mask) = contrast_img(mask);

% Display the binary mask image
imshow(mask);
title('Binary Mask');

% Find connected components in the binary mask
cc = bwconncomp(mask);

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
    if ismember(sub2ind(size(mask), clickedRow, clickedColumn), cc.PixelIdxList{i})
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
    selectedRegionImage = false(size(mask));
    selectedRegionImage(cc.PixelIdxList{clickedComponentIndex}) = true;
    
    figure;
    imshow(selectedRegionImage);
    title('Selected Region');
else
    disp('No region selected.');
end

% Calculate the contrast within this ROI
ROI_contrast = mean(contrast_img(selectedRegionImage));
formattedLength = sprintf('%.6f', ROI_contrast);
disp(['Mean ROI Contrast: ' formattedLength]);
% Display Area of the ROI
disp(['Number of pixels in the ROI: ' num2str(selectedRegion.Area)]);
