clear all;
close all;

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
% separate signals
signal = separate_Signal(yf);

%--------------------------------------------------------------------------

y698 = filter_697Hz(signal(1,:));






% %Filtering 697 Hz
% rp = 1;     %ripple passband
% rs = 150;   %ripple stopband
% [n,ws] = cheb2ord([695 700]/fn,[689 707]/fn, rp,rs);
% [z,p,k] = cheby2(n,rs,ws);  %[zeros, poles, gain]
% [sos,g] = zp2sos(z,p,k);    %second order section conversion
% %fvtool(sos)                 %plotting the filter
% y698 = filtfilt(sos,g,y); %filter signal

%plotting the filtered signal
figure;
subplot(2,1,1);
plot(y698);
subplot(2,1,2);
pwelch(y698,[],[],[],fs);

%--------------------------------------------------------------------------


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

function Filtered_697Hz = filter_697Hz(signal)
    rp = 1;     %ripple passband
    rs = 150;   %ripple stopband
    [n,ws] = cheb2ord([695 700]/fn,[689 707]/fn, rp,rs);
    [z,p,k] = cheby2(n,rs,ws);  %[zeros, poles, gain]
    [sos,g] = zp2sos(z,p,k);    %second order section conversion
    %fvtool(sos)                 %plotting the filter
    Filtered_697Hz = filtfilt(sos,g,signal); %filter signal
end