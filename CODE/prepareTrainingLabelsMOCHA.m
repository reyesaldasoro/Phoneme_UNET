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

%% Reference Phonemes
% List of phonemes, currently 46
%{'@';'@@';'a';'aa';'ai';'b';'breath';'ch';'d';'dh';'e';'ei';'eir';'f';'g';'h';'i';'i@';'ii';'iy';'jh';'k';'l';'m';'n';'ng';'o';'oi';'oo';'ou';'ow';'p';'r';'s';'sh';'sil';'t';'th';'u';'uh';'uu';'v';'w';'y';'z';'zh'}
load('Phonemes.mat')


%% To prepare data read per case, train 50% test 50%


% Partition to create a large number of images to train
%imageSize               = [32 32];
sizeSample              = 4096;
imageSize               = [1 sizeSample*2];
stepOverlap             = 0;
%h2=plot(ones(sizeSample*1,1));


for counterFile = 1:5%numFiles
    % iterate over the files selected for training
    %counterFile = 9;
    disp(counterFile)
    % Read the *.lab files, these are text with start-end-phoneme
    LAB                             = importdata(strcat(dataSetDir,'/',dir_Phonemes(counterFile).name,' '));
    % convert to a matlab matrix for easier manipulation
    [Phonemes,numPhonemes]          = convert_LAB_to_Phonemes(LAB);
    [audioWave,sampleRate]          = audioread(strcat(dataSetDir,'/',dir_Sounds(counterFile).name));
    % 95% of Phonemes are contained within 3,500 samples, 98.9 within 4,000 so train with a pair
    % of phonemes with [4k - 4k], use 4096 in case this can be converted to a 2D grid of 64*64
    % The silence and breath are necessary
    
    for counterClass_1 = 1:numPhonemes
        % First class
        for counterClass_2 = 1:numPhonemes
            % Second Class
            if counterClass_1~=counterClass_2
                %only if different
                
                % Prepare data (phonemes) 
                currentSection_1    = audioWave(1+round(sampleRate*Phonemes{counterClass_1,1}):round(sampleRate*Phonemes{counterClass_1,2} ));
                currentSection_2    = audioWave(1+round(sampleRate*Phonemes{counterClass_2,1}):round(sampleRate*Phonemes{counterClass_2,2} ));
                lengthSection_1     = numel(currentSection_1);
                lengthSection_2     = numel(currentSection_2);
                numRepeats_1        = ceil(sizeSample/lengthSection_1);
                numRepeats_2        = ceil(sizeSample/lengthSection_2);
                % If the phonemes are shorter than the sample, repeat, if shorter will be cropped
                repSection_1        = repmat(currentSection_1',[1 numRepeats_1]);
                repSection_2        = repmat(currentSection_2',[1 numRepeats_2]);    
                
                % Prepare the labels
                Label_1             = find(strcmp(Phonemes3,Phonemes{counterClass_1,3}));
                Label_2             = find(strcmp(Phonemes3,Phonemes{counterClass_2,3}));
                
                currentLabel_1      = uint8(ones(1,sizeSample)*Label_1);
                currentLabel_2      = uint8(ones(1,sizeSample)*Label_2);
               
                % Horizontal Pair Arrangement
                % For the phonemes, it is important the transitions, so crop initial for 1 and final for 2
                currentSectionH      = [repSection_1(:,end-sizeSample+1:end) repSection_2(:,1:sizeSample)] ;
                currentLabelH        = [currentLabel_1 currentLabel_2];
                
                
                % Display and Save Horizontal
                %hold off
                %plot(1:sizeSample,currentSectionH(1:sizeSample),'r',...
                %     sizeSample+(1:sizeSample),currentSectionH(sizeSample+(1:sizeSample)))
                %title (strcat(Phonemes{counterClass_1,3},'---',Phonemes{counterClass_2,3}))
                %imagesc(currentSection)
                %h2.CData = currentSectionH;
                %title(strcat('H Classes = ',num2str(counterClass_1),'/',num2str(counterClass_2),32,32,'(',num2str(counterR),'-',num2str(counterC),')'))
                %pause(0.1)
%                sound(currentSectionH)
                %drawnow;
                % Save
                fName  = strcat('D_P1_',num2str(Label_1),'_P2_',num2str(Label_2),'_S_',num2str(counterFile),'_Phonemes_',Phonemes{counterClass_1,3},'_',Phonemes{counterClass_2,3},'.mat');
                disp(fName)
                fNameL = strcat('L_P1_',num2str(Label_1),'_P2_',num2str(Label_2),'_S_',num2str(counterFile),'_Phonemes_',Phonemes{counterClass_1,3},'_',Phonemes{counterClass_2,3},'.mat');
                %fNameL  = strcat('Label_Phoneme1_',num2str(counterClass_1),'_',Phonemes{counterClass_1,3},'_Phoneme2_',num2str(counterClass_2),'_',Phonemes{counterClass_2,3},'_Phrase_',num2str(counterFile),'.mat');
                %save(currentSectionH,strcat('trainingImages',filesep,'Case_',num2str(currentCase),filesep,fName))
                %save(currentLabelH  ,strcat('trainingLabels',filesep,'Case_',num2str(currentCase),filesep,fNameL))
                save(strcat('trainingData',filesep,fName),'currentSectionH')
                save(strcat('trainingLabels',filesep,fNameL),'currentLabelH' )
                
               
            end
        end
    end
    
    
end
%%
% dataRanden    -  cell with the composite images
% trainRanden   -  cell with the training data for each image
% maskRanden    -  cell with the masks for each of the composite images

%% Augmentation of training data for classification with U-Net
figure(1)
h2=imagesc(ones(32));
colormap gray

counterClasses  = 1;

[rr,cc]         = meshgrid(1:32,1:32);

D1              = uint8(cc>rr);
D2              = uint8(cc<=rr);

%% Prepare training classes to be just two classes per image




