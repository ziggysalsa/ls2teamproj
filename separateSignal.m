% separate the signal from time domain
% (Successed)

close all;
clear all;

% load file
[y,fs] = audioread('audiocheck.net_dtmf_319256780.wav');
fn = fs/2;  

%--------------------------------------------------------------------%

% plot original singal
figure;
subplot(2,1,1);
plot(y);
subplot(2,1,2);
pwelch(y,[],[],[],fs);

%--------------------------------------------------------------------%

% clean noise
rp = 1;     %ripple passband
rs = 150;   %ripple stopband
[n,ws] = cheb2ord([695 1481]/fn,[689 1483]/fn, rp,rs);
[z,p,k] = cheby2(n,rs,ws);  %[zeros, poles, gain]
[sos,g] = zp2sos(z,p,k);    %second order section conversion
%fvtool(sos)                 %plotting the filter
yf = filtfilt(sos,g,y);

%plot cleaned signal
figure;
subplot(2,1,1);
plot(yf);
subplot(2,1,2);
pwelch(yf,[],[],[],fs);

%--------------------------------------------------------------------%

[pks,locs] = findpeaks(yf,'MinPeakDistance',1000,'MinPeakHeight',0.5);  % find important peaks 

minLength = 500;                    % set the min length of signal to 2 * 500
if locs(1) < minLength                        
        signal(1,:) = yf(1:1000);
    else
        signal(1,:) = yf(locs(1)-minLength : locs(1)+minLength);
end
   
for i = 2 : length(locs)            % loop over and assign content for each separated signal
    signal(i,:) = yf(locs(i)-minLength : locs(i)+minLength-1)';
end

%plot signal
figure;
subplot(2,1,1);
plot(signal(6,:));
subplot(2,1,2);
pwelch(signal(6,:),[],[],[],fs);

%-----------------------------------------------------------------------%
% And I'll put this into a function
function signal = separate_Signal(data)
    [pks,locs] = findpeaks(data,'MinPeakDistance',1000,'MinPeakHeight',0.5);  % find important peaks 
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