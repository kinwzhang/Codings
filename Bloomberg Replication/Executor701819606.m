function portfolio = Executor701819606(Portfolio, DayClose, Date, TradingDayIndex, Action, Size)
%   List of Action:
%   Action == 2, Long
%   Action == 1, Cover
%   Action == 0, Hold
%   Action == -1, Close
%   Action == -2, Short
    try
        Size;
    catch
        Size = abs(fix(Portfolio.AvailableCapital / DayClose));
    end
    if Action == 2 && Portfolio.Position > 0 && Portfolio.AvailableCapital < abs(Size * DayClose)
        Action = 0;
    elseif Action == -2 && Portfolio.Position < 0 && (Portfolio.AvailableCapital - 2 * Portfolio.InitialInvestment) < abs(Size * DayClose)
        Action = 0;
    end
    
    switch Action 
        case 2  %   Long
          
        Value = Size * DayClose;
        AvailableCapital = Portfolio.AvailableCapital - Value;
        Position = Portfolio.Position + Size;
        PositionStatus = 1;
        EntryPrice = DayClose;
        EntryDate = Date(TradingDayIndex);
        Balance = abs(Portfolio.Balance - abs(Value));
        
        case 1  %   Cover
        Size = abs(Portfolio.Position);
        Value = Size * DayClose;
        AvailableCapital = Portfolio.AvailableCapital - Value;
        Position = Portfolio.Position + Size;
        PositionStatus = 0;
        EntryPrice = DayClose;
        EntryDate = Date(TradingDayIndex);
        Balance = abs(Portfolio.Balance + abs(Value));
        
        case 0  %   Hold
        Size = Portfolio.Size;
        Value = Portfolio.Size * DayClose;
        AvailableCapital = Portfolio.AvailableCapital;
        Position = Portfolio.Position;
        PositionStatus = Portfolio.PositionStatus;
        EntryPrice = Portfolio.EntryPrice;        
        EntryDate = Portfolio.EntryDate;
        Balance = Portfolio.Balance;
        
        case -1 %   Close
        Size = abs(Portfolio.Position);
        Value = Size * DayClose;
        AvailableCapital = Portfolio.AvailableCapital + Value;
        Position = Portfolio.Position - Size;
        PositionStatus = 0;
        EntryPrice = DayClose;
        EntryDate = Date(TradingDayIndex);
        Balance = abs(Portfolio.Balance + abs(Value));
        
        case -2 %   Short
        Value = Size * DayClose;
        AvailableCapital = Portfolio.AvailableCapital + Value;
        Position = Portfolio.Position - Size;
        PositionStatus = -1;
        EntryPrice = DayClose;
        EntryDate = Date(TradingDayIndex);
        Balance = abs(Portfolio.Balance - abs(Value));
    end
    
    portfolio.Size = Size;
    portfolio.AvailableCapital = AvailableCapital;
    portfolio.Value = Value;
    portfolio.Position = Position;
    portfolio.PositionStatus = PositionStatus;
    portfolio.EntryPrice = EntryPrice;
    portfolio.EntryDate = EntryDate;
    portfolio.Balance = Balance;
    portfolio.InitialInvestment = Portfolio.InitialInvestment;
end
