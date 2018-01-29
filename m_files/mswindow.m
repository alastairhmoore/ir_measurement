function wins=mswindow(X,winsize)
%WINDOW - Windows a signal into a matrix for m-sequence impulse response measurement
%
%	WINDOW(X,WINSIZE) takes a vector X and splits into seperate windows of size
%	WINSIZE. The separate windows are stored in the rows of a matrix and the
%	window data in the columns.  The windows are rectangular and
%	contiguous.  The number of separate windows is equal to
%   FLOOR(length(X)/WINSIZE).  The final window is always full of data from X, so
%   some data at the end of X may be lost.
%
%	Michael Kelly 16/12/99
%   Rewritten AIT 25/02/03 to:
%     restrict to rectangular windows only
%     only produce FLOOR(length(X)/WINSIZE) *complete* windows of data from X
%     correct function description
%     improve naming conventions

if nargin ~= 2
   error('MSWINDOW requires two input arguments')
end

% Make sure X is a column vector
[rows,cols]=size(X);
if ((rows>1)&(cols>1))
   error('X must be a vector');
end

Xsize=cols;
if rows>cols
   X=X';
   Xsize=rows;
end

%Perform windowing
numwins=floor(Xsize/winsize);		%Calculate number of windows
wins(numwins,winsize)=0;			%Create array

for curwin = 1:numwins
   wins(curwin,:)=X((curwin-1)*winsize+1:curwin*winsize);
end

return
