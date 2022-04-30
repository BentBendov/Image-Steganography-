 close all; clc; clear all;

%I1= imread('lena_std.tif');
%I1= imread('f16.tiff');
%I1= imread('peppers.png');
I1= imread('baboon.png');
%I2= imread('goldhill.png');

I2 = rgb2gray(I1);

I_original = imresize(I2, [256 256]);  % 256x256 pixel goruntu lazim
I_copy = imresize(I2, [256 256]);

%Clearing 5 Least significant bits with and operation
bit_And=zeros(256,256);
lsb_5 =uint8(224); % 224 equal to 11100000
for i=1:1:256
for j=1:1:256
    bit_And(i,j) = bitand(I_copy(i,j),lsb_5);
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
edgePixels = times(uint8(dilatedHB),I_original);
dilated_Not = ~dilatedHB;
notEdgePixels = times(uint8(dilated_Not),I_original);

% mesaji bite donusturmek 3MSB yi y atamak 4LSB yi xe atamak
message = fileread('test.txt');
message_binary = dec2bin(message, 7); % gorsel olarak gorebilmem icin koda bir etkisi yok 
message_double=double(message);
[v,harf] =size(message_double);

lsb_4 =15;                          % corresponds to 00001111
msb_3 =112;                         % corresponds to 01110000
% x y olushturma islemi
x= zeros(1,harf);
y= zeros(1,harf);
for a=1:1:harf
    x(1,a)=bitand(message_double(1,a),lsb_4); % 00001111
    y(1,a)=bitand(message_double(1,a),msb_3); % 01110000
end
y = bitsra(y, 4); %bitshft to right   01110000  to -> 00000111


% Message embedding xbits to Edge pixels
[w,h]= size(edgePixels);
msb_4 =uint8(240); % Corresponds to 11110000
count = 0;
g = 1;
bah_x = uint8(x);
edge_pixelsx = zeros(w,h,'uint8');
for i=1:1:w
for j=1:1:h
    if edgePixels(i,j)~= 0 %Pixelde veri olup olmadigini test et
        edge_pixelsx(i,j) = bitand(edgePixels(i,j),msb_4); %4lsb temizle
        edgePixels(i,j) = bitor(edge_pixelsx(i,j),bah_x(1,g)); %xle or la 
        count = count +1;
        g = g+1;
    end
    if count == harf
        break
    end
   
end
    if count ==harf
        break
    end
end

% Message embedding y bits to not Edge pixels
notEdgeLSB_3 = uint8(248);
count2 = 0;
s = 1;
bah_y = uint8(y);
edge_pixelsy = zeros(w,h,'uint8');
for n=1:1:w
for m=1:1:h
    if notEdgePixels(n,m)~= 0 %Pixelde veri olup olmadigini test et
        edge_pixelsy(n,m) = bitand(notEdgePixels(n,m),notEdgeLSB_3); %3 lsb temizle
        notEdgePixels(n,m) = bitor(edge_pixelsy(n,m),bah_y(1,s)); %y yi ekle 
        count2 = count2 +1;
        s = s+1;
    end
    if count2 == harf
        break
    end
   
end
    if count2 ==harf
        break
    end
end

% edge ve edge olmayan pixelleri birlestirip stego image ulusturulmasi
stego_image = zeros(w,h,'uint8');
for r=1:1:w
for t=1:1:h
    stego_image(r,t) = bitor(notEdgePixels(r,t),edgePixels(r,t));
end
end
stego_image_deneme =  zeros(w,h,'uint8');
for r=1:1:w
for t=1:1:h
    stego_image_deneme(r,t) = bitor(edge_pixelsy(r,t),edge_pixelsx(r,t));
end
end
% son PSNR  hesaplamalar
peaksnr = psnr(stego_image,I_original);
mse = immse(stego_image, I_original);
ssimval = ssim(stego_image,I_original);


%imgenin yazdirilmasi
imwrite(stego_image,'stegoImage.png'); 
imwrite(I_original,'Original.png'); 




figure; imshow(I_original); title('Original image');
figure; imshow(stego_image); title('Stego image');

% figure; imshow(uint8(bit_And)); title('LSB edilen');
% figure; imshow(edge_Sob); title('Sobel');
% figure; imshow(edge_Can); title('Canny');
% figure; imshow(dilatedHB); title('Hybrid_dilated');
% figure; imshow(notEdgePixels); title('not edge pixels');
% figure; imshow(edgePixels); title('edge pixels');
% figure; imshow(edge_Hybrid); title('Hybrid');



