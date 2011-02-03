function [C,n0] = estimatePower(img)
% estimatePower estimates the values of C and n0 from the image

n    = size(img,1); % assumes image is square
pwr  = 0.5*( mean( abs(fft(img,[],1)).^2, 2 )' + mean( abs(fft(img,[],2)).^2, 1) );
n0   = sqrt(mean(pwr(end/2-30:end/2+30))/n);
freq = [0:n/2-1,-n/2:-1]*2*pi/n;
C    = sqrt(mean(freq(3:6).^2.*pwr(3:6))/n);
