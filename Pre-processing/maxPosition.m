function position = maxPosition(ff, fs, N)
%% Function maxPosition
% The function yields the position, alias the frequency with the higher
% response 

f_axis=(0:N-1)*fs/N;
x1h = f_axis(f_axis > 0 & f_axis < 50);
f1h = ff(find(f_axis == x1h(1)) : find(f_axis == x1h(end))); 
[~, loc1h] = max(f1h);
position = x1h(loc1h);