function [TradeTable, Trade_Stastics, DataTable] = GetTradeTableandStatistics701819606(DataTable, WindowsLength, IdenticialFactor, UpperBandFactor, LowerBandFactor, PorS, StartegyNo, InvestmentAmount, StartingTime, TradingSize, RiskFreeRate)
%%  Variables Explanation
%   DataTable               Source of Data, must including Date and Close
%   Columns
%   WindowsLength           Day of Moving Average Using
%   IdenticialFactor        1:  using UpperBandFactor as LowerBandFactor,
%   and input LowerBandFactor will be overwritten;  0:  using different
%   factor for LowerBandFactor
%   UpperBandFactor         Factor used for UpperBand
%   LowerBandFactor         Factor used for LowerBand
%   PorS                    1 for Population;   0 for Sample
%   StartegyNo              1 : using Bloomberg, 2 : using Dr.k's
%   TradingSize             Define size for each transaction, 0 for
%   all-in
%   InvestmentAmount        Amount of capital will be used in trading
%   StartingTime            Time (Year) to start trading
    %%  Calculating Bollinger Bands
    %   Moving Average Window
    if IdenticialFactor == 1
            LowerBandFactor = UpperBandFactor;
    end
    Close = DataTable.Close;
    MovingAverage = movmean(Close, [WindowsLength - 1, 0]);
    DataTable.MA = MovingAverage;
    MovingStd = movstd(Close, [WindowsLength - 1, 0], PorS);
    DataTable.MSTD = MovingStd;

    LowerBand = MovingAverage - LowerBandFactor * MovingStd;
    DataTable.LowerBand = LowerBand;
    UpperBand = MovingAverage + UpperBandFactor * MovingStd;
    DataTable.UpperBand = UpperBand;

    Bandwidth = 100 .* (UpperBand - LowerBand) ./ MovingAverage;
    DataTable.Bandwidth = Bandwidth;

    PercentageBand = (Close - LowerBand) ./ (UpperBand - LowerBand);
    DataTable.PercentageBand = PercentageBand;

    %%  Create signals for trading
    switch StartegyNo
        case 1
            DataTable = Signal701819606_strategy1(DataTable);
        case 2
            DataTable = Signal701819606_strategy2(DataTable);
    end

    %%  Trading Process
    StartingDateIndex = find(year(DataTable.Date) == StartingTime, 1);
    try
        if TradingSize == 0
            clearvars TradingSize;
        end
    end
    
    switch StartegyNo
        case 1
            try
                [DataTable, TradeTable] = Trading701819606_strategy1(StartingDateIndex, DataTable, InvestmentAmount, TradingSize);
            catch
                [DataTable, TradeTable] = Trading701819606_strategy1(StartingDateIndex, DataTable, InvestmentAmount);
            end
        case 2
            try
                [DataTable, TradeTable] = Trading701819606_strategy2(StartingDateIndex, DataTable, InvestmentAmount, TradingSize);
            catch
                [DataTable, TradeTable] = Trading701819606_strategy2(StartingDateIndex, DataTable, InvestmentAmount);
            end
    end

    TradeTableLength = TradeTable.TradeNumber(end);

    %   i will loop over TradeTable
    for i = 1:TradeTableLength
        TradeTable_Position = TradeTable.Position(i);
        %   Column: Ex_Date & Ex_Px
        for j = i:TradeTableLength
            if TradeTable_Position ~= TradeTable.Position(j)
                TradeTable_Ex_Date(i) = TradeTable.EntryDate(j);
                TradeTable_Ex_Px(i) = TradeTable.EntryPrice(j);
                break
            end
            if j == TradeTableLength && TradeTable_Position == TradeTable.Position(j)
                TradeTable_Ex_Date(i) = TradeTable.EntryDate(j);
                TradeTable_Ex_Px(i) = TradeTable.EntryPrice(j);
                break
            end
            
        end    
        if i == TradeTableLength
            TradeTable_Ex_Date(i) = DataTable.Date(end);
            TradeTable_Ex_Px(i) = DataTable.Close(end);
        end
        %   Column: PnL & Cum. PnL & TotalReturn
        if TradeTable_Position == 1  %   Position == 1 means Long
            TradeTable_PnL(i) = (TradeTable_Ex_Px(i) - TradeTable.EntryPrice(i))*TradeTable.Size(i);
        else    %   Position == -1 means Short
            TradeTable_PnL(i) = ( - TradeTable_Ex_Px(i) + TradeTable.EntryPrice(i))*TradeTable.Size(i);
        end
    % % % %     if i == TradeTableLength
    % % % %         if TradeTable_Position == 1  %   Position == 1 means Long
    % % % %             TradeTable_PnL(i) = (DataTable.Close(end) - TradeTable.EntryPrice(i))*TradeTable.Size(i);
    % % % %         else    %   Position == -1 means Short
    % % % %             TradeTable_PnL(i) = ( - DataTable.Close(end) + TradeTable.EntryPrice(i))*TradeTable.Size(i);
    % % % %         end
    % % % %     end
        TradeTable_CumPnL(i) = sum(TradeTable_PnL);
        TradeTable_TTLRet(i) = 100 * TradeTable_PnL(i)/ ((TradeTable.EntryPrice(i) * TradeTable.Size(i) * TradeTable.Position(i)) + TradeTable.AvailableCapital(i));

        %   Column: Max Return & Min Return
        dt_tbl_starting_index = find(DataTable.Date == TradeTable.EntryDate(i), 1);
        dt_tbl_ending_index = find(DataTable.Date == TradeTable_Ex_Date(i), 1);
        temp_Mx_Ret = -99999;
        temp_Mn_Ret = 99999;
        %   j will loop over DataTable
        for j = dt_tbl_starting_index:dt_tbl_ending_index % Duration for one trade; 
            %   daily portfolio profit and loss
            if TradeTable_Position == 1  %   Position == 1 means Long
                dt_tbl_pnl = (DataTable.Close(j) - TradeTable.EntryPrice(i))*TradeTable.Size(i);
            else    %   Position == -1 means Short
                dt_tbl_pnl = ( - DataTable.Close(j) + TradeTable.EntryPrice(i))*TradeTable.Size(i);
            end
            temp_Mx_Ret = max(temp_Mx_Ret, 100 * dt_tbl_pnl/((TradeTable.EntryPrice(i) * TradeTable.Size(i) * TradeTable.Position(i)) + TradeTable.AvailableCapital(i)));
            temp_Mn_Ret = min(temp_Mn_Ret, 100 * dt_tbl_pnl/((TradeTable.EntryPrice(i) * TradeTable.Size(i) * TradeTable.Position(i)) + TradeTable.AvailableCapital(i)));

        end
        if temp_Mx_Ret == -99999
            temp_Mx_Ret = 0;
        end
        if temp_Mn_Ret == 99999
            temp_Mn_Ret = 0;
        end

        TradeTable_MaxReturn(i) = temp_Mx_Ret;
        TradeTable_MinReturn(i) = temp_Mn_Ret;

    end

    TradeTable.ExitDate = TradeTable_Ex_Date';
    TradeTable.ExitPrice = TradeTable_Ex_Px';
    TradeTable.ProfitandLoss = TradeTable_PnL';
    TradeTable.CumProfitandLoss = TradeTable_CumPnL';
    TradeTable.TotalReturn = TradeTable_TTLRet';
    TradeTable.MaxReturn = TradeTable_MaxReturn';
    TradeTable.MinReturn = TradeTable_MinReturn';

    %   i will loop over TradeTable
    for i = 1:TradeTableLength
        %   Column: MaxDrawDown && MaxDDLength
        %   MaxDDRecovery && RecoveryfromMaxDD
        %   MaxIncrease && MaxIncreaseLength
        if i < TradeTableLength + 1
                %   Column: MaxDrawDown && MaxDDLength && MaxDDRecovery && RecoveryfromMaxDD
                TradeTable_Position = TradeTable.Position(i);
                dt_tbl_starting_index = find(DataTable.Date == TradeTable.EntryDate(i), 1);
                dt_tbl_ending_index = find(DataTable.Date == TradeTable.ExitDate(i), 1);
                DailyPX_in_Trade = DataTable.Close(dt_tbl_starting_index:dt_tbl_ending_index);

                [DD_PeakPX, DD_PeakIndex, DD_BottomPX, DD_BottomIndex, DD_RecovPX, DD_RecovIndex] = TradeMaxDD701819606(DailyPX_in_Trade, TradeTable_Position);
                dt_tbl_dd_peak_index = dt_tbl_starting_index - 1 + DD_PeakIndex;
                dt_tbl_dd_bottom_index = dt_tbl_starting_index - 1 + DD_BottomIndex;
                temp_DD = (DD_PeakPX - DD_BottomPX) * DataTable.Port_Position(dt_tbl_dd_peak_index) / (DD_PeakPX * DataTable.Port_Position(dt_tbl_dd_peak_index) + DataTable.Port_Avai_Cap(dt_tbl_dd_peak_index));
                %   DrawDown period
                temp_Mx_DD_Length = dt_tbl_dd_bottom_index - dt_tbl_dd_peak_index;
                if isnan(DD_RecovIndex)
                    dt_tbl_recov_index = -1;
                    temp_Rc_DD_Length = -1;
                    temp_DD_Rc_Length = -1;
                elseif temp_DD == 0
                    temp_Mx_DD_Length = 0;
                    temp_Rc_DD_Length = 0;
                    temp_DD_Rc_Length = 0;                
                else
                    dt_tbl_recov_index = dt_tbl_starting_index - 1 + DD_RecovIndex;
                    %   Recovery From DrawDown (from bottom point to peak);
                    temp_Rc_DD_Length = dt_tbl_recov_index - dt_tbl_dd_bottom_index;
                    %   DrawDown Recovery (Periods for reaching peak again);
                    temp_DD_Rc_Length = dt_tbl_recov_index - dt_tbl_dd_peak_index;
                end  


                [MI_PeakPX, MI_PeakIndex, MI_BottomPX, MI_BottomIndex] = MaxIncrease701819606(DailyPX_in_Trade, TradeTable_Position);
                dt_tbl_mi_peak_index = dt_tbl_starting_index - 1 + MI_PeakIndex;
                dt_tbl_mi_bottom_index = dt_tbl_starting_index - 1 + MI_BottomIndex;
                temp_MI = (MI_PeakPX - MI_BottomPX) * DataTable.Port_Position(dt_tbl_mi_bottom_index) / (MI_PeakPX * DataTable.Port_Position(dt_tbl_mi_bottom_index) + DataTable.Port_Avai_Cap(dt_tbl_mi_bottom_index));
                %   MaxIncreaseLength
                temp_Mx_IN_Length = dt_tbl_mi_peak_index - dt_tbl_mi_bottom_index;
        else
                temp_DD = 0;
                temp_Mx_DD_Length = 0;
                temp_Rc_DD_Length = 0;
                temp_DD_Rc_Length = 0;
                temp_MI = 0;
                temp_Mx_IN_Length = 0;
        end

        TradeTable_MaxDrawDown(i) = 100 * temp_DD;
        TradeTable_MaxDD_Length(i) = temp_Mx_DD_Length;
        TradeTable_Reco_Frm_Mx_DD(i) = temp_Rc_DD_Length;
        TradeTable_DD_Recovery(i) = temp_DD_Rc_Length;
        TradeTable_MaxIncrease(i) = 100 * temp_MI;
        TradeTable_MaxIN_Length(i) = temp_Mx_IN_Length;
    end

    TradeTable.MaxDrawDown = TradeTable_MaxDrawDown';
    TradeTable.MaxDDLength = TradeTable_MaxDD_Length';
    TradeTable.RecoveryFromMaxDD = TradeTable_Reco_Frm_Mx_DD';
    TradeTable.DrawDownRecovery = TradeTable_DD_Recovery';
    TradeTable.MaxIncrease = TradeTable_MaxIncrease';
    TradeTable.MaxINLength = TradeTable_MaxIN_Length';

    %%   Trading Statistics
    try 
        RiskFreeRate;
        Trade_Stastics = Statistics701819606(TradeTable, DataTable, InvestmentAmount, StartingDateIndex, RiskFreeRate);
    catch
        Trade_Stastics = Statistics701819606(TradeTable, DataTable, InvestmentAmount, StartingDateIndex);
    end
end
