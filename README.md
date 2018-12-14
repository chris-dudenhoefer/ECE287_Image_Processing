# ECE287 Image Processing
Chris Dudenhoefer, Ye Qiao
## Overview
For our project we built an image processing algorithm capable of reading a 200x200 8-bit color image stored to ROM, processing and manipulating the image through various filters, and displaying the image to a computer monitor. Filters include 3 preset kernel convolution filters, a preset color inversion algorithm, and a custom kernel filter that sets kernel values based on user input. The algorithm was written with verilog, implemented on an Altera DE2-115 board, and displayed using VGA.

## Background Information
### Basics of Image Processing
When images are displayed on computers they can be broken down into individual pixels. Color photos have three color values per pixel- Red, Green, and Blue. These three colors are combined in different intensities to create the full color spectrum. Image files at there basis are simply lists of values designating the intensity of a given color in a given pixel. So as such, in order to manipulate or process an imag, all you do is perform carious computations with the values that designate color intensity. 

### Kernel Convolution
Kernel convolution is a method of image processing that involves manipulating the individual pixel values of an image by using an nxn "kernel" matrix (typically 3x3) to multiply corresponding values surrounding each pixel and then add them together and assign them to a particular pixel. The image below shows a kernel operation with a very simple kernel.

![](https://i.imgur.com/32VoQZ8.png)

this operation equates to assigning the center index a value of (40\*0)+(42\*1)+(46\*0)+(46\*0)+(50\*0)+(55\*0)+(52\*0)+(56\*0)+(58\*0). 
### Simple kernels
The most basic of all kernels is the identity matrix. When applied to an entire photo it returns the original photo. 

![](https://i.imgur.com/rjTJZwkb.png) 

If you increase the value of the identity matrix, it enhances the colors of the image, effectively brightening it. 

![](https://i.imgur.com/o5qWBwCb.png)

Another common kernel is the gaussian blur. This kernel uses the standard deviation to take an average of the surrounding values and apply it to the center.

![](https://i.imgur.com/zmoUxQNb.png)

For blurring kernels it is essential for the sum of all of the kernel values to equal 1 so this particular kernel must be divided by 16 in order to achieve the desired blur.

![](https://i.imgur.com/IOy28t6b.png)

Because kernel convolution requires 17 computations per pixel (9 multiplications and 8 additions), the total computational time can be very large and inefficient. This is why it is most commonly implemented through parallel multipliers simultaneously multiplying each kernel value allowing all kernel multiplications to be made in a single clock cycle rather than 9. 

## Design and Implementation
### Choosing a Picture
The first step in designing an image processor is choosing an image to test and process. Our primary constraint in choosing an image was memory. In order to execute the parallel processing necessary for kernel convolution we planned on storing the image in 9 different memories that could be simultaneously accessed. We chose to convert 900x900 jpg into a 200x200 8-bit color bitmap image. Whereas larger color picture formats typically use 3 individual values to represent the Red, Green, and Blue (RGB) values to represent the color intensities of each pixel, 8-bit condenses these 3 values into a singular 8-bit value (2-bits for blue, 3-bits each for green and red). This makes the image file much smaller and easier to process, which meets the needs of our project. We used Microsoft Paint to convert the original jpeg file (1) into 8-bit bitmap (2)

![](https://i.imgur.com/f3bS062m.jpg)(1)
![](https://i.imgur.com/GhSHN8B.jpg)(2)

and then used to following matlab script to convert the image into a .mif file that Quartus could read into its memory.

    clear;  
    clc;  
    n=40000;%200*200  
    mat = imread('mountain.bmp');
    mat = double(mat);
    fid=fopen('mountain.mif','w');
    fprintf(fid,'WIDTH=8;\n');
    fprintf(fid,'DEPTH=40000;\n');
    fprintf(fid,'ADDRESS_RADIX=UNS;\n'); 
    fprintf(fid,'DATA_RADIX=HEX;');  
    fprintf(fid,'CONTENT BEGIN\n');
    for i=0:n-1  
        x = mod(i,200)+1;  
        y = fix(i/200)+1;  
        k = mat(y,x);
    fprintf(fid,'\t%d:%x;\n',i,k);  
    end  
    fprintf(fid,'END;\n');  
    fclose(fid);

### Memory

![](https://i.imgur.com/RmFw5wxl.png)

### VGA

### Convolution 



## Results
When complete, our algorithm effectively stored and processed the image with the following filters:
### Identity
![](https://i.imgur.com/bhlHdb1.jpg)
### Brighten
![](https://i.imgur.com/h4TggeA.jpg)
### Gaussian Blur
![](https://i.imgur.com/CM3s4zZ.jpg)
### Invert
![](https://i.imgur.com/xfXMATc.jpg)
***
As well as our custom kernel function which can be seen in our demo video (click on image):

[![IMAGE ALT TEXT](https://i.imgur.com/QeWpsKZ.jpg)](https://youtu.be/2ujU9qDhLFA "ECE287 Final Project- Image Processor")






    
g
