function response = fht(sysout,perm,display)
% FHT
%        RESPONSE = FHT(SYSOUT,PERM,DISPLAY)
%
%        FHT performs a Fast Hadamard Transform for system identification according to
%        the algorithm by Borish and Angell.  The impulse response of the system is 
%        placed in vector RESPONSE.
%
%        SYSOUT is the (bipolar) output signal vector obtained from the unidentified 
%        system for a particular m-sequence input.  Pre- and post-shuffling of the FHT 
%        input and output data is specified in the permutations matrix PERM.  Use 
%        function MAKEPERM to create PERM for the particular m-sequence being used.
%
%        DISPLAY = B displays calculation progress messages only if the number of 
%        m-sequence stages equals or exceeds B.  Omitting this argument suppresses the 
%        progress messages in all circumstances.
%
%        For further information on the algorithm, refer to:
%
%        Borish, J and Angell, JB (1983) "An efficient algorithm for measuring the 
%        impulse response using pseudorandom noise."  J Audio Eng Soc, 31(7), 478 - 487.
%
%        Jones, DL (1990) "A system to measure the impulse response of a room." 
%        3rd year project report, Department of Electronics, University of York.
%
%        See also MAKEPERM.

%        Author:  A I Tew, 23/2/00

if (nargin < 2) | (nargin > 3)
  error('FHT requires two or three arguements!')
end

N = size(perm,2)+1;  % Calculate length of original m-sequence

if N ~= length(sysout)+1;
  error('Length of sysout and perm columns must match!')
end

if size(perm,1) ~= 2
  error('Permutations matrix must have two rows!')
end

if N < 7
  error('Cannot perform FHT of fewer than 8 points')
end

B = log2(N);  % Calculate the number of bits in original m-sequence

if B ~= fix(B)
  error('sysout and perm must be of length 2^B - 1 !')
end

if nargin == 2
  show_progress = 0;  % Set to FALSE to suppress all progress messages
else

  if display > 0
    show_progress = (B >= display);  % Indicate progress when required
  else
     show_progress = 0;  % Set to FALSE to suppress progress messages
  end

end

if size(sysout,2) == 1
  sysout = sysout';  % If sysout is a row vector, make it a column vector
end

tmpvec = zeros(1,N);  % Initialise temporary vector
response = zeros(1,N-1);  % Initialise output vector

tmpvec(2:N) = sysout(perm(1,(1:N-1)));  % Shuffle and prepend a zero

% Perform first butterfly stage using in-place computation

if show_progress; disp('Performing first stage...'); end

bf0 = tmpvec(1:2:N-1) + tmpvec(2:2:N);
bf1 = tmpvec(1:2:N-1) - tmpvec(2:2:N);
tmpvec(1:2:N-1) = bf0;
tmpvec(2:2:N) = bf1;

% Perform intermediate stages of FHT using in-place computation

% s is stage number in FHT process

for s = 1:log2(N)-2
  if show_progress; disp(setstr(['Performing stage ',num2str(s+1),'...'])); end
  bs = 2^s;  % Butterfly size

% b is block start index

  for b = 0:2*bs:N-2*bs
    bf0 = tmpvec(b+(1:bs)) + tmpvec(b+(bs+1:2*bs));
    bf1 = tmpvec(b+(1:bs)) - tmpvec(b+(bs+1:2*bs));
    tmpvec(b+(1:bs)) = bf0;
    tmpvec(b+(bs+1:2*bs)) = bf1;
  end

end

% Perform final stage of FHT

if show_progress; disp('Performing final stage...'); end
bs = N/2;  % Butterfly size

bf0 = tmpvec(1:bs) + tmpvec(bs+1:N);
bf1 = tmpvec(1:bs) - tmpvec(bs+1:N);
tmpvec(1:bs) = bf0;
tmpvec(bs+1:N) = bf1;

tmpvec = tmpvec(2:N);  % Supress first column (reduces length back to N-1)
response(1:N-1) = tmpvec(perm(2,1:N-1));  % Unshuffle result

return
