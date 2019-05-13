'''
The Hamming distance between two integers is the number of positions at which the corresponding bits are different.

Given two integers x and y, calculate the Hamming distance.

Note:
0 ≤ x, y < 231.

Example:

Input: x = 1, y = 4

Output: 2

Explanation:
1   (0 0 0 1)
4   (0 1 0 0)
       ↑   ↑

The above arrows point to positions where the corresponding bits are different.
'''

#   Accepted Codes:
class Solution:
    def hammingDistance(self, x: int, y: int) -> int:
        x = str(bin(x))[2:]
        y = str(bin(y))[2:]
        x = (32 - len(x)) * '0' + x
        y = (32 - len(y)) * '0' + y
        result = 0
        for i in range(len(x)):
            if x[i] != y[i]:
                result = result + 1
        return result
#   28 ms, 13.3 MB