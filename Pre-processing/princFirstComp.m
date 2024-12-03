function [princ] = princFirstComp(target, ff, fs, N)
%% Function princFirstComp
% The function will compute the principal harmonic component and the first 
% harmonic in term of psd, since in some patient the harmonincs are more
% useful to detect the stimuli frequencies

    f_axis=(0:N-1)*fs/N;
    x1h = f_axis(f_axis > target(1) & f_axis < target(end));
    f1h = ff(find(f_axis == x1h(1)) : find(f_axis == x1h(end))); 
    [~, loc1h] = max(f1h);
    princ = x1h(loc1h);

    x1h = f_axis(f_axis > 2*target(1) & f_axis < 2*target(end));
    f1h = ff(find(f_axis == x1h(1)) : find(f_axis == x1h(end))); 
    [~, loc1h] = max(f1h);
    princ = [princ, x1h(loc1h)];