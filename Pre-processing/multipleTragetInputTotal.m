% The patient is looking at different stimuli a t the same time, only 
% focusing at one at the time
% clear all
%%clc

% Load all the information for a recording
target1 = load("multi\Sub1_2_multitarget.mat");
data = target1.Data.EEG(:, 8);
targetFrequency = target1.Data.TargetFrequency;   
fs = target1.Data.AmpSamlingFrequency ;    % Sampling frequency
N = length(data);
eeg = target1.Data.EEG;

% 4th order Butterworth pass-band filter
[x,y] = butter(4,[4 35]/(fs/2)); 

% Define the output tables
wdCoeffs = [];
inputMeans = [];
inputMax = [];
inputPrincFirst = [];
periodogramMax = [];
% Supplementary matrices
signals = [];
targets = [];
data = load("multiTargetData.mat").data;
targetFrequency = data(end, :);
% Each recording is splitted into sub-recording of certain amount of
% seconds ( user defined )
for ii=1:size(data, 2)
    signal = data(:, ii);

    %% Pre-processing
    sy = filter(x,y, signal);

    % Split the signal in 3s signals
    time = round((size(sy,1)-1)/fs);
    splitLength = 5;     % in seconds
    % Manage uneven splitting
    if mod(time, splitLength) ~= 0
        nSplits = floor(time/splitLength);    
    else
        nSplits = time/splitLength; 
    end
    splits = [];
    for jj=1:nSplits
        jjsplit = sy((jj-1)*splitLength*fs+1:splitLength*fs*jj);
        jjsplit = jjsplit';
        jjsplit = [jjsplit zeros(1, N-length(jjsplit))];
        jjsplit = jjsplit';
        splits = [splits, jjsplit];    
    end
    splits = splits';
    splitTarget = targetFrequency(ii) + zeros(nSplits,1);
    signals = [signals, splits'];
    targets = [targets, splitTarget'];
   
end 

%% Feature extraction
    % We will use FFT as feature to extract from the needed informations
    for pp=1:size(signals,2)
        ppSignal = signals(:, pp);
        N = length(ppSignal);
        ff = fft(ppSignal);    
        % Feature selection
        means = computeAroundMean(unique(targetFrequency), ff, fs, N);
        maxF = maxPosition(ff, fs, N);
        pFirstComp = princFirstComp(unique(targetFrequency), ff, fs, N);
%         posPSD = periodogramPos(ppSignal, fs, N);
        inputMeans = [inputMeans, means'];
        inputMax = [inputMax, maxF'];
        inputPrincFirst = [inputPrincFirst, pFirstComp'];
%         periodogramMax = [periodogramMax, posPSD'];
%         wdCoeffs = [wdCoeffs, waveletFeaturesEnergy(ppSignal)'];
    end
%% Model the output
inputMeans = inputMeans';
inputMeans = [inputMeans targets'];
inputMeans = array2table(inputMeans);
inputMeans.Properties.VariableNames = [string(unique(targets)) "target"];

%%
% wdCoeffs = wdCoeffs';
% wdCoeffs = [wdCoeffs targets'];
% wdCoeffs = array2table(wdCoeffs);
% wdCoeffs.Properties.VariableNames = ["cD1" "cD2" "cD3" "cD4" "cD5" "cA5" "target"];
%%
inputMax = inputMax';
inputMax = [inputMax targets'];
inputMax = array2table(inputMax);
inputMax.Properties.VariableNames = ["MaxPos" "target"];
%%
inputPrincFirst = inputPrincFirst';
inputPrincFirst = [inputPrincFirst targets'];
inputPrincFirst = array2table(inputPrincFirst);
inputPrincFirst.Properties.VariableNames = ["Principal" "First H" "target"];
%%
% periodogramMax = periodogramMax';
% periodogramMax = [periodogramMax targets'];
% periodogramMax = array2table(periodogramMax);
% periodogramMax.Properties.VariableNames = ["PSD Max" "target"];
