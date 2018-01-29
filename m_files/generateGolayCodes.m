function[codeA, codeB] = generateGolayCodes(order)
%GENERATESINESWEEP
%       Produces a complementary pair of golay codes, each in a column
%       vector of length 2^order.
%
%Alastair Moore, September 2006

if order < 2
    error('generateGolayCodes: order must be an integer greater than or equal to 2')
end

%seed codes
codeA = [1;1];
codeB = [1;-1];

%recursively build up full length code
for i = 2:order
    codeA = [codeA;codeB];
    codeB = [codeA(1:length(codeB));-codeB];
end
    