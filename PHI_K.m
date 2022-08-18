%% get the PHI
%input: the number of clusters, the number of superpixels, the descending order of ri, the feautures of superpixels, the sorting of extended relative density, 
%input: the data points with higher local density of all data points in nneigh, and ratio to find the proportion of Lab features in the feature distance 
%output: the SSE change rate of the optimal number of clusters


function PHI=PHI_K(K,N,ord_ri,SP_features,ord,nneigh,ratio)
    SSE=SSE_K(K,N,ord_ri,SP_features,ord,nneigh,ratio);
    a=SSE_K(K-1,N,ord_ri,SP_features,ord,nneigh,ratio)-SSE;
    b=SSE_K(1,N,ord_ri,SP_features,ord,nneigh,ratio)-SSE;
    PHI=a/b;
end
