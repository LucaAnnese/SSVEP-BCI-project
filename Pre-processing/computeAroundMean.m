function [values] = computeAroundMean(target, ff, fs, N)

%% Syntax
%   Input: 
%       target: vector of frequencies 
%       ff: FFT of signal over which to compute the aroundMean
%   Output:
%       values: vector 

% values = [];
% for ii = 1:length(target)
%     f_axis=(0:N-1)*fs/N;    
% %    aroundFreq = f_axis(f_axis > target(ii)-0.15 & f_axis < target(ii)+0.15);
%     freq = f_axis(f_axis ==target(ii));
%     aroundFFT = ff(find(f_axis == freq)); 
% %     aroundFFT = abs(aroundFFT)/max(abs(aroundFFT));
% %    meanFFT = mean(abs(aroundFFT));
%     meanFFT = abs(aroundFFT);
%     values = [values, meanFFT];
% end

%%
values = [];
for ii = 1:length(target)
    f_axis=(0:N-1)*fs/N;
    x1h = f_axis(f_axis > target(ii)-0.1 & f_axis < target(ii)+0.1);
    f1h = ff(find(f_axis == x1h(1)) : find(f_axis == x1h(end))); 
    meanFFT = mean(abs(f1h));
    values = [values, meanFFT];
end