% File to calculate length of phonemes
%% Clear all variables and close all figures
clear all
close all
clc

%% Read the files that have been stored in the current folder
% These are local folders, so they will have to be changed if run in a different computer
% Also, the data has to be donwloaded from the MOCHA-TIMIT website
% http://www.cstr.ed.ac.uk/research/projects/artic/mocha.html
if strcmp(filesep,'/')
    % Running in Mac
    %    load('/Users/ccr22/OneDrive - City, University of London/Acad/ARC_Grant/Datasets/DataARC_Datasets_2019_05_03.mat')
    cd ('/Users/ccr22/Acad/GitHub/Phoneme_UNET/CODE')
    %dataSetDir =  'D:\OneDrive - City, University of London\Acad\Research\texture\Horiz_Vert_Diag';
    
    %    baseDir                             = 'Metrics_2019_04_25/metrics/';
else
    % running in windows
    cd ('D:\Acad\GitHub\Phoneme_UNET\CODE')
    dataSetDir =  'D:\OneDrive - City, University of London\Acad\Research\JoVerhoeven\MOCHA\fsew0_v1.1\';
end
%% Read the folder for .lab and . wav files

% all files in a folder will be converted
dir_Phonemes                    = dir(strcat(dataSetDir,'/*.lab'));
dir_Sounds                      = dir(strcat(dataSetDir,'/*.wav'));

numFiles                        = size(dir_Phonemes,1);
%% To prepare data read per case, train 50% test 50%

%
clear LengthPhonemes
LengthPhonemes(numFiles*10,1) = 0;
t=1;
for counterFile = 1:numFiles
    
    disp(counterFile)
    % Read the *.lab files, these are text with start-end-phoneme
    LAB                             = importdata(strcat(dataSetDir,'/',dir_Phonemes(counterFile).name,' '));
    % convert to a matlab matrix for easier manipulation
    [Phonemes,numPhonemes]          = convert_LAB_to_Phonemes(LAB);
    [audioWave,sampleRate]          = audioread(strcat(dataSetDir,'/',dir_Sounds(counterFile).name));
    % Size of phonemes
    % discard 3 at the beginning, usually sil-breath-sil and last -sil
    for k=4:numPhonemes-1
        LengthPhonemes(t,1) = sampleRate*(Phonemes{k,2}-Phonemes{k,1})/1000;
        t=t+1;
    end
end

%%
% Results (samples x 1000): 
% Shortest Phoneme      =  0.48
% Longest Phoneme       = 20.48
% Average Length        =  1.4189
% 95% are shorter than  =  2.9
