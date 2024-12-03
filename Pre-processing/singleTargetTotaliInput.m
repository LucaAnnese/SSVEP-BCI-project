clear all
clc
%%
% The target would look at a single stimulo per record, so interference from 
% other stimuli on the same sight
% Le tabelle prodotte sono poi da salvare correttamente nella cartella
% classification

% Define the output tables
wdCoeffs = [];
inputMeans = [];
inputMax = [];
inputPrincFirst = [];
periodogramMax = [];
% Supplementary matrices
targets = [];   
%%
for qq = 1:4      
    % Load all the information for a recording
    "single\Sub"+string(qq)+"_singletarget.mat"
    target1 = load("single\Sub"+string(qq)+"_singletarget.mat");
    data = target1.Data.EEG(:, 8);
    targetFrequency = target1.Data.TargetFrequency;   
    fs = target1.Data.AmpSamplingFrequency ;    % Sampling frequency
    N = length(data);
    eeg = target1.Data.EEG;

    % Remove the 10Hz target ffrequency signals (not included into multi
    % data)
    tbd = 10;
    indeces_10 = find(targetFrequency == tbd);
    targetFrequency(targetFrequency == 10) = [];
    for tt = 1:length(indeces_10)
        eeg(:, indeces_10(tt)) = [];
    end
    tbd = 12;
    indeces_12 = find(targetFrequency == tbd);
    targetFrequency(targetFrequency == 12) = [];
    for tt = 1:length(indeces_12)
        eeg(:, indeces_12(tt)) = [];
    end


    signals = [];
    
    %%
    % 4th order Butterworth pass-band filter
    [x,y] = butter(4,[4 35]/(fs/2)); 
    
 
    % Each recording is splitted into sub-recording of certain amount of
    % seconds ( user defined )
    for ii=1:size(eeg, 2)
        signal = eeg(:, ii);
    
        %% Pre-processing
        sy = filter(x,y, signal);
    
        % Split the signal in 5s signals
        time = round((size(sy,1)-1)/fs);
        splitLength = 5;     % in seconds
        nSplits = time/splitLength;
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
%             posPSD = periodogramPos(ppSignal, fs, N);
            inputMeans = [inputMeans, means'];
            inputMax = [inputMax, maxF'];
            inputPrincFirst = [inputPrincFirst, pFirstComp'];
%             periodogramMax = [periodogramMax, posPSD'];
%             wdCoeffs = [wdCoeffs, waveletFeaturesEnergy(ppSignal)'];
        end

end
%% Model the output
inputMeans = inputMeans';
inputMeans = [inputMeans targets'];
inputMeans = array2table(inputMeans);
inputMeans.Properties.VariableNames = [string(unique(targetFrequency)) "target"];

% wdCoeffs = wdCoeffs';
% wdCoeffs = [wdCoeffs targets'];
% wdCoeffs = array2table(wdCoeffs);
% wdCoeffs.Properties.VariableNames = ["cD1" "cD2" "cD3" "cD4" "cD5" "cA5" "target"];

inputMax = inputMax';
inputMax = [inputMax targets'];
inputMax = array2table(inputMax);
inputMax.Properties.VariableNames = ["MaxPos" "target"];

inputPrincFirst = inputPrincFirst';
inputPrincFirst = [inputPrincFirst targets'];
inputPrincFirst = array2table(inputPrincFirst);
inputPrincFirst.Properties.VariableNames = ["Principal" "First H" "target"];

% periodogramMax = periodogramMax';
% periodogramMax = [periodogramMax targets'];
% periodogramMax = array2table(periodogramMax);
% periodogramMax.Properties.VariableNames = ["PSD Max" "target"];
