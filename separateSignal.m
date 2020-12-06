% Linear Systems II Team Project: the Signal Separators
% Function for separating the signal
% Input 'data' which should be our cleaned signal 'yf' in this case
% Spit out a 'signal' matrix which contains each separated signal segment..
% ..in each row of the matrix, the segments are what we will filter
function signal = separateSignal(data)
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
    
    %plot cleaned signal
    figure;
    subplot(2,1,1);
    plot(yf);
    subplot(2,1,2);
    pwelch(yf,[],[],[],fs);

    %plot signal
    figure;
    subplot(2,1,1);
    plot(signal(6,:));
    subplot(2,1,2);
    pwelch(signal(6,:),[],[],[],fs);
end