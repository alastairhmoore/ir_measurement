function[out] = safe_db(in)
%SAFE_DB    safe db function which handles zeros by making them the smallest
%           real number
%
%out = safe_db(in)
%
%Alastair Moore, September 2006

i_zeros = find(in == 0);
if length(i_zeros) > 0;
    in = double(in);
    in(i_zeros) = realmin;
end
out = 20*log10(in);
