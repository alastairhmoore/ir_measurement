function [ms,seqsum] = mseq(stages,levels,filesize)
%MSEQ Generates prbs m-sequences.
%     Sequences are tested for validity and their sum returned in seqsum
%	[MS,SEQSUM] = MSEQ(STAGES,LEVELS)
%
%	MS:   The generated prbs (m-sequence), a column vector.  For sequences stretching over
%         multiple files, only the last part of the sequence is returned this way.
%	STAGES: A scalar 
%	      stages = LOG2(sequence length + 1).  STAGES = 0
%         gives the m-sequence with 18 stages (262143 samples).
%         Default: 18 stages (262143 samples)
%         Range of stages supported: 3 to 33.
%   LEVELS = [MI, MA]: A 2 by 1 row vector, defining the input levels.
%	      the levels are adjusted so
%         that the input signal always is between MI and MA.
%	      Default: LEVELS = [-1 1].
%   FILESIZE: A scalar that sets the maximum elements in each .mat output 
%         file that makes up the m-sequence.  Multiple files are labelled
%         <stages>mseq1.mat, <stages>mseq2.mat, ... where <stages> is the
%         value of the variable STAGES
%         filesize = 700000 fits 700000, 16-bit integers on a 3.5" floppy
%         filesize = 0 supresses file saving and returns the entire sequence in MS
%         Default: no files are produced.

%	Based on IDINPUT.M by Ljung 3-3-95
%	Copyright (c) 1995 by the MathWorks, Inc.
%	$Revision: 1.3 $  $Date: 1995/05/16 09:01:05 $
%   Mod'd A I Tew 06/06/99 to produce m-seqs only and to run approx 60 times faster
%   Mod'd A I Tew 26/02/03 to improve functionality

if nargin < 3
   filesize = 0;  % Do not partition and save ms in a series of .mat files
end
if nargin < 2
   levels = [-1,1];
end
if nargin < 1
   stages=0;
end
if levels(2)<levels(1)
   error('The first component of LEVELS must be less than the second one.')
end

if stages==0,n=18;else n=floor(stages);end
if n<3|n>33,
  error('The length of the PRBS sequence, BAND(1), must range from 3 to 33.')
  return
end

if n==3
   ind=[1,3];
elseif n==4
   ind=[1,4];
elseif n==5
   ind=[2,5];
elseif n==6
   ind=[1,6];
elseif n==7
   ind=[1,7];
elseif n==8
   ind=[1,2,7,8];
elseif n==9
%   ind=[4,9];
   ind=[3,5,6,7,8,9];     %
elseif n==10
   ind=[3,10];
elseif n==11
   ind=[9,11];
elseif n==12
   ind=[6,8,11,12];
elseif n==13
   ind=[9,10,12,13];      % Tested, Smooth
%   ind=[2,3,4,7,8,13];    % Smooth
elseif n==14
   ind=[4,8,13,14];       % Tested, smooth
elseif n==15
%   ind=[14,15];           % Rough
%   ind=[1,15];            % Rough
   ind=[2,3,4,5,12,15];   % Smooth
elseif n==16
   ind=[4,13,15,16];
elseif n==17
   ind=[14,17];
elseif n==18
   ind=[11,18];
elseif n==19
   ind=[1,2,5,19];
elseif n==20
   ind=[3,20];
elseif n==21
   ind=[2,21];
elseif n==22
   ind=[1,22];
elseif n==23
   ind=[5,23];
elseif n==24
   ind=[1,2,7,24];
elseif n==25
   ind=[3,25];
elseif n==26
   ind=[1,2,6,26];
elseif n==27
   ind=[1,2,5,27];
elseif n==28
   ind=[3,28];
elseif n==29
   ind=[2,29];
elseif n==30
   ind=[1,2,23,30];
elseif n==31
   ind=[3,31];
elseif n==32
   ind=[1,2,22,32];
elseif n==33
   ind=[13,33];
end

fi=-ones(n,1);     % initalise states in shift register

N=2^n-1;           % Calc length of sequence
seqsum = 0;        % For storing the sum of the sequence (for checking it's ok)
ms = zeros(N,1);   % Prepare output vector for storing the entire sequence
curpos = 1;        % Current write position in ms vector

if filesize==0
    savefile = 0;
    totfiles = 1;
    filesize = N;
else
    savefile = 1;
    totfiles = ceil(N/filesize);
end

for file = 1:totfiles

    if savefile
        thisfile = ['mseq' num2str(stages) setstr(64 + file)];
        disp(['Generating data for file ' thisfile])
    end

  maxindex = min([filesize,N-(file-1)*filesize]);

  buildms=zeros(maxindex,1);  % Create temporary vector for building up part-sequence for each file

  for t=1:maxindex
    buildms(t)=fi(n);
    fi=[prod(fi(ind));fi(1:n-1)];
%    if rem(t,10000)==0,disp(t);end  % Progress indicator
  end

% Loosely validate the sequence by accumulating the sum of its elements
  seqsum = seqsum + sum(buildms);

  buildms = (levels(2)-levels(1))*(buildms+1)/2+levels(1);     % Adjust levels
  ms(curpos:curpos+maxindex-1) = buildms;    % Add the data for this part-sequence to ms
  curpos = curpos + maxindex;    % Update current position in ms
  
  if savefile
      wavedata=buildms;
      savefile = ['save ' thisfile ' wavedata'];  % Save this section of the sequence
      eval(savefile)
  end

end

if seqsum ~= -1, disp(['Sequence sum check failed with ' num2str(seqsum)]); end

return