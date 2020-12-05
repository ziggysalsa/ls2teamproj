% Linear Systems II: the Signal Separators
% This is the main script for our project. 

close all; clear all;

% Needs to run the record audio function here
input('press Enter to record your dial');
[y,Fs] = record_Dial();

input('press Enter to play your recording');
soundsc(y,Fs);

% and return normalized Y and Fs.

% Then, pass Y and Fs to a separate signal function
% which returns a vector of integers

% Then, call send_text_message.m to send the text.