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
% plot(y);
%-------------------------------------------------------------------------

%Load file

cd C:\Users\zelen\Documents\GitHub\ls2teamproj %cd to my github directory
currentFolder = pwd;                                               %get curr folder address
addpath(append(currentFolder,'\Testing samples\With noise'));   %add folders to file path
addpath(append(currentFolder, '\Testing samples\Without noise'));   %add folders to file path
fileName = '1234567890.wav';
[y,fs] = audioread(fileName);
y = y - mean(y); 
ymax = max(y);
ymin = min(y);
scale = (ymax - ymin)/2; %scale yvals for consistency to always be around 1
y = y/scale;

fn = fs/2;

%Plot raw data for testing
figure;
subplot(2,1,1);
plot(y);
title('Raw data');
subplot(2,1,2);
pwelch(y,[],[],[],fs);
%-------------------------------------------------------------------------

%Reducing noise (bandpass for the whole range of DTMF frequencies)
rp = 1;     %ripple passband
rs = 150;   %ripple stopband
[n,ws] = cheb2ord([695 1481]/fn,[689 1483]/fn, rp,rs);
[z,p,k] = cheby2(n,rs,ws);  %[zeros, poles, gain]
[sos,g] = zp2sos(z,p,k);    %second order section conversion
%fvtool(sos)                 %plotting the filter
yf = filtfilt(sos,g,y);
%Here [zeros, poles, gain] is used. According to documentation of cheby2,
%[b,a] runs into numerical round-off errors. It also says to convert to 
%second order section using zp2sos. Looking more into zp2sos, it outputs
%the second order section as well as the gain which is equivalent to
%transfer function. Similar to [b,a].

%plot signal
figure;
subplot(2,1,1);
plot(yf);
title('Reduced noise');
subplot(2,1,2);
pwelch(yf,[],[],[],fs);
%-------------------------------------------------------------------------

% separate signals
signal = separate_Signal(yf);

%--------------------------------------------------------------------------

% y698 = filter_697Hz(signal(1,:));
% for i = 1:10
%     % put each segment into each filters
% end




%Testing with bandpass()
% yf = bandpass(y,[500 1700],8000);
% figure;
% subplot(2,1,1);
% plot(yf);
% subplot(2,1,2);
% pwelch(yf,[],[],[],fs);

% figure;
% y698 = bandpass(y,[690 700],8000);
% subplot(4,1,1);
% pwelch(y698,[],[],[],fs);
% y770 = bandpass(y,[765 775],8000);
% subplot(4,1,2);
% pwelch(y770,[],[],[],fs);
% y852 = bandpass(y,[845 860],8000);
% subplot(4,1,3);
% pwelch(y852,[],[],[],fs);
% y941 = bandpass(y,[938 949],8000);
% subplot(4,1,4);
% pwelch(y941,[],[],[],fs);
% 
% y1209 = bandpass(y,[1200 1215],8000);
% y1336 = bandpass(y,[1330 1345],8000);
% y1477 = bandpass(y,[1470 1480],8000);
%-------------------------------------------------------------------------

%Filtering 697 Hz
rp = 1;     %ripple passband
rs = 150;   %ripple stopband
[n,ws] = cheb2ord([695 700]/fn,[689 707]/fn, rp,rs);
[z,p,k] = cheby2(n,rs,ws);  %[zeros, poles, gain]
[sos,g] = zp2sos(z,p,k);    %second order section conversion
%fvtool(sos)                 %plotting the filter
y698 = filtfilt(sos,g,y); %filter signal
%Here [zeros, poles, gain] is used. According to documentation of cheby2,
%[b,a] runs into numerical round-off errors. It also says to convert to 
%second order section using zp2sos. Looking more into zp2sos, it outputs
%the second order section as well as the gain which is equivalent to
%transfer function. Similar to [b,a].

%plotting the filtered signal
figure;
subplot(2,1,1);
plot(y698);
title('698 Hz');
subplot(2,1,2);
pwelch(y698,[],[],[],fs);


% PUT IN KRUGER'S PHONE # AND CARRIER HERE
 %send_text_message('319-457-6000', 'T-Mobile',...
 %'Hi Professor Kruger!', 'Test Message');


 
 
 
% Function for separating the signal
% Input 'data' which should be our cleaned signal 'yf' in this case
% Spit out a 'signal' matrix which contains each separated signal segment..
% ..in each row of the matrix, the segments are what we will filter
function signal = separate_Signal(data)
    [~,locs] = findpeaks(data,'MinPeakDistance',1000,'MinPeakHeight',0.5);  % find important peaks 
    minLength = 500;                    % set the min length of signal to 2 * 500
    if locs(1) < minLength                        
            signal(1,:) = data(1:1000);
        else
            signal(1,:) = data(locs(1)-minLength : locs(1)+minLength);
    end

    for i = 2 : length(locs)            % loop over and assign content for each separated signal
        signal(i,:) = data(locs(i)-minLength : locs(i)+minLength-1)';
    end
end
