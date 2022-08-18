%% Convert the label of superpixels to the corresponding segmentation result of the image
%input: the clustering result of superpixels, the number of superpixels, the original image, and the linear index corresponding to each area of the superpixel label matrix
%output: the image segmentation

function I_seg=LabelToImage(SP_L,N,I_ori,idx)
[w,h,~]=size(I_ori);
%% Convert superpixels' label to pixels' label
label=zeros(w*h,1);%pixels' label
for labelVal=1:N
    id=idx{labelVal};
    label(id)=SP_L(labelVal);
end
%% Convert the label of pixels to the corresponding segmentation result of the image
I_seg=zeros(w*h,3);
A = reshape(I_ori(:, :, 1), w*h, 1);  
B = reshape(I_ori(:, :, 2), w*h, 1);
C = reshape(I_ori(:, :, 3), w*h, 1);
data = [A B C];
data=double(data);
K=max(SP_L);
for i=1:K
    label_K=find(label==i);
    I_seg(label_K,:)=I_seg(label_K,:)+mean(data(label_K,:));
end
I_seg=uint8(reshape(I_seg,w,h,3));
