function[window] = cosine_window(length,side)
%COSINE_WINDOW      returns a cosine window in the range 0-1
%
%[window] = cosine_window(length)
%                   symmetrical window shape
%
%[window] = cosine_window(length,side)
%                   specifify the 'rising' or 'falling' side
%
%Alastair Moore, September 2006


switch nargin
    case 1
        window = (1-cos([1:length]/(length+1)*2*pi))/2;
    case 2
        if strcmpi(side,'rising')
            window = (1-cos([1:length]/(length+1)*pi))/2;
        elseif strcmpi(side,'falling')
            window = (1+cos([1:length]/(length+1)*pi))/2;
        else
            error('cosine_window: 2nd argument must be rising or falling')
        end
    otherwise
        error('cosine_window: see help for usage')
end

