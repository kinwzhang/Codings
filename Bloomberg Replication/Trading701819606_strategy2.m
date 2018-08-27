function [DataTable, TradeTable] = Trading701819606(StartingDateIndex, DataTable, InvestmentAmount, Size)

%       Bloomberg Startegy
%       Ignore repeat signals in the same direction.

    LongSignalCount = sum(DataTable.Signal == 2);
    ShortSignalCount = sum(DataTable.Signal == -2);
    TradeTable = table;
    Tra_Tbl = struct;
    TradeTableCurrentRow = 1;
    if LongSignalCount == 0 && ShortSignalCount == 0 %% In case there is no trade happens
        Portfolio = PortfolioInitialization701819606(InvestmentAmount, StartingDateIndex, DataTable.Date);
        Tra_Tbl = WriteTradeTable701819606(Portfolio, Tra_Tbl, TradeTableCurrentRow);
        Port_Avai_Cap(1:length(DataTable.Date)) = Portfolio.AvailableCapital;
        Port_Value(1:length(DataTable.Date)) = Portfolio.Value;
        Port_Pos_Status(1:length(DataTable.Date)) = Portfolio.PositionStatus;
        Port_Position(1:length(DataTable.Date)) = Portfolio.Position;
        Port_Ent_Px(1:length(DataTable.Date)) = Portfolio.EntryPrice;
        Port_Ent_Dt(1:length(DataTable.Date)) = Portfolio.EntryDate;
    else
        for TradingDayIndex = StartingDateIndex:length(DataTable.Date)
            if TradingDayIndex == StartingDateIndex
                Portfolio = PortfolioInitialization701819606(InvestmentAmount, TradingDayIndex, DataTable.Date);
            end
            %   Trading at current close
            TradingPX = DataTable.Close(TradingDayIndex);
            CurrentSignal = DataTable.Signal(TradingDayIndex);
            switch CurrentSignal
                case 0
                    %   Hold Executor
                    Portfolio = Executor701819606(Portfolio, TradingPX, DataTable.Date, TradingDayIndex, 0);

                    Port_Avai_Cap(TradingDayIndex) = Portfolio.AvailableCapital;
                    Port_Value(TradingDayIndex) = Portfolio.Value;
                    Port_Pos_Status(TradingDayIndex) = Portfolio.PositionStatus;
                    Port_Position(TradingDayIndex) = Portfolio.Position;
                    Port_Ent_Px(TradingDayIndex) = Portfolio.EntryPrice;
                    Port_Ent_Dt(TradingDayIndex) = Portfolio.EntryDate;

                case 2
                    %   Long Executor(handling Long Signals)
                    %   Action 1
                    if Portfolio.Position < 0   %   Cover First
                        Portfolio = Executor701819606(Portfolio, TradingPX, DataTable.Date, TradingDayIndex, 1);
                    end
                    %   Action 2
                    if Portfolio.Position >= 0  %   Go Long
                        try
                            Portfolio = Executor701819606(Portfolio, TradingPX, DataTable.Date, TradingDayIndex, 2, Size);
                        catch
                            Portfolio = Executor701819606(Portfolio, TradingPX, DataTable.Date, TradingDayIndex, 2);
                        end
                        %   Write the trade into trade table
                        Tra_Tbl = WriteTradeTable701819606(Portfolio, Tra_Tbl, TradeTableCurrentRow);
                        TradeTableCurrentRow = TradeTableCurrentRow + 1;
                    end
                    %   Recording Actions
                    Port_Avai_Cap(TradingDayIndex) = Portfolio.AvailableCapital;
                    Port_Value(TradingDayIndex) = Portfolio.Value;
                    Port_Pos_Status(TradingDayIndex) = Portfolio.PositionStatus;
                    Port_Position(TradingDayIndex) = Portfolio.Position;
                    Port_Ent_Px(TradingDayIndex) = Portfolio.EntryPrice;
                    Port_Ent_Dt(TradingDayIndex) = Portfolio.EntryDate;
                case 1
                    %   Cover Executor (handling Cover Signals)
                    %   Action 1
                    if Portfolio.Position < 0   %   Cover First
                        Portfolio = Executor701819606(Portfolio, TradingPX, DataTable.Date, TradingDayIndex, 1);

                        %   Write the trade into trade table
                        Tra_Tbl = WriteTradeTable701819606(Portfolio, Tra_Tbl, TradeTableCurrentRow);
                        TradeTableCurrentRow = TradeTableCurrentRow + 1;  
                    end

                    %   Recording Actions
                    Port_Avai_Cap(TradingDayIndex) = Portfolio.AvailableCapital;
                    Port_Value(TradingDayIndex) = Portfolio.Value;
                    Port_Pos_Status(TradingDayIndex) = Portfolio.PositionStatus;
                    Port_Position(TradingDayIndex) = Portfolio.Position;
                    Port_Ent_Px(TradingDayIndex) = Portfolio.EntryPrice;
                    Port_Ent_Dt(TradingDayIndex) = Portfolio.EntryDate;
                    
                    
                case -2
                    %   Short Executor (handling Short Signals)
                    %   Action 1
                    if Portfolio.Position > 0  %   Close First
                        Portfolio = Executor701819606(Portfolio, TradingPX, DataTable.Date, TradingDayIndex, -1); 
                    end
                    %   Action 2
                    if Portfolio.Position <= 0%   Go Short
                        try
                            Portfolio = Executor701819606(Portfolio, TradingPX, DataTable.Date, TradingDayIndex, -2, Size);
                        catch
                            Portfolio = Executor701819606(Portfolio, TradingPX, DataTable.Date, TradingDayIndex, -2);
                        end                    
                        %   Write the trade into trade table
                        Tra_Tbl = WriteTradeTable701819606(Portfolio, Tra_Tbl, TradeTableCurrentRow);
                        TradeTableCurrentRow = TradeTableCurrentRow + 1;
                    end
                    %   Recording Actions
                    Port_Avai_Cap(TradingDayIndex) = Portfolio.AvailableCapital;
                    Port_Value(TradingDayIndex) = Portfolio.Value;
                    Port_Pos_Status(TradingDayIndex) = Portfolio.PositionStatus;
                    Port_Position(TradingDayIndex) = Portfolio.Position;
                    Port_Ent_Px(TradingDayIndex) = Portfolio.EntryPrice;
                    Port_Ent_Dt(TradingDayIndex) = Portfolio.EntryDate;
                    
                case -1
                    %   Close Executor (handling Close Signals)
                    %   Action 1
                    if Portfolio.Position > 0  %   Close First
                        Portfolio = Executor701819606(Portfolio, TradingPX, DataTable.Date, TradingDayIndex, -1); 

                        %   Write the trade into trade table
                        Tra_Tbl = WriteTradeTable701819606(Portfolio, Tra_Tbl, TradeTableCurrentRow);
                        TradeTableCurrentRow = TradeTableCurrentRow + 1;  
                    end
                    %   Recording Actions
                    Port_Avai_Cap(TradingDayIndex) = Portfolio.AvailableCapital;
                    Port_Value(TradingDayIndex) = Portfolio.Value;
                    Port_Pos_Status(TradingDayIndex) = Portfolio.PositionStatus;
                    Port_Position(TradingDayIndex) = Portfolio.Position;
                    Port_Ent_Px(TradingDayIndex) = Portfolio.EntryPrice;
                    Port_Ent_Dt(TradingDayIndex) = Portfolio.EntryDate;
                    
                end
        end
    end
        DataTable.Port_Avai_Cap = Port_Avai_Cap';
        DataTable.Port_Value = Port_Value';
        DataTable.Port_Pos_Status = Port_Pos_Status';
        DataTable.Port_Position = Port_Position';
        DataTable.Port_Ent_Px = Port_Ent_Px';
        DataTable.Port_Ent_Dt = Port_Ent_Dt';

        %%  Trading results
        TradeTable.TradeNumber = Tra_Tbl.TradeNumber';
        TradeTable.Position = Tra_Tbl.Position';
        TradeTable.EntryDate = Tra_Tbl.Ent_Date';
        TradeTable.EntryPrice = Tra_Tbl.Ent_Px';
        TradeTable.Size = Tra_Tbl.Size';
        TradeTable.AvailableCapital = Tra_Tbl.Avai_Cap';
    

end

