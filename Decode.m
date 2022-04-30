close all; clc; clear all;

stego_image = imread('stegoImage.png');
[w,h]= size(stego_image);
%Clearing 5 Least significant bits with and operation
bit_And=zeros(256,256);
lsb_5 =uint8(224); % 224 equal to 11100000
for i=1:1:256
for j=1:1:256
    bit_And(i,j) = bitand(stego_image(i,j),lsb_5);
end
end

% Canny Sobel edge detection
edge_Can = edge(bit_And,'canny');
edge_Sob = edge(bit_And,'sobel');
edge_Hybrid = bitor(edge_Can,edge_Sob);


%dilation process
se = strel([0 1 0; 1 1 1; 0 1 0]); 
dilatedHB = imdilate(edge_Hybrid, se);

%edge area not edge area based on Hybrid detection
edgePixels = times(uint8(dilatedHB),stego_image);
dilated_Not = ~dilatedHB;
notEdgePixels = times(uint8(dilated_Not),stego_image);


% decode kismi imgeden mesaji cekme 
harf = 30; % bunu Messaja gore degistirmem gerekiyor 
harf2 = harf;
harf3 = harf;
x = zeros(1,harf);
y = zeros(1,harf);
lsb_4 =uint8(15);
lsb_3 =uint8(7);
g= 1;
bah_x=uint8(x);
bah_y=uint8(y);
for i=1:1:w
for j=1:1:h
    if edgePixels(i,j) ~= 0 %Veri olup olmadigini kontrol et 
       edgePixels(i,j) = bitand(edgePixels(i,j),lsb_4);
       x(1,g) = bitor(edgePixels(i,j),bah_x(1,g));
       g=g+1;
       harf = harf-1;
    end
   
    if harf==0
        break
    end
end
    if harf==0
        break
    end
end
g2 = 1;
for i=1:1:w
for j=1:1:h
    if notEdgePixels(i,j) ~= 0 %Veri olup olmadigini kontrol et 
       notEdgePixels(i,j) = bitand(notEdgePixels(i,j),lsb_3);
       y(1,g2) = bitor(notEdgePixels(i,j),bah_y(1,g2));
       g2=g2+1;
       harf2 = harf2-1;
    end
   
    if harf2==0
        break
    end
end
    if harf2==0
        break
    end
end
y = bitshift(y,4);


%Finding message 
message = zeros(1,harf3);

for a=1:1:harf3
    message(1,a) = bitor(x(1,a),y(1,a));    
end
secret_message = char(message);
disp(secret_message);

%figure; imshow(edge_Can); title('Canny');
%figure; imshow(edge_Sob); title('Sobel');
%figure; imshow(edgePixels); title('Edge Pixels');
%figure; imshow(notEdgePixels); title('Not edge pixels');
%figure; imshow(dilatedHB); title('Dilated image');
figure; imshow(stego_image); title('stego image');