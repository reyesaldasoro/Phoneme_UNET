% File to find unique phonemes in Mocha
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
clear Phonemes2
%LengthPhonemes(numFiles*10,1) = 0;
t=1;
for counterFile = 1:numFiles
    
    disp(counterFile)
    % Read the *.lab files, these are text with start-end-phoneme
    LAB                             = importdata(strcat(dataSetDir,'/',dir_Phonemes(counterFile).name,' '));
    % convert to a matlab matrix for easier manipulation
    [Phonemes,numPhonemes]          = convert_LAB_to_Phonemes(LAB);
    % Size of phonemes
    % discard 3 at the beginning, usually sil-breath-sil and last -sil
    for k=1:numPhonemes
        Phonemes2{t,1} = Phonemes{k,3};
        t=t+1;
    end
end

%% Identify unique phonemes
% Use the function uniquecell by PAtrick Mineault
% https://uk.mathworks.com/matlabcentral/fileexchange/31718-unique-elements-in-cell-array

Phonemes3 = uniquecell(Phonemes2);

% Results so far include 46 phonemes (plus breath and sil)
%{'@';'@@';'a';'aa';'ai';'b';'breath';'ch';'d';'dh';'e';'ei';'eir';'f';'g';'h';'i';'i@';'ii';'iy';'jh';'k';'l';'m';'n';'ng';'o';'oi';'oo';'ou';'ow';'p';'r';'s';'sh';'sil';'t';'th';'u';'uh';'uu';'v';'w';'y';'z';'zh'}

save('Phonemes','Phonemes3')