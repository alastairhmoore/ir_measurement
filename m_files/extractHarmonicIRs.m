function[hirs, offsets] = extractHarmonicIRs(hir, options,nHarmonics)

if nargin < 3 || isempty(nHarmonics)
    nHarmonics = 5;
end
f1 = options{1}
f2 = options{2}

T = length(hir)/2;

for N = 1:nHarmonics
    offset(N) = T * log(N) / (log(f2/f1))
end

start = (length(hir)/2)-offset;
stop = [length(hir), start(1:end-1)-1];
offsets = [start', stop']

for N = 1:nHarmonics
    hirs(N) = {hir(start(N):stop(N))};
end