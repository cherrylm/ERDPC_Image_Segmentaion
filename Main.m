%read the image
%output:?the segmentation result
clear all
close all

I_ori=imread('images/206097.jpg');
%% SLIC segmentation
N=200;
[label_,N] = superpixels(I_ori,N,'Compactness',20,'Method','slic','NumIterations',30);
idx = label2idx(label_);%Convert the area described by the label matrix to a linear index pixelIndexList
%% get Lab features and HOG features of superpixels
SP_features=getFeatures(I_ori,label_,N,idx);
%% ERDPC clustering
SP_L=ERDPC(SP_features,N);
%% Convert the label of superpixels to the corresponding segmentation result of the image
I_seg=LabelToImage(SP_L,N,I_ori,idx);
%% show result
figure
subplot(1,2,1); imshow(I_ori);
title('images');
subplot(1,2,2); imshow(I_seg);
title('ERDPC segmentation result');
