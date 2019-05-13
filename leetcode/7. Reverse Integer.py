'''
Given a 32-bit signed integer, reverse digits of an integer.

Example 1:

Input: 123
Output: 321
Example 2:

Input: -123
Output: -321
Example 3:

Input: 120
Output: 21
Note:
Assume we are dealing with an environment which could only store integers within the 32-bit signed integer range: [−231,  231 − 1]. For the purpose of this problem, assume that your function returns 0 when the reversed integer overflows.
'''
#   Accepted Codes:
class Solution:
    def reverse(self, x: int) -> int:
        if x < 0:
            string = list(str(abs(x)))
            addNegative = 1
        else:
            string = list(str(x))
            addNegative = 0
        result = []
        while len(string) > 0:
            result.append(string.pop())
        result = ''.join(result)
        if addNegative == 1:
            result = '-' + result   
        if abs(int(result)) > pow(2, 31):
            return 0
        return int(result)
#   32 ms, 13.2 MB