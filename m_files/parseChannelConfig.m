function [ playChan, recChan ] = parseChannelConfig( config )
if isa(config, 'char')
    switch config
        case 'hrtf'
            playChan = 1;
            recChan = [1 2];
        case 'phones'
            playChan = [1 2];
            recChan = [1 2];
        otherwise
            error('Unknown string supplied in config')
    end
else
    playChan = cell2mat(config(1));
    recChan = cell2mat(config(2));  
end

end

