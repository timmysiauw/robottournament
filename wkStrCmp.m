function [out] = wkStrCmp(S1,S2,tol)
% Weak String Comparison
% Counts the number of "important" characters in each string, then computes
% the normalized inner product between them. If the angle is close enough
% (tol) to 1, then the vectors are similar enough to be considered equal.

characters = ['abcdefghijklmnopqrstuvwxyz1234567890'];
L = 36;

S1 = lower(S1);
S2 = lower(S2);

v1 = zeros(1,L);
v2 = zeros(1,L);

for i = 1:L
    v1(i) = length(find(S1==characters(i)));
    v2(i) = length(find(S2==characters(i)));
end

out = (1 - (v1*v2')/(norm(v1)*norm(v2))) < tol; 

end % end wkStrCmp