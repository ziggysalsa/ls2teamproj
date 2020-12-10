%Linear Systems 2 Term Project
%DTMF decoder using filter banks
%Group: Signal Separators
%Members: Nat Rojvachiranonda, Sasha Zelenski, Tuoheng Zheng

close all;
clear all;

%Record sound
fs = 8000;
rec = audiorecorder(fs,16,1); %Sample rate, bit per sample, channel
disp('Press ENTER to start and stop recording');
pause;
disp('Recording...');
record(rec);
pause;  %Wait for second ENTER to stop recording
stop(rec);

%For testing purposes
disp('Processing...');
play(rec);

%Recording plot
y = getaudiodata(rec);
y=y'; %transpose the y values 
fn = fs/2;

%Scale yvals for consistency to always be around 1
y = y - mean(y); 
ymax = max(y);
ymin = min(y);
scale = (ymax - ymin)/2; 
y = y/scale;

%Reducing noise
y = highpass(y,670,fs); %remove tones below 670 Hz
y = lowpass(y,1460,fs); %remove tones above 1460 Hz
y = bandstop(y,[980 1180],fs); %remove tones between 980 and 1180 Hz
%-------------------------------------------------------------------------

signals = separateSignal(y); %pass in time series to separate signal
phoneNo = zeros(1,size(signals,1)); %phoneNo is matrix of 0s with length of the separateSignal output

for i = 1:size(signals,1)
    %The filter bank
    y697 = customCheby2(1,20,fn,697,signals(i,:));
    y770 = customCheby2(1,20,fn,770,signals(i,:));
    y852 = customCheby2(1,20,fn,852,signals(i,:));
    y941 = customCheby2(1,20,fn,941,signals(i,:));
    y1209 = customCheby2(1,20,fn,1209,signals(i,:));
    y1336 = customCheby2(1,20,fn,1336,signals(i,:));
    y1477 = customCheby2(1,20,fn,1477,signals(i,:));

    %Finding the biggest frequency at each key press
    [~,lmax] = max([max(y697) max(y770) max(y852) max(y941)]);
    [~,rmax] = max([max(y1209) max(y1336) max(y1477)]);

    %Checking for the biggest frequencies and turning it into a number
    switch lmax
        case 1
            switch rmax
                case 1
                    phoneNo(i) = 1;
                case 2
                    phoneNo(i) = 2;
                otherwise
                    phoneNo(i) = 3;
            end
        case 2
           switch rmax
                case 1
                    phoneNo(i) = 4;
                case 2
                    phoneNo(i) = 5;
                otherwise
                    phoneNo(i) = 6;
            end 
        case 3
            switch rmax
                case 1
                    phoneNo(i) = 7;
                case 2
                    phoneNo(i) = 8;
                otherwise
                    phoneNo(i) = 9;
            end
        otherwise
            switch rmax
                case 1
                    phoneNo(i) = '*';
                case 2
                    phoneNo(i) = 0;
                otherwise
                    phoneNo(i) = '#';
            end
    end
end

%Print out number
fprintf('Phone Number: %u%u%u-%u%u%u-%u%u%u%u\n',phoneNo);

%Convert into string for send_text_message function
phoneNo = mat2str(phoneNo);
phoneNo(phoneNo == ' ') = [];
phoneNo(phoneNo == '[') = [];
phoneNo(phoneNo == ']') = [];

%-------------------------------------------------------------------------
% PUT IN KRUGER'S PHONE # AND CARRIER HERE
 send_text_message(phoneNo, 'T-Mobile','Hey Professor Kruger',...
     'Hurray');
% '3194576000' <- testing phone number
%-------------------------------------------------------------------------
%Functions:

% Function for separating the signal

% Outputs: matrix of signals. Each row is one key press
% Inputs: the recorded signal
function signal = separateSignal(data)
    % find important peaks 
    [~,locs] = findpeaks(data,'MinPeakDistance',1000,'Threshold',0.1); 
    minLength = 500;    % set the min length of signal to 2 * 500
    if locs(1) < minLength                        
            signal(1,:) = data(1:1000);
    else
            signal(1,:) = data(locs(1)-minLength : locs(1)+minLength);
    end

    % loop over and assign content for each separated signal
    for i = 2 : length(locs)
        signal(i,:) = data(locs(i)-minLength : locs(i)+minLength)';
    end
end

%Custom Cheby2 filter. Finds minimum required order and applies to filter
%to filter the signal x.
%Outputs: y. 
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

%Function to send text message to the phone number.
%Outputs: null
%Inputs: phone number, carrier, subject, message
function send_text_message(number,carrier,subject,message)
% Ke Feng, Sept. 2007
% Please send comments to: jnfengke@gmail.com
% $Revision: 1.0.0.0 $  $Date: 2007/09/28 16:23:26 $
mail = 'matlablablablab@gmail.com';    %Your GMail email address
password = '8vo$NL8^mJ';          %Your GMail password
if nargin == 3
    message = subject;
    subject = '';
end
% Information found from
% http://www.sms411.net/2006/07/how-to-send-email-to-phone.html
switch strrep(strrep(lower(carrier),'-',''),'&','')
    case 'alltel';    emailto = strcat(number,'@message.alltel.com');
    case 'att';       emailto = strcat(number,'@mmode.com');
    case 'boost';     emailto = strcat(number,'@myboostmobile.com');
    case 'cingular';  emailto = strcat(number,'@cingularme.com');
    case 'cingular2'; emailto = strcat(number,'@mobile.mycingular.com');
    case 'nextel';    emailto = strcat(number,'@messaging.nextel.com');
    case 'sprint';    emailto = strcat(number,'@messaging.sprintpcs.com');
    case 'tmobile';   emailto = strcat(number,'@tmomail.net');
    case 'verizon';   emailto = strcat(number,'@vtext.com');
    case 'virgin';    emailto = strcat(number,'@vmobl.com');
end
% Then this code will set up the preferences properly:
setpref('Internet','E_mail',mail);
setpref('Internet','SMTP_Server','smtp.gmail.com');
setpref('Internet','SMTP_Username',mail);
setpref('Internet','SMTP_Password',password);
% The following four lines are necessary only if you are using GMail as
% your SMTP server. Delete these lines wif you are using your own SMTP
% server.
props = java.lang.System.getProperties;
props.setProperty('mail.smtp.auth','true');
props.setProperty('mail.smtp.socketFactory.class', 'javax.net.ssl.SSLSocketFactory');
props.setProperty('mail.smtp.socketFactory.port','465');
% Send the email
sendmail(emailto,subject,message)
end