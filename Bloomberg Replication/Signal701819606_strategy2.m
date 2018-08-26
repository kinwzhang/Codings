function DataTable = Signal701819606_strategy2(DataTable)

%%  Create signals for trading
%   Destination Variable: Signal && DataTable.Signal


%   Short Signal, Closing Price above upperband
CloseAboveUpperBand = DataTable.Close >= DataTable.UpperBand;
ShortSignal = CloseAboveUpperBand;
ShortSignal = -ShortSignal;
DataTable.ShortSignal = ShortSignal;

%   Cover Signal, Closing Price Cross below upperband
CloseCrossBelowUpperBand = DataTable.Close < DataTable.UpperBand;
CoverSignal = [0, diff(CloseCrossBelowUpperBand)']';
CoverSignal(CoverSignal == -1) = 0;

DataTable.CoverSignal = CoverSignal;

%   Long Signal, Closing Price below lowerband
CloseBelowLowerBand = DataTable.Close <= DataTable.LowerBand;
LongSignal = CloseBelowLowerBand;
DataTable.LongSignal = LongSignal;

%   Close Signal, Closing Price Cross above lowerband
CloseCrossAboveLowerBand = DataTable.Close > DataTable.LowerBand;
CloseSignal = [0, diff(CloseCrossAboveLowerBand)']';
CloseSignal(CloseSignal == -1) = 0;
CloseSignal = -CloseSignal;
DataTable.CloseSignal = CloseSignal;
%   Signal:
%   -1 means close & go short
%   1 means cover & go long
Signal = (LongSignal + ShortSignal) .* 2;
Signal = Signal + CloseSignal + CoverSignal;
DataTable.Signal = Signal;


end
