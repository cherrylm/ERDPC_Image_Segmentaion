%% get Lab features and HOG features for superpixels
%Input :the original image, the superpixel labels corresponding to all pixels, the number of superpixels, and the linear index corresponding to each area of the superpixel label matrix
%output: Lab and HOG features for output superpixels

function SP_features=getFeatures(I_ori,label_,N,idx)
%% the Lab feature of the superpixel
I=rgb2lab(I_ori);
%% Normalization
I_ori_L = I(:, :, 1);
I_ori_a = I(:, :, 2);
I_ori_b = I(:, :, 3);
L=(I_ori_L-min(min(I_ori_L)))/(max(max(I_ori_L))-min(min(I_ori_L)));
a=(I_ori_a-min(min(I_ori_a)))/(max(max(I_ori_a))-min(min(I_ori_a)));
b=(I_ori_b-min(min(I_ori_b)))/(max(max(I_ori_b))-min(min(I_ori_b)));
%% get Lab features and HOG features for superpixels
for labelVal = 1:N
    %Lab features
    Idx = idx{labelVal};
    Lab=[L(Idx),a(Idx),b(Idx)];
    SP_Lab(labelVal,:) = [mean(Lab)];%average lab value of the superpixels
    
    %HOG features
    clear SP
    [sp_w,sp_h]=find(label_==labelVal);
    cell_up=max(sp_w);
    cell_down=min(sp_w);
    cell_left=min(sp_h);
    cell_right=max(sp_h);
    d_h=cell_up-cell_down;
    d_w=cell_right-cell_left;
    %if the width or height of the superpixel is less than 16,extend to 16
    if (d_h<16)
        if(cell_down>(16-d_h))
            cell_down=cell_down-(16-d_h);
        else
            cell_up=cell_up+(16-d_h);
        end
    end
    if (d_w<16)
        if(cell_left>(16-d_w))
            cell_left=cell_left-(16-d_w);
        else
            cell_right=cell_right+(16-d_w);
        end
    end
    SP(:,:,1)=I(cell_down:cell_up,cell_left:cell_right,1);
    SP(:,:,2)=I(cell_down:cell_up,cell_left:cell_right,2);
    SP(:,:,3)=I(cell_down:cell_up,cell_left:cell_right,3);
    
    featureVector= extractHOGFeatures(SP);
    NN=numel(featureVector)/9;
    SP_shape= reshape(featureVector,NN,9);
    HOG(labelVal,:)=mean(SP_shape,1);%average HOG value of the superpixels
end
%% Normalization
for i=1:9
    SP_HOG(:,i)=(HOG(:,i)-min(HOG(:,i)))/(max(HOG(:,i))-min(HOG(:,i)));
end
SP_features=[SP_Lab SP_HOG];
end
