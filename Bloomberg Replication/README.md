# Bloomberg Replication <BTST> (Matlab Code)
This project replicates the back-testing and optimization function of Bloomberg Terminal.

Within samples, a trading strategy using Bollinger Bands as technical indicator to decide the trade action (Long, Short, Cover, Close) 
For sample 1 (strategy 1): 
go long (cover) position when the closing price cross below lower Bollinger Bands if no position (or has short position) 
go short (close) position when the closing price cross above upper Bollinger Bands if no position (or has long position)

For sample 2 (strategy 2): 
take short position when the closing price goes above upper Bollinger Bands (maximum positions available) 
go cover position when the closing price cross below upper Bollinger Bands (maximum positions available) 
take long position when the closing price goes below lower Bollinger Bands (maximum positions available) 
go close position when the closing price cross above lower Bollinger Bands (maximum positions available)

Starting: Main701819606.m
Output: Trade tables and optimization tables which are the same as Bloomberg's result on screen.
