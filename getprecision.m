function p = getprecision(x)
% Returns the least unexpected output of a number
% i.e. the closest precision of a number in the form of a 1

% ex. getprecision(5.34) 
% >>>>  0.01

f = 14-9*isa(x,'single'); % double/single = 14/5 decimal places.
s = sprintf('%.*e',f,x);
v = [f+2:-1:3,1];
s(v) = '0'+diff([0,cumsum(s(v)~='0')>0]);
p = str2double(s);

end