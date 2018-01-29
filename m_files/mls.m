function[out, extras] = mls(command, options, micsignal);
%MLS    contains the routines for generating a maximum length sequence and
%processing the subsequenct response into an impulse response
%
%stimulus = mls('generate',{order, repetitions, start, finish, weighted_average})
%       returns an m-sequence stimulus stimulus signal
%
%est_ir = mls('process',options, micsignal)
%       returns the estimated system impulse response, given the response
%       of the signal to the mls generated using the same options
%
%       **TO DO: describe options**
%
%Alastair Moore, September 2006

%Defaults
order = 12;
repetitions = 10;
start = 5;
finish = 9;
weighted_average = 0;


%input validation
%% extract data from options (more or less blindly)
if (nargin > 1)&&(~isempty(options));
    order = cell2mat(options(1));
    repetitions = cell2mat(options(2));
    start = cell2mat(options(3));
    finish = cell2mat(options(4));
    if (finish < start +1)||(finish > repetitions)
        error('mls: finish must be less than repetitions and at least one greater than start');
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
    %if so, the sequence will be loaded into ms
    load stimulus_path;
    if exist([stimulus_path,'mls_',num2str(order),'.mat'],'file')
        load([stimulus_path,'mls_',num2str(order),'.mat'])
    else
        ms = mseq(order);
        save([stimulus_path,'mls_',num2str(order),'.mat'],'ms')
    end
    %copy signal vertically
    out = repmat(ms, repetitions,1);
elseif strcmpi(command, 'process')
    %do process	--	incorporates code originally in get_sysir and getir
    %           --  requires makeperm.n, mswindow.m and fht.m
    %load (or generate) m-sequence
    load stimulus_path;
    if exist([stimulus_path,'mls_',num2str(order),'.mat'],'file')
        load([stimulus_path,'mls_',num2str(order),'.mat'])
    else
        ms = mseq(order);
        save([stimulus_path,'mls_',num2str(order),'.mat'], 'ms')
    end
    
    %load (or generate) permutation matrix for fht
    if exist([stimulus_path,'perm_',num2str(order),'.mat'],'file')
        load([stimulus_path,'perm_',num2str(order),'.mat'])
    else
        perm = makeperm(ms);    %column 1:shuffled indices to be read by FHT
                                %column 2:shuffled indices to be written by
                                %FHT
        save([stimulus_path,'perm_',num2str(order),'.mat'],'perm')
    end

    mseqlength = length(ms);
    i_start = ((start-1)*mseqlength)+1; %starts from beginning of start'th sequence
    i_stop = finish*mseqlength;         %finishes at end of finish'th sequence
    
    %do processing one channel at a time (mswindow is mono process)
    
    for i = 1:nChan
        % split sysout into separate chunks
        syswins=mswindow(micsignal(i_start:i_stop,i),mseqlength);

        % Find the number of m-sequence lengths that have been extracted from X
        [numcycles,temp]=size(syswins);
        
       

        % Average the corresponding samples in each cycle
        if numcycles == 1
            avwin=syswins;
        elseif ~weighted_average
            avwin=sum(syswins(1:numcycles,:))/numcycles;
        else
            avwin = weighted_av(syswins);           
        end
        
        %normalise the response such that the maximum impulse aplitude is
        %unity
        avwin = avwin ./ (2^order -1);

        % Calculate the FHT
        out(:,i)=fht(avwin,perm);       
    end
    
else
	error('mls: command must be "generate" or "process"');
end

if nargout > 1
    extras = struct([]);
end