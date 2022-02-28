% Domain Parameters:
% p = Field that curve is defined over
% a,b = Values define the curve
% g = Generator point
% n = prime order of g (smallest num s.t. n*g = elliptic identity)
% h = cofactor (number of points over curve n)
% Steps for public/private key pair
% 1. Each party select random value d s.t. 1 <= d <= n-1
% 2. Public: d*g = P = (xG, yG)
% 3. Send P to eachother 
% 4. Calculate 3rd point R = d*P
% *Note --> R = d * (other d) * G = (xR, yR) so both parties have same
%           coordinates. R is kept private. 
% 5. Use R as the key 
%% READING IMAGE
img =(imread('8-bit-256-x-256-Grayscale-Lena-Image_Q320.jpg'));
figure,imhist(img);
%A=(imread('8-bit-256-x-256-Grayscale-Lena-Image_Q320.jpg'));
%A=double(img)
[lt bt]=size(img);
%img=im2double(img);
input=img;
figure,imshow(img);
a = 1;
b = 3;
p = 31;
%plotElipticCurve(a, b)
% Select one of these points for g (change to random later)
points = getPoints(a, b, p);
%disp(points);
xG = points(1,1);
yG = points(1,2);
%disp(xG)
%disp(yG)
disp(['G: (' num2str(xG) ', ' num2str(yG) ')']);

% Compute 2g, 3g, ..., (n-1)G until a point at infinity 
% keep track of this number n as well as its cofactor h
[n, ordPoints] = computeOrder(xG, yG, a, p);
%%n==41
%disp(ordPoints)
%disp(n);
  
% Choose d s.t. 1 <= d <= n-1
% Compute d*g (ex if d = 5, find 5g)
d = 13;
xP = ordPoints(d,1);
yP = ordPoints(d,2);
%disp(xP)
%disp(yP)
disp(['Pa: (' num2str(xP) ', ' num2str(yP) ')']);
% Exchange points publically
% For now, just choosing another point manually
otherD = 17;
xQ = ordPoints(otherD,1);
yQ = ordPoints(otherD,2);
disp(['Pb: (' num2str(xQ) ', ' num2str(yQ) ')']);
% Compute d * (exchanged point)
% if d * (other d) >= n, wraparound with mod n
%otherD = 15;
%xPQ = xQ;
%yPQ = yQ;
for i = 1:otherD
    % Have to add (xQ, pQ) d times
    if xPQ == xQ && yPQ == yQ
        % Must double the point to start
        [xPQ, yPQ] = pointDouble(xPQ, yPQ, a, p);
    elseif xG == xPQ && yG == mod(-yPQ, p)
        % If the point is equal to the negative origin point, start from
        % the origin again
        [xPQ, yPQ] = pointDouble(xQ, yQ, a, p);
    else
        % Otherwise continue to add the point (in order to multiply by d)
        [xPQ, yPQ] = pointAdd(xQ, yQ, xPQ, yPQ, p);
    end
end

% Key has been generated 
disp(['KI: (' num2str(xPQ) ', ' num2str(yPQ) ')']);

otherD = 13;
xQ = ordPoints(otherD,1);
yQ = ordPoints(otherD,2);
% Compute d * (exchanged point)
% if d * (other d) >= n, wraparound with mod n
xPQ = xQ;
yPQ = yQ;
for i = 1:otherD
    % Have to add (xQ, pQ) d times
    if xPQ == xQ && yPQ == yQ
        % Must double the point to start
        [xPQ, yPQ] = pointDouble(xPQ, yPQ, a, p);
    elseif xG == xPQ && yG == mod(-yPQ, p)
        % If the point is equal to the negative origin point, start from
        % the origin again
        [xPQ, yPQ] = pointDouble(xG, yG, a, p);
    else
        % Otherwise continue to add the point (in order to multiply by d)
        [xPQ, yPQ] = pointAdd(xQ, yQ, xPQ, yPQ, p);
    end
end

% Key has been generated 
disp(['K1: (' num2str(xPQ) ', ' num2str(yPQ) ')']);
K1=[xPQ,yPQ];
otherD = 17;
xQ = ordPoints(otherD,1);
yQ = ordPoints(otherD,2);
% Compute d * (exchanged point)
% if d * (other d) >= n, wraparound with mod n
xPQ = xQ;
yPQ = yQ;
for i = 1:otherD
    % Have to add (xQ, pQ) d times
    if xPQ == xQ && yPQ == yQ
        % Must double the point to start
        [xPQ, yPQ] = pointDouble(xPQ, yPQ, a, p);
    elseif xG == xPQ && yG == mod(-yPQ, p)
        % If the point is equal to the negative origin point, start from
        % the origin again
        [xPQ, yPQ] = pointDouble(xG, yG, a, p);
    else
        % Otherwise continue to add the point (in order to multiply by d)
        [xPQ, yPQ] = pointAdd(xQ, yQ, xPQ, yPQ, p);
    end
end

% Key has been generated 
disp(['K2: (' num2str(xPQ) ', ' num2str(yPQ) ')']);
K2=[xPQ,yPQ];
%K1=[Xq,Yq]
%K2=[Xq,Yq]
I=[1 0;0 1];
K11=[K1;K2];
K12=I-K11;
K21=I+K11;
K22=-1*K11;
Km=mod([K11,K12;K21,K22],256);
disp(Km);
%self invertible key matrix generated by both th users
%Similarly reciever also generated the Km Key matrix
%nb=17;
%Pb=17(1,6)=(24,5)
%Ki=nb*Pa=17(3,23)=(20,5)=(x,y) Initial Key
%Compute K1,K2 as above
%figure,imshow(img);
%% ENCRYPTION
i=1;
while(i<=lt)
    j=1;
    while(j<=bt)
        p1=double([input(i,j);input(i,j+1);input(i,j+2);input(i,j+3)]);
        t=mod(Km*p1,256);
        input(i,j)=t(1);
        input(i,j+1)=t(2);
        input(i,j+2)=t(3);
        input(i,j+3)=t(4);
        j=j+4;
    end
    i=i+1;
end
%Open this to display the encryption results
encryptedimg=input;
figure,imshow(input);
%B=input;
%J1=entropy(input)
%B=double(input)
figure,imhist(input);
%% DECRYPTION
i=1;
while(i<=lt)
    j=1;
    while(j<=bt)
        p1=double([input(i,j);input(i,j+1);input(i,j+2);input(i,j+3)]);
        t=mod(Km*p1,256);
        input(i,j)=t(1);
        input(i,j+1)=t(2);
        input(i,j+2)=t(3);
        input(i,j+3)=t(4);
        j=j+4;
    end
    i=i+1;
end
%Open this to display the decryption results
figure,imshow(input);
figure,imhist(input);
%% FUNCTIONS
%{
MODULAR INVERSE FUNCTION
i=1;
function x = modinv(s1,m)
    m0=m;
    y=0;
    x=1;
    if(m==1);
        return;
    end
    while(a>1)
        q=floor(s1/m);%quotient
        t=m;
        %finding remainder 
        m=rem(s1,m);
        s1=t;
        t=y;
        %updating x and y
        y=x-q*y;
        x=t;
    end
    if (x<0)
        x=x+m0;
    end
end
%}