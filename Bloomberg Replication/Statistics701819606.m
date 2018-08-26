function Stat_Trading = Statistics701819606(TradeTable, DataTable, InvestmentAmount, StartingDateIndex, RiskFreeRate)
    %   Trading Summary
    StatTable = TradeTable;
    for i = 1:length(StatTable.TradeNumber)
        StatTable_EntryDateIndex(i) = find(DataTable.Date == StatTable.EntryDate(i));
        StatTable_ExitDateIndex(i) = find(DataTable.Date == StatTable.ExitDate(i));  
    end
    StatTable.EntryDateIndex = StatTable_EntryDateIndex';
    StatTable.ExitDateIndex = StatTable_ExitDateIndex';
    StatTable.Duration = StatTable.ExitDateIndex - StatTable.EntryDateIndex;

    Stat_LongRowIndex = StatTable.Position == 1;
    Stat_ShortRowIndex = StatTable.Position == -1;
    StatTable_Long_tbl = StatTable(Stat_LongRowIndex,StatTable.Properties.VariableNames);
    StatTable_Short_tbl = StatTable(Stat_ShortRowIndex,StatTable.Properties.VariableNames);

    Stat_Trading = struct;

    Stat_Trading.LongTrades = length(StatTable_Long_tbl.TradeNumber);
    Stat_Trading.LongWins = length(find(StatTable_Long_tbl.ProfitandLoss > 0));
    Stat_Trading.LongLosses = length(find(StatTable_Long_tbl.ProfitandLoss <=0));
    Stat_Trading.LongTotal = Stat_Trading.LongWins + Stat_Trading.LongLosses;
    Stat_Trading.LongPnL = sum(StatTable_Long_tbl.ProfitandLoss);
    Stat_Trading.LongPnLpctg = Stat_Trading.LongPnL/InvestmentAmount * 100;

    Stat_Trading.ShortTrades = length(StatTable_Short_tbl.TradeNumber);
    Stat_Trading.ShortWins = length(find(StatTable_Short_tbl.ProfitandLoss > 0));
    Stat_Trading.ShortLosses = length(find(StatTable_Short_tbl.ProfitandLoss <=0));
    Stat_Trading.ShortTotal = Stat_Trading.ShortWins + Stat_Trading.ShortLosses;
    Stat_Trading.ShortPnL = sum(StatTable_Short_tbl.ProfitandLoss);
    Stat_Trading.ShortPnLpctg = Stat_Trading.ShortPnL/InvestmentAmount * 100;

    Stat_Trading.TotalTrades = Stat_Trading.LongTrades + Stat_Trading.ShortTrades;
    Stat_Trading.TotalWins = length(find(StatTable.ProfitandLoss > 0));
    Stat_Trading.TotalLosses = length(find(StatTable.ProfitandLoss <=0));
    Stat_Trading.TotalTotal = Stat_Trading.TotalWins + Stat_Trading.TotalLosses;
    Stat_Trading.TotalPnL = sum(StatTable.ProfitandLoss);
    Stat_Trading.TotalPnLpctg = Stat_Trading.TotalPnL/InvestmentAmount * 100;

    %   Additional Statistics
    %   For Long Positions
    Stat_Trading.LongAveragePnL = Stat_Trading.LongPnL / Stat_Trading.LongTrades;
    Stat_Trading.LongTotalWins = sum(StatTable_Long_tbl.ProfitandLoss(StatTable_Long_tbl.ProfitandLoss > 0));
    Stat_Trading.LongTotalLosses = abs(sum(StatTable_Long_tbl.ProfitandLoss(StatTable_Long_tbl.ProfitandLoss <= 0)));
    Stat_Trading.LongAverageWins = mean(StatTable_Long_tbl.ProfitandLoss(StatTable_Long_tbl.ProfitandLoss > 0));
    Stat_Trading.LongAverageLosses = abs(mean(StatTable_Long_tbl.ProfitandLoss(StatTable_Long_tbl.ProfitandLoss <= 0)));
    Stat_Trading.LongMaxWin = StatTable_Long_tbl.ProfitandLoss(StatTable_Long_tbl.ProfitandLoss == max(StatTable_Long_tbl.ProfitandLoss));
    Stat_Trading.LongMaxLoss = StatTable_Long_tbl.ProfitandLoss(StatTable_Long_tbl.ProfitandLoss == min(StatTable_Long_tbl.ProfitandLoss));
    
    if length(Stat_Trading.LongMaxLoss) > 1;
        Stat_Trading.LongMaxLoss = Stat_Trading.LongMaxLoss(1);
    end
    if length(Stat_Trading.LongMaxWin) > 1;
        Stat_Trading.LongMaxWin = Stat_Trading.LongMaxWin(1);
    end
    if isempty(Stat_Trading.LongMaxWin) || Stat_Trading.LongMaxWin < 0  
        Stat_Trading.LongMaxWin = 0;
    end
  
    if isempty(Stat_Trading.LongMaxLoss) || Stat_Trading.LongMaxLoss > 0
        Stat_Trading.LongMaxLoss = 0;
    else
        Stat_Trading.LongMaxLoss = abs(Stat_Trading.LongMaxLoss);
    end
    Stat_Trading.LongDuration = sum(StatTable_Long_tbl.Duration);

    %   For Short Positions
    Stat_Trading.ShortAveragePnL = Stat_Trading.ShortPnL / Stat_Trading.ShortTrades;
    Stat_Trading.ShortTotalWins = sum(StatTable_Short_tbl.ProfitandLoss(StatTable_Short_tbl.ProfitandLoss > 0));
    Stat_Trading.ShortTotalLosses = abs(sum(StatTable_Short_tbl.ProfitandLoss(StatTable_Short_tbl.ProfitandLoss <= 0)));
    Stat_Trading.ShortAverageWins = mean(StatTable_Short_tbl.ProfitandLoss(StatTable_Short_tbl.ProfitandLoss > 0));
    Stat_Trading.ShortAverageLosses = abs(mean(StatTable_Short_tbl.ProfitandLoss(StatTable_Short_tbl.ProfitandLoss <= 0)));
    Stat_Trading.ShortMaxWin = StatTable_Short_tbl.ProfitandLoss(StatTable_Short_tbl.ProfitandLoss == max(StatTable_Short_tbl.ProfitandLoss));
    Stat_Trading.ShortMaxLoss = StatTable_Short_tbl.ProfitandLoss(StatTable_Short_tbl.ProfitandLoss == min(StatTable_Short_tbl.ProfitandLoss));
    
    if length(Stat_Trading.ShortMaxLoss) > 1;
        Stat_Trading.ShortMaxLoss = Stat_Trading.ShortMaxLoss(1);
    end
    if length(Stat_Trading.ShortMaxWin) > 1;
        Stat_Trading.ShortMaxWin = Stat_Trading.ShortMaxWin(1);
    end
    if isempty(Stat_Trading.ShortMaxWin) || Stat_Trading.ShortMaxWin < 0  
        Stat_Trading.ShortMaxWin = 0;
    end
    if isempty(Stat_Trading.ShortMaxLoss) || Stat_Trading.ShortMaxLoss > 0
        Stat_Trading.ShortMaxLoss = 0;
    else
        Stat_Trading.ShortMaxLoss = abs(Stat_Trading.ShortMaxLoss);
    end
    Stat_Trading.ShortDuration = sum(StatTable_Short_tbl.Duration);

    %   For Totals
    Stat_Trading.TotalAveragePnL = Stat_Trading.TotalPnL / Stat_Trading.TotalTrades;
    Stat_Trading.TotalTotalWins = Stat_Trading.LongTotalWins + Stat_Trading.ShortTotalWins;
    Stat_Trading.TotalTotalLosses = Stat_Trading.LongTotalLosses + Stat_Trading.ShortTotalLosses;
    Stat_Trading.TotalAverageWins = Stat_Trading.TotalTotalWins / Stat_Trading.TotalWins;
    Stat_Trading.TotalAverageLosses = Stat_Trading.TotalTotalLosses / Stat_Trading.TotalLosses;
    Stat_Trading.TotalMaxWin = max(Stat_Trading.LongMaxWin, Stat_Trading.ShortMaxWin);
    Stat_Trading.TotalMaxLoss = max(Stat_Trading.LongMaxLoss, Stat_Trading.ShortMaxLoss);
    Stat_Trading.TotalDuration = Stat_Trading.LongDuration + Stat_Trading.ShortDuration;

    Stat_Port_Value = DataTable.Port_Value(StartingDateIndex:end) .* DataTable.Port_Pos_Status(StartingDateIndex:end) + DataTable.Port_Avai_Cap(StartingDateIndex:end);
    Stat_Port_Value(isnan(Stat_Port_Value)) = 0;
    Stat_Port_Return = Stat_Port_Value ./ InvestmentAmount - 1;
    % % % % % % % % % % % % % % % % % % % % % % % KInput: RiskFreeRate
    try 
        RiskFreeRate;
    catch
        RiskFreeRate = 0.0136;
    end

    Stat_Trading.AverageDuration = Stat_Trading.TotalDuration / Stat_Trading.TotalTrades;
    Stat_Trading.SharpeRatio = (mean(Stat_Port_Return) - RiskFreeRate) / std(Stat_Port_Return, 1);
    Stat_Trading.SortinoRatio = (mean(Stat_Port_Return) - RiskFreeRate) / std(Stat_Port_Return(Stat_Port_Return < 0), 1);
    Stat_Trading.TotalReturn = Stat_Trading.TotalPnLpctg;  

    Stat_Trading.Mx_Return_Pctg = max(Stat_Port_Return) * 100;
    Stat_Trading.Mn_Return_Pctg = min(Stat_Port_Return) * 100;

    %   MaxDrawDown
    [Stat_Port_H, Stat_Port_HIndex, Stat_Port_L, Stat_Port_LIndex, ~, ~] = TradeMaxDD701819606(Stat_Port_Value, 1);
    Stat_Trading.MaxDD = (Stat_Port_H - Stat_Port_L) / Stat_Port_H * 100;
    Stat_Trading.MaxDDLength = Stat_Port_LIndex - Stat_Port_HIndex;
    
end
