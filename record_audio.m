% test record audio from mic
% ( Successed )

close all;
clear all;

input('press Enter to record your dial');
[y,Fs] = record_Dial();

input('press Enter to play your recording');
soundsc(y,Fs);

% function used to record sound
function [y,Fs] = record_Dial()
    recObj = audiorecorder;
    
    disp('Recording, You May Start Dialing....')
    record(recObj);
   
    input('press Enter to stop recording');
    stop(recObj);
    disp('Recording stopped');
    
    y = getaudiodata(recObj);
    Fs = get(recObj, 'SampleRate');
end

