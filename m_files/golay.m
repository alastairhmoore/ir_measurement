function[out, extras] = golay(command, options, micsignal);
%GOLAY    contains the routines for generating a pair of Golay codes pair and
%processing the subsequenct response into an impulse response
%
%stimulus = golay('generate',{order, repetitions, start, finish})
%       returns golay stimulus signal consisting of
%       1. repetitions x code A (2^order samples long)
%       2. 2^order samples of silence
%       3. repetitions x code B (2^order samples long)
%
%est_ir = mls('process',options, micsignal)
%       returns the estimated system impulse response, given the response
%       of the signal to the golay stimulus generated using the same options
%
%       **TO DO: describe options**
%
%Alastair Moore, September 2006

%Defaults
order = 11;
repetitions = 10;
start = 1;
finish = 10;
weighted_average = 0;


%input validation
%% extract data from options (more or less blindly)
if (nargin > 1)&&(~isempty(options));
    order = cell2mat(options(1));
    repetitions = cell2mat(options(2));
    start = cell2mat(options(3));
    finish = cell2mat(options(4));
    if (finish < start)||(finish > repetitions)
        error('golay: finish must be less than repetitions and greater than or equal to start');
    end
    weighted_average = cell2mat(options(5));
end
%Print values
if 0
    order = order
    repetitions = repetitions
    start = start
    finish = finish
    weighted_average =weighted_average
end

if (nargin > 2)
    [siglength, nChan] = size(micsignal);
end

if (nargin < 1) || (nargin > 3) || ~isa(command, 'char')
    error('mls: see help for usage');
elseif strcmpi(command, 'generate')
    %check to see if the m-sequence has already been stored
    %if so, the sequence will be loaded into A and B
    load stimulus_path;
    if exist([stimulus_path,'golay_',num2str(order),'.mat'],'file')
        load([stimulus_path,'golay_',num2str(order),'.mat'])
    else
        [A B] = generateGolayCodes(order);
        conj_fft_A = conj(fft(A));
        conj_fft_B = conj(fft(B));
        save([stimulus_path,'golay_',num2str(order),'.mat'],'A','B','conj_fft_A','conj_fft_B')
    end
    %copy signal vertically
    %out = repmat(ms, repetitions,1);
    out = [repmat(A,repetitions,1);zeros(length(A),1);repmat(B,repetitions,1)];
elseif strcmpi(command, 'process')
    %check to see if the codes have already been stored
    %if so, the codes and their conjugate fft's are loaded in
    load stimulus_path;
    if exist([stimulus_path,'golay_',num2str(order),'.mat'],'file')
        load([stimulus_path,'golay_',num2str(order),'.mat'])
    else
        [A B] = generateGolayCodes(order);
        conj_fft_A = conj(fft(A));
        conj_fft_B = conj(fft(B));
        save([stimulus_path,'golay_',num2str(order),'.mat'],'A','B','conj_fft_A','conj_fft_B')
    end

    

    codelength = length(A);
        %extract the right bits assuming no repititions
        %a_start = 1;
        %a_stop = codelength;
        %b_start = 2*codelength+1;
        %b_stop = 3*codelength;
    %starts from beginning of start'th sequence
    %finishes at end of finish'th sequence
    a_start = ((start-1)*codelength)+1
    a_stop = (finish*codelength)
    offset = (repetitions + 1) * codelength;
    b_start = a_start + offset;
    b_stop = a_stop + offset;
    
    
    responseA = micsignal(a_start:a_stop,:);
    responseB = micsignal(b_start:b_stop,:);
    %[responseA, responseB]
    
    %do processing one channel at a time (mswindow is mono process)
    
    for i = 1:nChan
        % split sysout into separate chunks
        a_syswins = mswindow(responseA(:,i),codelength);
        b_syswins = mswindow(responseB(:,i),codelength);

        % Find the number of code lengths that have been extracted from X
        [numcycles,temp]=size(a_syswins);
        
        % Average the corresponding samples in each cycle
        if numcycles == 1
            a_avwin=a_syswins;
            b_avwin=b_syswins;
        elseif ~weighted_average
            a_avwin=sum(a_syswins(1:numcycles,:))/numcycles;
            b_avwin=sum(b_syswins(1:numcycles,:))/numcycles;            
            
        else
            a_avwin = weighted_av(a_syswins);
            b_avwin = weighted_av(b_syswins);
        end
        a_avwin = a_avwin';
        b_avwin = b_avwin';
        
        %normalise the response such that the maximum impulse aplitude is
        %unity
        a_avwin = a_avwin ./ (2^(order +1));
        b_avwin = b_avwin ./ (2^(order +1));
        
        %do the main processing
        %summed cross correlation of each code
        out(:,i) = ifft(fft(a_avwin).*conj_fft_A + fft(b_avwin).*conj_fft_B);
        
    end
    
else
	error('golay: command must be "generate" or "process"');
end


if nargout > 1
    extras = struct([]);
end