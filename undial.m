%Linear Systems 2 Term Project
%DTMF decoder using filter banks
%Group: Signal Separators
%Members: Nat Rojvachiranonda, Sasha Zelenski, Tuoheng Zheng

close all;
clear all;

%Record sound
% fs = 8000;
% rec = audiorecorder(fs,16,1); %sample rate, bit per sample, channel
% disp('Press ENTER to start and stop recording');
% pause;
% disp('Recording...');
% record(rec);
% pause;  %Wait for second ENTER to stop recording
% stop(rec);
% disp('Processing...');
% 
% %For testing purposes
% disp('Press ENTER to playback recording');
% pause;
% play(rec);
% 
% %Recording plot
% y = getaudiodata(rec);
%-------------------------------------------------------------------------

%Load file
cd C:\Users\rojva\Documents\GitHub\ls2teamproj; %cd to my github directory
currentFolder = pwd;     %get current folder address
%add folders to file path
addpath(append(currentFolder,'\Testing samples\With noise'));
addpath(append(currentFolder, '\Testing samples\Without noise'));
fileName = '1234567890_n.wav';
[y,fs] = audioread(fileName);

fn = fs/2;

%scale yvals for consistency to always be around 1
y = y - mean(y); 
ymax = max(y);
ymin = min(y);
scale = (ymax - ymin)/2; 
y = y/scale;

%Reducing noise
y = highpass(y,670,fs);
y = lowpass(y,1475,fs);
y = bandstop(y,[960 1180],fs);

%Plot raw data for testing
figure;
subplot(2,1,1);
plot(y);
title('Raw data');
subplot(2,1,2);
pwelch(y,[],[],[],fs);
%-------------------------------------------------------------------------

%Filtering 697 Hz
y697 = customCheby2(1,15,fn,697,y);

%plotting the filtered signal
figure;
subplot(4,1,1);
plot(y697);
title('697 Hz');
% subplot(2,1,2);
% pwelch(y698,[],[],[],fs);
%-------------------------------------------------------------------------

%Filtering 770 Hz
y770 = customCheby2(1,10,fn,770,y);

%plotting the filtered signal
subplot(4,1,2);
plot(y770);
title('770 Hz');
%-------------------------------------------------------------------------

%Filtering 852 Hz
y852 = customCheby2(1,10,fn,852,y);

%plotting the filtered signal
subplot(4,1,3);
plot(y852);
title('852 Hz');
%-------------------------------------------------------------------------

%Filtering 941 Hz
y941 = customCheby2(1,10,fn,941,y);

%plotting the filtered signal
subplot(4,1,4);
plot(y941);
title('941 Hz');
%-------------------------------------------------------------------------

%Filtering 1209 Hz
y1209 = customCheby2(1,10,fn,1209,y);

%plotting the filtered signal
figure;
subplot(3,1,1);
plot(y1209);
title('1209 Hz');
%-------------------------------------------------------------------------

%Filtering 1336 Hz
y1336 = customCheby2(1,10,fn,1336,y);

%plotting the filtered signal
subplot(3,1,2);
plot(y1336);
title('1336 Hz');
%-------------------------------------------------------------------------

%Filtering 1477 Hz
y1477 = customCheby2(1,10,fn,1477,y);

%plotting the filtered signal
subplot(3,1,3);
plot(y1477);
title('1477 Hz');
%-------------------------------------------------------------------------

% PUT IN KRUGER'S PHONE # AND CARRIER HERE
 %send_text_message('319-457-6000', 'T-Mobile',...
 %'Hi Professor Kruger!', 'Test Message');
 
%-------------------------------------------------------------------------
%Functions:

%Custom Cheby2 filter. Finds minimum required order and applies to filter
%to filter the signal x.
%Outputs y. 
%Inputs: ripple passband, stopband attenuation,
%normalized freq, frequency to filter, input signal.
function y = customCheby2(rp,rs,fn,f,x)
    wp1 = f - 3;    %bandpass freq 1
    wp2 = f + 3;    %bandpass freq 2
    ws1 = wp1 - 5;  %bandstop freq 1
    ws2 = wp2 + 5;  %bandstop freq 2
    [n,ws] = cheb2ord([wp1 wp2]/fn,[ws1 ws2]/fn, rp,rs); %finds order
    [z,p,k] = cheby2(n,rs,ws);  %[zeros, poles, gain]
    [sos,g] = zp2sos(z,p,k);    %second order section conversion
    y = filtfilt(sos,g,x);      %filters signal
    %Here [zeros, poles, gain] is used. According to documentation of cheby2,
    %[b,a] runs into numerical round-off errors. It also says to convert to 
    %second order section using zp2sos. Looking more into zp2sos, it outputs
    %the second order section as well as the gain which is equivalent to
    %transfer function. Similar to [b,a].
end

% Function for separating the signal
% Input 'data' which should be our cleaned signal 'yf' in this case
% Spit out a 'signal' matrix which contains each separated signal segment..
% ..in each row of the matrix, the segments are what we will filter
function signal = separate_Signal(data)
    [~,locs] = findpeaks(data,'MinPeakDistance',1000,'MinPeakHeight',0.5);  % find important peaks 
    minLength = 500;                    % set the min length of signal to 2 * 500
    if locs(1) < minLength                        
            signal(1,:) = yf(1:1000);
        else
            signal(1,:) = yf(locs(1)-minLength : locs(1)+minLength);
    end

    for i = 2 : length(locs)            % loop over and assign content for each separated signal
        signal(i,:) = yf(locs(i)-minLength : locs(i)+minLength-1)';
    end
end