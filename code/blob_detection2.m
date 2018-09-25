img = im2double(imread('..\data\sunflowers.jpg')); %image to process

img = rgb2gray(img);
imgTemp = img;
levels = 15; %levels of processing
tHold = 0.03; %threshold
K = 2^0.5; %multiplication factor for sigma
sigma = 0.5;
sigmaTemp = sigma;
result = [];
scale = []; %scale space
rad = []; %array fo  r radius of blobs
tic %start stopwatch
[row, column] = size(img);
filter = sigmaTemp^2 * fspecial('log', 2*ceil(3*sigma)+1, sigma);
for i = 1: levels
    filteredImg = imfilter(img, filter, 'replicate');
    filteredImg = abs(filteredImg);
    filteredImg = imresize(filteredImg, [row column]);
    scale = cat(3, scale, filteredImg);
    if(sigmaTemp < 1)
        img = imresize(img, sigmaTemp);
    else
        img = imresize(img, 1/sigmaTemp);
    end
    sigmaTemp = sigmaTemp * K;
end

img = imgTemp;
[resultTest, idx] = max(scale, [], 3);
B = ordfilt2(resultTest, 25, ones(5));
C = (resultTest == B) & (B > tHold); %decresing the treshold with scale space results in much better results
C = C .* B;

[x, y] = size(C);
for i = 1: x
    for j = 1: y
        if(C(i, j) == 0)
            idx(i, j) = 0;
        end
    end
end

[cx, cy] = find(idx);

for i = 1: length(cx)
    if (idx(cx(i), cy(i)) - 1) == 0
        radius = sigma * 2^0.5;
    else
        radius = ((idx(cx(i), cy(i)) - 1) * K * sigma)* 2^0.5;
    end
    rad = cat(1, rad, radius);
end
toc %output stopwatch time
% show_all_circles(img,cy,cx,rad);