%% Clear all variables and close all figures
clear all
close all
clc

%% Read the files that have been stored in the current folder
if strcmp(filesep,'/')
    % Running in Mac
    cd ('/Users/ccr22/Academic/GitHub/Phoneme_UNET/CODE')
    dataSetDir= '/Users/ccr22/OneDrive - City, University of London/Acad/Research/JoVerhoeven/MOCHA/fsew0_v1.1';
    trainingSetDir  =  '/Users/ccr22/Academic/GitHub/Phoneme_UNET/CODE';
    dataSaveDir     = '/Users/ccr22/Academic/GitHub/Phoneme_UNET/Results/'; 
else
    % running in windows
    dataSetDir      =  'D:\OneDrive - City, University of London\Acad\Research\JoVerhoeven\MOCHA\fsew0_v1.1\';
    trainingSetDir  =  'D:\Acad\GitHub\Phoneme_UNET\CODE\';
    dataSaveDir     = 'D:\Acad\GitHub\Phoneme_UNET\CODE\Results\';
    
    cd ('D:\Acad\GitHub\Phoneme_UNET\CODE')
    dataSetDir =  'D:\OneDrive - City, University of London\Acad\Research\JoVerhoeven\MOCHA\fsew0_v1.1\';
end

%% Read the folder for .lab and . wav files

% all files in a folder will be converted
dir_Phonemes                    = dir(strcat(dataSetDir,filesep,'*.lab'));
dir_Sounds                      = dir(strcat(dataSetDir,filesep,'*.wav'));
numFiles                        = size(dir_Phonemes,1);

%% Reference Phonemes
% List of phonemes, currently 46
%{'@';'@@';'a';'aa';'ai';'b';'breath';'ch';'d';'dh';'e';'ei';'eir';'f';'g';'h';'i';'i@';'ii';'iy';'jh';'k';'l';'m';'n';'ng';'o';'oi';'oo';'ou';'ow';'p';'r';'s';'sh';'sil';'t';'th';'u';'uh';'uu';'v';'w';'y';'z';'zh'}
%load('Phonemes.mat')

% this contains @ and other symbols that may not be valid
%Phonemes2 = {'@';'@@';'a';'aa';'ai';'b';'breath';'ch';'d';'dh';'e';'ei';'eir';'f';'g';'h';'i';'i@';'ii';'iy';'jh';'k';'l';'m';'n';'ng';'o';'oi';'oo';'ou';'ow';'p';'r';'s';'sh';'sil';'t';'th';'u';'uh';'uu';'v';'w';'y';'z';'zh'};
% this replaces  @  with at
Phonemes3 = {'at';'atat';'a';'aa';'ai';'b';'breath';'ch';'d';'dh';'e';'ei';'eir';'f';'g';'h';'i';'iat';'ii';'iy';'jh';'k';'l';'m';'n';'ng';'o';'oi';'oo';'ou';'ow';'p';'r';'s';'sh';'sil';'t';'th';'u';'uh';'uu';'v';'w';'y';'z';'zh'};


%%
numClasses = size(Phonemes3,1);

% The class names are a sequence of options for the textures, e.g.
clear classNames
%classNames(numClasses)='';
for counterClass=1:numClasses
    classNames(counterClass) = Phonemes3(counterClass);
end
labelIDs                    = (1:numClasses);

% Partition to create a large number of images to train
%imageSize               = [32 32];
sizeSample              = 4096;
imageSize               = [1 sizeSample*2];
stepOverlap             = 0;
%h2=plot(ones(sizeSample*1,1));

%% Define the unet 
%
% Definition of the network to be trained.
numFilters      = 64;
filterSize      = [3 1];
typeEncoder     = 'sgdm';
numEpochs       = 10;
lgraph = layerGraph;
layers = [
    imageInputLayer([sizeSample*2 1 1],'Name','input')
    convolution2dLayer(filterSize,numFilters,'Padding',1,'Name','conv_1')
    reluLayer('Name','relu_1')
    maxPooling2dLayer(2,'Stride',2,'Name','maxP_1')
    convolution2dLayer(filterSize,numFilters,'Padding',1,'Name','conv_2')
    reluLayer('Name','relu_2')
    maxPooling2dLayer(2,'Stride',2,'Name','maxP_2')
    convolution2dLayer(filterSize,numFilters,'Padding',1,'Name','conv_3')
    reluLayer('Name','relu_3')
    transposedConv2dLayer(4,numFilters,'Stride',2,'Cropping',1,'Name','transConv_1');
    convolution2dLayer(1,numClasses,'Name','conv_4');
    transposedConv2dLayer(4,numFilters,'Stride',2,'Cropping',1,'Name','transConv_2');
    convolution2dLayer(1,numClasses,'Name','conv_5');
    softmaxLayer('Name','softMax_1')
    pixelClassificationLayer('Name','classLayer_1')
    ];
lgraph = addLayers(lgraph,layers);
nameLayers     = '15';
opts = trainingOptions(typeEncoder, ...
    'InitialLearnRate',1e-3, ...
    'MaxEpochs',numEpochs, ...
    'MiniBatchSize',64);

%% Locations
    % location of the training data data and labels are stored as pairs of textures arranged in Horizontal,
    imageDir                    = fullfile(trainingSetDir,'trainingData');
    labelDir                    = fullfile(trainingSetDir,'trainingLabels');
    
    % These are the data stores with the training pairs and training labels
    % They can be later used to create montages of the pairs.
    %imds                        = fileDatastore(imageDir,'ReadFcn', @(x)(load(x)));
    %imds2                       = fileDatastore(labelDir,'ReadFcn', @(x)(load(x)));
    imds                        = fileDatastore(imageDir,'ReadFcn', @(x)(load(x)));
    imds2                       = fileDatastore(labelDir,'ReadFcn', @(x)(load(x)));

    pxds                        = datastore(labelDir,classNames,labelIDs);
    %%
    load('trainingDataPhonemes.mat')
    net                         = trainNetwork(totSections,y2,lgraph,opts);
      
    %%
    % The labels are simply the numbers of the textures, same numbers
    % as with the classNames. For randen examples, these vary 1-5, 1-16, 1-10
    pxds                        = pixelLabelDatastore(labelDir,classNames,labelIDs,'ReadFcn', @(x)(load(x)));
                
                trainingData        = pixelLabelImageDatastore(imds,pxds);
                nameNet             = strcat(dataSaveDir,'Network_Case_',num2str(currentCase),'_Enc_',nameEncoder,'_numL_',nameLayers,'_NumEpochs_',num2str(numEpochs));
                disp(nameNet)
                net                 = trainNetwork(trainingData,layers,opts);
                
                %save(nameNet,'net')
                
                %
                C = semanticseg(uint8(dataRanden{currentCase}),net);
                %B = labeloverlay(uint8(dataRanden{currentCase}), C);
                %figure
                %imagesc(B)
                
                % Convert from semantic to numeric
                result = zeros(rows,cols);
                for counterClass=1:numClasses
                    %strcat('T',num2str(counterClass))
                    %result = result + counterClass*((C==strcat('T',num2str(counterClass))));
                    result = result +(counterClass*(C==strcat('T',num2str(counterClass))));
                end
                %figure(10*counterOptions+currentCase)
                %imagesc(result==maskRanden{currentCase})
                accuracy(numLayersNetwork,currentCase,caseEncoder,numEpochsName)=sum(sum(result==maskRanden{currentCase}))/rows/cols;
                %save(strcat(dataSaveDir,'accuracy'),'accuracy')

misclassification = 100*(1-accuracy);
