# Distribution of Stock Returns
# Question:
Is stock return normally distributed?
# Background:
I was asked this question during a phone interveiw.

Intitutively, I think it was not, since some companies/sectors are doing better than others.
However, when I think that again. I think I have a different answer. 

So I searched Google and the answer is yes, stock returns is normally distributed in general.
Although Google said that, I decide to verify the answer myself.

Therefore, I worked on this Python code for the verification.

# Data Description:	
Columns:	 S&P 500 Companies (492 companies with valid data, 8 companies removed)

Observations:	503 observations (503 trading days between 01/01/2016 and 12/31/2017)

Data:		

Daily adjusted closing price from Yahoo Finance;

Calculated stock returns from closing prices.

# Conclusion: 
Yes, stock returns are normally distributed.
