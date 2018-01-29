function[chan_list, A] = addLoopbackSignal(out_chans, out_mat, loopback_chan)
%ADDLOOPBACKSIGNAL
%   appends an MLS signal to the output matrix which can be used to
%   calculate the i/o loopback delay
%
%   [chan_list, A] = addLoopbackSignal(out_chans, out_mat, loopback_chan)
%
%   out_chans:      the current list of output cannnels to be used
%   out_mat:        the matrix of samples to be output
%   loopback_chan:  the output channel to be used for loopback signal. This
%                   must be different from the channels specified in out_chans
%
%Alastair Moore, October 2007


%check to make sure the loopback channel does not conflict with any of the
%channels in use
i = find(loopback_chan == out_chans, 1);    %specifying 1 means it will stop if any are encountered


if ~isempty(i)
    warning('Loopback channel is already in use.  Loopback signal not added.')
    chan_list = out_chans;
    A = out_mat;
else
    %blindly create an MLS
    loopback_mls_order = 12;
    loopback_reps = 4;
    mls_signal = mls('generate',{loopback_mls_order,loopback_reps,1,loopback_reps,0});
   
    %make it same size as test_len
    [nSamples,nChans] = size(out_mat);
    if length(mls_signal) > nSamples
        mls_signal = mls_signal(1:nSamples);
    else
        mls_signal = zero_pad(mls_signal, nSamples);
    end
    
    %add it to the output matrix
    A = [out_mat, mls_signal];
    
    %add loopback channel to chan_list
    chan_list = [out_chans, loopback_chan];
end