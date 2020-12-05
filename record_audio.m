% Linear Systems II: the Signal Separators
% function used to record sound. Called from MainScript.m
% to record the phone dial. Returns normalized Y vals and Fs.
function [y,Fs] = record_audio()
    recObj = audiorecorder;
    
    disp('Recording, You May Start Dialing....')
    record(recObj);
   
    input('press Enter to stop recording');
    stop(recObj);
    disp('Recording stopped');
    
    y = getaudiodata(recObj);
    Fs = get(recObj, 'SampleRate');
    
    %Scale Y by a value to normalize it
    y = y - mean(y); 
    ymax = max(y);
    ymin = min(y);
    scale = (ymax - ymin)/2; %scale yvals for consistency to always be around 1
    y = y/scale;
    
end

