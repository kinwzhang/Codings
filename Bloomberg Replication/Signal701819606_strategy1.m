function DataTable = Signal701819606_strategy1(DataTable)

%%  Create signals for trading
%   Destination Variable: Signal && DataTable.Signal
%   Cover & go long
%   When Closing cross below LowerBand
CloseBelowLowerBand = DataTable.Close <= DataTable.LowerBand;
LongSignal = [0, diff(CloseBelowLowerBand)']';
LongSignal(LongSignal == -1) = 0; 
DataTable.LongSignal = LongSignal;

%   Close & go short
%   When Closing cross above UpperBand
CloseAboveUpperBand = DataTable.Close >= DataTable.UpperBand;
ShortSignal = [0, diff(CloseAboveUpperBand)']';
ShortSignal(ShortSignal == -1) = 0;
ShortSignal = -ShortSignal;
DataTable.ShortSignal = ShortSignal;

%   Signal:
%   -1 means close & go short
%   1 means cover & go long
Signal = (LongSignal + ShortSignal) .* 2;
DataTable.Signal = Signal;

end
