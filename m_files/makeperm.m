function permout = makeperm(mseqin)
% MAKEPERM
%        PERMOUT = MAKEPERM(MSEQIN) creates the 2 by N permutations matrix for 
%        pre-shuffling and post-shuffling data in the Fast Hadamard Transform (FHT) 
%        method of system identification performed by function FHT.
%
%        The m-sequence to be used in the measurement must be supplied in vector MSEQIN.
%        If the m-sequence values are bipolar (1/-1) they are internally mapped to 
%        unipolar form (0/1, respectively) to suit the algorithm.
% 
%        PERMOUT(1,:) contains the shuffled indices of the vector from which system
%        output data is to be read by the first stage of FHT.
%
%        PERMOUT(2,:) contains the shuffled indices of the vector to which to which 
%        the calculated impulse response is to be written by the final stage of FHT.
%
%        For further information on the algorithm, refer to:
%
%        Borish, J and Angell, JB (1983) "An efficient algorithm for measuring the 
%        impulse response using pseudorandom noise."  J Audio Eng Soc, 31(7), 478 - 487.
%
%        Jones, DL (1990) "A system to measure the impulse response of a room." 
%        3rd year project report, Department of Electronics, University of York.
%
%        See also FHT.

%        Author:  A I Tew, 23/2/00

N = length(mseqin);
B = log2(N+1);  % Calculate the number of bits in the m-sequence generator

if B ~= fix(B)
  error('Input vector cannot be an m-sequence - length not 2^B - 1 !')
end

if size(mseqin,2) == 1
  mseqin = mseqin';  % If mseqin is a row vector, make it a column vector
end

if ~((min(mseqin) == 0) & (max(mseqin) == 1))

  if ~((min(mseqin) == -1) & (max(mseqin) == 1))
    error('M-sequence values must be either 0 and 1 OR +1 and -1!')
  else
%    disp('Converting m-sequence from bipolar to binary form...')

    for n = 1:N

      if mseqin(n) == -1
        mseqin(n) = 1;
      else
        mseqin(n) = 0;
      end

    end

  end

end

permout = zeros(2,N);  % Initialise permutation output matrix

mseqin = [mseqin(2:N),mseqin];  % Duplicate the m-sequence to simplify scanning

% Calculate the input shuffle vector

%disp('Generating input shuffle vector...')

for n=1:N
  k = N+n-1;
  shuffleval = sum(mseqin(k+(0:-1:-(B-1))) .* 2.^(B-(B:-1:1)));
  permout(1,shuffleval) = n;
end

% Calculate the output shuffle vector

%disp('Generating ouput shuffle vector...')

for n = 1:N
  shuffleval = sum(mseqin(permout(1,2.^(0:(B-1)))+N-n) .* 2.^(0:(B-1)));
  permout(2,n) = shuffleval;
end

return
