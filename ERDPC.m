%% ERDPC clustering
%Input the Lab features and HOG features of superpixels
%output the clustering results of superpixels

function SP_L=ERDPC(SP_features,N)
SP_Lab=SP_features(:,1:3);
SP_HOG=SP_features(:,4:12);

%% the distance between the features of superpixels
ratio=0.8;
for i=1:N
    for j=1:N
        d_color=abs(sqrt((1/3)*((SP_Lab(i,1)-SP_Lab(j,1)).^2+(SP_Lab(i,2)-SP_Lab(j,2)).^2+(SP_Lab(i,3)-SP_Lab(j,3)).^2)));
        d_hog=abs(sqrt((1/9)*(sum((SP_HOG(i,:)-SP_HOG(j,:)).^2))));
        dist(i,j)=ratio*d_color+(1-ratio)*d_hog;
    end
end

%% the process of ERDPC
Relative_rho=zeros(N,1);
k=15;
KNN=inf(N,k);
ind=ones(N,k);
for i=1:N
    dd(i,:)=dist(i,:);
    dd(i,i)=inf;
    [dist_sorted(i,:),ord_dist(i,:)]=sort(dd(i,:));
    KNN=dist_sorted(i,1:k);
    ind(i,:)=ord_dist(i,1:k);
    tightness(i,:)=k/sum(KNN);
end
tightness=(tightness-min(tightness))./(max(tightness)-min(tightness));

for i=1:N
    for j=1:k
        if(tightness(i)>=tightness(ind(i,j)))
            Relative_rho(i)=Relative_rho(i)+1;
        end
    end
end
%% get the density and sort all data points in descending order
Expanded_Relative_rho=Relative_rho+tightness;
Expanded_Relative_rho=(Expanded_Relative_rho-min(Expanded_Relative_rho))./(max(Expanded_Relative_rho)-min(Expanded_Relative_rho));
[~,ord]=sort(Expanded_Relative_rho,'descend');

%% get the delta
delta=Inf(N,1);
nneigh=zeros(N,1);
delta(ord(1))=-1.;
nneigh(ord(1))=0;
for i=2:N
    for j=1:i-1
        if(dist(ord(i),ord(j))<delta(ord(i)))
            delta(ord(i))=dist(ord(i),ord(j));
            nneigh(ord(i))=ord(j);
        end
    end
end
delta(ord(1))=max(dist(ord(1),:));
delta=(delta-min(delta))./(max(delta)-min(delta));
%% adjust delta of each data point using the Sigmoid function
delta_=1./(1+exp(-10*(delta-0.5)));
ri=Expanded_Relative_rho.*delta_;
[~,ord_ri]=sort(ri,'descend');

%% get the cluster numbers
epsilon=0.065;
K_set=2:1:10;
l=length(K_set);
for i = 1:l
    PHI(i)=PHI_K(K_set(i),N,ord_ri,SP_features,ord,nneigh,ratio);
end
ii=1;
for i=1:l
    if(PHI(ii)<epsilon)
        break
    else
        ii=ii+1;
    end
end
K=ii;

%% get the cluster centers according to the number of clusters
for i=1:N
    SP_L(i)=-1;%SP_l is the label of superpixels
end

for g=1:K
    SP_L(ord_ri(g))=g;
    centers(g,:)=SP_features(ord_ri(g),:);
end

%% Merge the cluster centers
th=0.08;
p=1:K;
c_delete=[];%points to be deleted
K_=K;
for g=1:K-1
    for h=g+1:K
        temp1=abs(sqrt((1/3)*(sum((centers(g,1:3)-centers(h,1:3)).^2))));
        temp2=abs(sqrt((1/9)*(sum((centers(g,4:12)-centers(h,4:12)).^2))));
        dist2(g,h)=ratio*temp1+(1-ratio)*temp2;
        if((dist2(g,h))<th)
            if(p(g)<p(h))
                c_delete=[c_delete,h];
                p(h)=p(g);
                SP_L(find(SP_L==h))=p(g);
                K_=K_-1;
            else
                c_delete=[c_delete,g];
                p(g)=p(h);
                SP_L(find(SP_L==g))=p(h);
                K_=K_-1;
            end
        end
    end
end
centers(c_delete,:)=[];
K=K_;

%% assignation
for i=1:N
    if (SP_L(ord(i))==-1)
        SP_L(ord(i))=SP_L(nneigh(ord(i)));
    end
end
end
