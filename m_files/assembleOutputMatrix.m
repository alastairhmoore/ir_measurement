function[chan_list, A] = assembleOutputMatrix(out_chans, out_vecs, len_gap)
%ASSEMBLEOUTPUTMATRIX
%   Returns a single matrix to pass to playrec for outputing
%
%   [chan_list A] = assembleOutputMatrix(out_chans, out_vecs, len_gap)
%
%   out_chans:  cell array containing vectors of output channel numbers
%   out_vecs:   cell array containing matrices with sound data to be output
%   arranged in coloumns
%   [len_gap]:    number of samples silence between each cell of samples 
%
%   N.B. The number of columns in each cell of out_vecs must match the
%   number of elements in the corresponding cell of out_chans.
%
%   Alastair Moore, October 2007


N = length(out_chans);          %How many sets of stimuli are there
%validation checks
if length(out_vecs) ~= N
    error('Lenghts of cell arrays must be equal')
end

%check to see whether len_gap is specified and is valid
if nargin < 3
    len_gap = 0;
else if len_gap < 0 || (mod(len_gap,1) ~= 0) 
        error('len_gap must be a non-negative integer')
    end
end

chan_list = [];
A = [];

%enter the main loop, iterating through each of the cells
for n = 1:N
    chans = cell2mat(out_chans(n));
    vecs = cell2mat(out_vecs(n));
    [rows cols] = size(vecs);
    
    if cols ~= length(chans)
        error('Mismatch between number of channels specified and number of channels of data supplied')
    end
    
    %add enough zeros to the end of A to fit the current set of samples
    [i_row width_A] = size(A);
    A = [A; zeros(rows, width_A)];
    range = i_row + [1:rows];
    
    
    %iterate through each channel
    for c = 1:cols
        %check to see if the channel is already in the channel list
        i = find(chans(c) == chan_list);
        if length(i) > 1
            error('Cannot specify the same channel twice in the same cell')
        end

        
        if isempty(i)
            %if not, add it to the end of chan_list and point i to that
            %column
            chan_list = [chan_list, chans(c)];
            i = length(chan_list);
            
            %and add a new column of zeros to A
            A = [A, zeros(length(A),1)];
        end
        
        %transfer the smamples into the current column of vecs into A
        A(range, i) = vecs(:,c);
    end
    
    %add zeros to form gap if required
    if len_gap
        A = [A; zeros(len_gap, length(chan_list))];
    end
end     
        
        
    
    

