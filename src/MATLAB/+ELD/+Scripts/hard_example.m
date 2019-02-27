X = zeros(2,200);
X(1,1:2:200) =1+rand(1,100);
X(2,2:2:200) =1+rand(1,100);
figure,imshow(X,[])
