%% get the SSE of K  
%input: the number of clusters, the number of superpixels, the descending order of ri, the feautures of superpixels, the sorting of extended relative density, 
%and input: the data points with higher local density of all data points in nneigh, and ratio to find the proportion of Lab features in the feature distance 
%output: the sum of squared errors (SSE) of the evaluation clustering results under different number of clusters


function SSE=SSE_K(K,N,ord_ri,SP_features,ord,nneigh,ratio)
    for i=1:N
        SP_L(i)=-1;
    end
    for g=1:K
        SP_L(ord_ri(g))=g;
    end
    %% assignation
    for i=1:N
        if (SP_L(ord(i))==-1)
            SP_L(ord(i))=SP_L(nneigh(ord(i)));
        end
    end
    %% SSE
    temp1=0;
    temp2=0;
    for i=1:K
        index=(SP_L==i);
        x_temp=SP_features(index,:);
        u=mean(x_temp,1);
        for j=1:size(x_temp,1)
            temp1=temp1+abs(sqrt((1/3)*(sum((x_temp(j,1:3)-u(1:3)).^2))));
            temp2=temp2+abs(sqrt((1/9)*(sum((x_temp(j,4:12)-u(4:12)).^2))));       
        end
    end
   temp=ratio*temp1+(1-ratio)*temp2;
   SSE=temp;
end
