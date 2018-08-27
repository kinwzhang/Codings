clear all

load('Data_T_1644.mat')
%%  Backtesting Process
RiskFreeRate = 0.0136;
%% Example 1
%   The folling line runs tradetable and statistics using 20 day moving
%   average for bollinger bands, 2 as factors for upper band and lower
%   band, using population, backtesting on Bloomberg's strategy with 100k
%   initial investment, and trades begins in 2007, each transaction is
%   limited to 100 shares.
[TradeTable_Example1, Trade_Stastics_Example1, DataTable_Example1] = GetTradeTableandStatistics701819606(DataTable, 20, 0, 2, 2, 1, 1,100000, 2007, 100, RiskFreeRate);

%%  Example 2
%   The following line runs tradetable and statistics using 252 day moving
%   average for bollinger bands, 3 as factors for upper band and lower
%   band, using sample for standard derivation, backtesting on the second
%   strategy with 100k initial investment, and trades begins in 2007, each
%   transaction will utilize maximum available capital
[TradeTable_Example2, Trade_Stastics_Example2, DataTable_Example2] = GetTradeTableandStatistics701819606(DataTable, 252, 1, 3, 2, 0, 2,100000, 2007, 0, RiskFreeRate);

%%  Optimization Process
%   Example 1
current_row = 1;
for WindowsLength = 5:185
    for UpperBandFactor = 1.5:0.1:3.5
        LowerBandFactor = UpperBandFactor;
        %   Using All-in
        opti_result(current_row, 1) = WindowsLength;
        opti_result(current_row, 2) = UpperBandFactor;
        opti_result(current_row, 3) = LowerBandFactor;
    
        [~, TradingStastics, ~] = GetTradeTableandStatistics701819606(DataTable, WindowsLength, 0, UpperBandFactor, LowerBandFactor, 1, 1,100000, 2007, 100, RiskFreeRate);
        column_names = fieldnames(TradingStastics);

        for i = 1:length(column_names)
            opti_result(current_row, i + 3) = getfield(TradingStastics, column_names{i,1});
        end
%         display_text = 'Current working on Row %i, with MA: %i Upper and Lower: %.2f.';
%         disp(sprintf(display_text, current_row, WindowsLength, UpperBandFactor))
       
        current_row = current_row + 1;
    end
end

OptimizationTable = array2table(opti_result);
OptimizationTable.Properties.VariableNames = ['MA_Window_Length', 'UpperbandFactor', 'LowerBandFactor', column_names'];
disp('Optimization Result is stored in variable "OptimizationTable_Example1".')
clearvars column_names current_row display_text i opti_result Trade_Stastics LowerBandFactor UpperBandFactor WindowsLength
OptimizationTable_Example1 = OptimizationTable;

OptimizationTable_Example1 = sortrows(OptimizationTable_Example1,'TotalPnL','descend');
display_text = 'The best, by Total Profit and Loss, parameter for the run backtesting was using:\n%i day moving average, \nwith UpperBandFactor: %.2f and LowerBandFactor: %.2f.';
disp(sprintf(display_text, OptimizationTable_Example1.MA_Window_Length(1), OptimizationTable_Example1.UpperbandFactor(1), OptimizationTable_Example1.LowerBandFactor(1)))

save('Sample1_1223.mat')

%   Example 2
current_row = 1;
for WindowsLength = 5:185
    for UpperBandFactor = 1.5:0.1:3.5
        LowerBandFactor = UpperBandFactor;
        %   Using All-in
        opti_result(current_row, 1) = WindowsLength;
        opti_result(current_row, 2) = UpperBandFactor;
        opti_result(current_row, 3) = LowerBandFactor;
    
        [~, TradingStastics, ~] = GetTradeTableandStatistics701819606(DataTable, WindowsLength, 1, UpperBandFactor, LowerBandFactor, 0, 2,100000, 2007, 0, RiskFreeRate);
        column_names = fieldnames(TradingStastics);

        for i = 1:length(column_names)
            opti_result(current_row, i + 3) = getfield(TradingStastics, column_names{i,1});
        end
%         display_text = 'Current working on Row %i, with MA: %i Upper and Lower: %.2f.';
%         disp(sprintf(display_text, current_row, WindowsLength, UpperBandFactor))
       
        current_row = current_row + 1;
    end
end

OptimizationTable = array2table(opti_result);
OptimizationTable.Properties.VariableNames = ['MA_Window_Length', 'UpperbandFactor', 'LowerBandFactor', column_names'];
disp('Optimization Result is stored in variable "OptimizationTable_Example2".')
clearvars column_names current_row display_text i opti_result Trade_Stastics LowerBandFactor UpperBandFactor WindowsLength
OptimizationTable_Example2 = OptimizationTable;

display_text = 'The best, by Total Profit and Loss, parameter for the run backtesting was using:\n%i day moving average, \nwith UpperBandFactor: %.2f and LowerBandFactor: %.2f.';
disp(sprintf(display_text, OptimizationTable_Example2.MA_Window_Length(1), OptimizationTable_Example2.UpperbandFactor(1), OptimizationTable_Example2.LowerBandFactor(1)))
save('Sample2_1223.mat')

%%
1+1;
%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%    Referencing functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % function [TradeTable, Trade_Stastics, DataTable] = GetTradeTableandStatistics701819606(DataTable, WindowsLength, IdenticialFactor, UpperBandFactor, LowerBandFactor, PorS, StartegyNo, InvestmentAmount, StartingTime, TradingSize, RiskFreeRate)
% % % %%  Variables Explanation
% % % %   DataTable               Source of Data, must including Date and Close
% % % %   Columns WindowsLength           Day of Moving Average Using
% % % %   IdenticialFactor        1:  using UpperBandFactor as LowerBandFactor,
% % % %   and input LowerBandFactor will be overwritten;  0:  using different
% % % %   factor for LowerBandFactor UpperBandFactor         Factor used for
% % % %   UpperBand LowerBandFactor         Factor used for LowerBand PorS 1 for
% % % %   Population;   0 for Sample StartegyNo              1 : using Bloomberg,
% % % %   2 : using Dr.k's TradingSize             Define size for each
% % % %   transaction, 0 for all-in InvestmentAmount        Amount of capital
% % % %   will be used in trading StartingTime            Time (Year) to start
% % % %   trading
% % %     %%  Calculating Bollinger Bands
% % %     %   Moving Average Window
% % %     if IdenticialFactor == 1
% % %             LowerBandFactor = UpperBandFactor;
% % %     end
% % %     Close = DataTable.Close;
% % %     MovingAverage = movmean(Close, [WindowsLength - 1, 0]);
% % %     DataTable.MA = MovingAverage;
% % %     MovingStd = movstd(Close, [WindowsLength - 1, 0], PorS);
% % %     DataTable.MSTD = MovingStd;
% % % 
% % %     LowerBand = MovingAverage - LowerBandFactor * MovingStd;
% % %     DataTable.LowerBand = LowerBand;
% % %     UpperBand = MovingAverage + UpperBandFactor * MovingStd;
% % %     DataTable.UpperBand = UpperBand;
% % % 
% % %     Bandwidth = 100 .* (UpperBand - LowerBand) ./ MovingAverage;
% % %     DataTable.Bandwidth = Bandwidth;
% % % 
% % %     PercentageBand = (Close - LowerBand) ./ (UpperBand - LowerBand);
% % %     DataTable.PercentageBand = PercentageBand;
% % % 
% % %     %%  Create signals for trading
% % %     switch StartegyNo
% % %         case 1
% % %             DataTable = Signal701819606_strategy1(DataTable);
% % %         case 2
% % %             DataTable = Signal701819606_strategy2(DataTable);
% % %     end
% % % 
% % %     %%  Trading Process
% % %     StartingDateIndex = find(year(DataTable.Date) == StartingTime, 1);
% % %     try
% % %         if TradingSize == 0
% % %             clearvars TradingSize;
% % %         end
% % %     end
% % %     
% % %     switch StartegyNo
% % %         case 1
% % %             try
% % %                 [DataTable, TradeTable] = Trading701819606_strategy1(StartingDateIndex, DataTable, InvestmentAmount, TradingSize);
% % %             catch
% % %                 [DataTable, TradeTable] = Trading701819606_strategy1(StartingDateIndex, DataTable, InvestmentAmount);
% % %             end
% % %         case 2
% % %             try
% % %                 [DataTable, TradeTable] = Trading701819606_strategy2(StartingDateIndex, DataTable, InvestmentAmount, TradingSize);
% % %             catch
% % %                 [DataTable, TradeTable] = Trading701819606_strategy2(StartingDateIndex, DataTable, InvestmentAmount);
% % %             end
% % %     end
% % % 
% % %     TradeTableLength = TradeTable.TradeNumber(end);
% % % 
% % %     %   i will loop over TradeTable
% % %     for i = 1:TradeTableLength
% % %         TradeTable_Position = TradeTable.Position(i);
% % %         %   Column: Ex_Date & Ex_Px
% % %         for j = i:TradeTableLength
% % %             if TradeTable_Position ~= TradeTable.Position(j)
% % %                 TradeTable_Ex_Date(i) = TradeTable.EntryDate(j);
% % %                 TradeTable_Ex_Px(i) = TradeTable.EntryPrice(j);
% % %                 break
% % %             end
% % %         end    
% % %         if i == TradeTableLength
% % %             TradeTable_Ex_Date(i) = DataTable.Date(end);
% % %             TradeTable_Ex_Px(i) = DataTable.Close(end);
% % %         end
% % %         %   Column: PnL & Cum. PnL & TotalReturn
% % %         if TradeTable_Position == 1  %   Position == 1 means Long
% % %             TradeTable_PnL(i) = (TradeTable_Ex_Px(i) - TradeTable.EntryPrice(i))*TradeTable.Size(i);
% % %         else    %   Position == -1 means Short
% % %             TradeTable_PnL(i) = ( - TradeTable_Ex_Px(i) + TradeTable.EntryPrice(i))*TradeTable.Size(i);
% % %         end
% % %     % % % %     if i == TradeTableLength % % %         if
% % %     % TradeTable_Position == 1  %   Position == 1 means Long % % %
% % %     % TradeTable_PnL(i) = (DataTable.Close(end) -
% % %     % TradeTable.EntryPrice(i))*TradeTable.Size(i); % % %         else    %
% % %     % Position == -1 means Short % % %             TradeTable_PnL(i) = ( -
% % %     % DataTable.Close(end) + TradeTable.EntryPrice(i))*TradeTable.Size(i);
% % %     % % % %         end % % %     end
% % %         TradeTable_CumPnL(i) = sum(TradeTable_PnL);
% % %         TradeTable_TTLRet(i) = 100 * TradeTable_PnL(i)/ ((TradeTable.EntryPrice(i) * TradeTable.Size(i) * TradeTable.Position(i)) + TradeTable.AvailableCapital(i));
% % % 
% % %         %   Column: Max Return & Min Return
% % %         dt_tbl_starting_index = find(DataTable.Date == TradeTable.EntryDate(i), 1);
% % %         dt_tbl_ending_index = find(DataTable.Date == TradeTable_Ex_Date(i), 1);
% % %         temp_Mx_Ret = -99999;
% % %         temp_Mn_Ret = 99999;
% % %         %   j will loop over DataTable
% % %         for j = dt_tbl_starting_index:dt_tbl_ending_index % Duration for one trade; 
% % %             %   daily portfolio profit and loss
% % %             if TradeTable_Position == 1  %   Position == 1 means Long
% % %                 dt_tbl_pnl = (DataTable.Close(j) - TradeTable.EntryPrice(i))*TradeTable.Size(i);
% % %             else    %   Position == -1 means Short
% % %                 dt_tbl_pnl = ( - DataTable.Close(j) + TradeTable.EntryPrice(i))*TradeTable.Size(i);
% % %             end
% % %             temp_Mx_Ret = max(temp_Mx_Ret, 100 * dt_tbl_pnl/((TradeTable.EntryPrice(i) * TradeTable.Size(i) * TradeTable.Position(i)) + TradeTable.AvailableCapital(i)));
% % %             temp_Mn_Ret = min(temp_Mn_Ret, 100 * dt_tbl_pnl/((TradeTable.EntryPrice(i) * TradeTable.Size(i) * TradeTable.Position(i)) + TradeTable.AvailableCapital(i)));
% % % 
% % %         end
% % %         if temp_Mx_Ret == -99999
% % %             temp_Mx_Ret = 0;
% % %         end
% % %         if temp_Mn_Ret == 99999
% % %             temp_Mn_Ret = 0;
% % %         end
% % % 
% % %         TradeTable_MaxReturn(i) = temp_Mx_Ret;
% % %         TradeTable_MinReturn(i) = temp_Mn_Ret;
% % % 
% % %     end
% % % 
% % %     TradeTable.ExitDate = TradeTable_Ex_Date';
% % %     TradeTable.ExitPrice = TradeTable_Ex_Px';
% % %     TradeTable.ProfitandLoss = TradeTable_PnL';
% % %     TradeTable.CumProfitandLoss = TradeTable_CumPnL';
% % %     TradeTable.TotalReturn = TradeTable_TTLRet';
% % %     TradeTable.MaxReturn = TradeTable_MaxReturn';
% % %     TradeTable.MinReturn = TradeTable_MinReturn';
% % % 
% % %     %   i will loop over TradeTable
% % %     for i = 1:TradeTableLength
% % %         %   Column: MaxDrawDown && MaxDDLength MaxDDRecovery &&
% % %         %   RecoveryfromMaxDD MaxIncrease && MaxIncreaseLength
% % %         if i < TradeTableLength + 1
% % %                 %   Column: MaxDrawDown && MaxDDLength && MaxDDRecovery &&
% % %                 %   RecoveryfromMaxDD
% % %                 TradeTable_Position = TradeTable.Position(i);
% % %                 dt_tbl_starting_index = find(DataTable.Date == TradeTable.EntryDate(i), 1);
% % %                 dt_tbl_ending_index = find(DataTable.Date == TradeTable.ExitDate(i), 1);
% % %                 DailyPX_in_Trade = DataTable.Close(dt_tbl_starting_index:dt_tbl_ending_index);
% % % 
% % %                 [DD_PeakPX, DD_PeakIndex, DD_BottomPX, DD_BottomIndex, DD_RecovPX, DD_RecovIndex] = TradeMaxDD701819606(DailyPX_in_Trade, TradeTable_Position);
% % %                 dt_tbl_dd_peak_index = dt_tbl_starting_index - 1 + DD_PeakIndex;
% % %                 dt_tbl_dd_bottom_index = dt_tbl_starting_index - 1 + DD_BottomIndex;
% % %                 temp_DD = (DD_PeakPX - DD_BottomPX) * DataTable.Port_Position(dt_tbl_dd_peak_index) / (DD_PeakPX * DataTable.Port_Position(dt_tbl_dd_peak_index) + DataTable.Port_Avai_Cap(dt_tbl_dd_peak_index));
% % %                 %   DrawDown period
% % %                 temp_Mx_DD_Length = dt_tbl_dd_bottom_index - dt_tbl_dd_peak_index;
% % %                 if isnan(DD_RecovIndex)
% % %                     dt_tbl_recov_index = -1;
% % %                     temp_Rc_DD_Length = -1;
% % %                     temp_DD_Rc_Length = -1;
% % %                 elseif temp_DD == 0
% % %                     temp_Mx_DD_Length = 0;
% % %                     temp_Rc_DD_Length = 0;
% % %                     temp_DD_Rc_Length = 0;                
% % %                 else
% % %                     dt_tbl_recov_index = dt_tbl_starting_index - 1 + DD_RecovIndex;
% % %                     %   Recovery From DrawDown (from bottom point to peak);
% % %                     temp_Rc_DD_Length = dt_tbl_recov_index - dt_tbl_dd_bottom_index;
% % %                     %   DrawDown Recovery (Periods for reaching peak
% % %                     %   again);
% % %                     temp_DD_Rc_Length = dt_tbl_recov_index - dt_tbl_dd_peak_index;
% % %                 end  
% % % 
% % % 
% % %                 [MI_PeakPX, MI_PeakIndex, MI_BottomPX, MI_BottomIndex] = MaxIncrease701819606(DailyPX_in_Trade, TradeTable_Position);
% % %                 dt_tbl_mi_peak_index = dt_tbl_starting_index - 1 + MI_PeakIndex;
% % %                 dt_tbl_mi_bottom_index = dt_tbl_starting_index - 1 + MI_BottomIndex;
% % %                 temp_MI = (MI_PeakPX - MI_BottomPX) * DataTable.Port_Position(dt_tbl_mi_bottom_index) / (MI_PeakPX * DataTable.Port_Position(dt_tbl_mi_bottom_index) + DataTable.Port_Avai_Cap(dt_tbl_mi_bottom_index));
% % %                 %   MaxIncreaseLength
% % %                 temp_Mx_IN_Length = dt_tbl_mi_peak_index - dt_tbl_mi_bottom_index;
% % %         else
% % %                 temp_DD = 0;
% % %                 temp_Mx_DD_Length = 0;
% % %                 temp_Rc_DD_Length = 0;
% % %                 temp_DD_Rc_Length = 0;
% % %                 temp_MI = 0;
% % %                 temp_Mx_IN_Length = 0;
% % %         end
% % % 
% % %         TradeTable_MaxDrawDown(i) = 100 * temp_DD;
% % %         TradeTable_MaxDD_Length(i) = temp_Mx_DD_Length;
% % %         TradeTable_Reco_Frm_Mx_DD(i) = temp_Rc_DD_Length;
% % %         TradeTable_DD_Recovery(i) = temp_DD_Rc_Length;
% % %         TradeTable_MaxIncrease(i) = 100 * temp_MI;
% % %         TradeTable_MaxIN_Length(i) = temp_Mx_IN_Length;
% % %     end
% % % 
% % %     TradeTable.MaxDrawDown = TradeTable_MaxDrawDown';
% % %     TradeTable.MaxDDLength = TradeTable_MaxDD_Length';
% % %     TradeTable.RecoveryFromMaxDD = TradeTable_Reco_Frm_Mx_DD';
% % %     TradeTable.DrawDownRecovery = TradeTable_DD_Recovery';
% % %     TradeTable.MaxIncrease = TradeTable_MaxIncrease';
% % %     TradeTable.MaxINLength = TradeTable_MaxIN_Length';
% % % 
% % %     %%   Trading Statistics
% % %     try 
% % %         RiskFreeRate;
% % %         Trade_Stastics = Statistics701819606(TradeTable, DataTable, InvestmentAmount, StartingDateIndex, RiskFreeRate);
% % %     catch
% % %         Trade_Stastics = Statistics701819606(TradeTable, DataTable, InvestmentAmount, StartingDateIndex);
% % %     end
% % % end
% % % 
% % % function DataTable = Signal701819606_strategy1(DataTable)
% % % 
% % % %%  Create signals for trading
% % % %   Destination Variable: Signal && DataTable.Signal Cover & go long When
% % % %   Closing cross below LowerBand
% % % CloseBelowLowerBand = DataTable.Close <= DataTable.LowerBand;
% % % LongSignal = [0, diff(CloseBelowLowerBand)']';
% % % LongSignal(LongSignal == -1) = 0; 
% % % DataTable.LongSignal = LongSignal;
% % % 
% % % %   Close & go short When Closing cross above UpperBand
% % % CloseAboveUpperBand = DataTable.Close >= DataTable.UpperBand;
% % % ShortSignal = [0, diff(CloseAboveUpperBand)']';
% % % ShortSignal(ShortSignal == -1) = 0;
% % % ShortSignal = -ShortSignal;
% % % DataTable.ShortSignal = ShortSignal;
% % % 
% % % %   Signal: -1 means close & go short 1 means cover & go long
% % % Signal = (LongSignal + ShortSignal) .* 2;
% % % DataTable.Signal = Signal;
% % % 
% % % end
% % % 
% % % function DataTable = Signal701819606_strategy2(DataTable)
% % % 
% % % %%  Create signals for trading
% % % %   Destination Variable: Signal && DataTable.Signal
% % % 
% % % 
% % % %   Short Signal, Closing Price above upperband
% % % CloseAboveUpperBand = DataTable.Close >= DataTable.UpperBand;
% % % ShortSignal = CloseAboveUpperBand;
% % % ShortSignal = -ShortSignal;
% % % DataTable.ShortSignal = ShortSignal;
% % % 
% % % %   Cover Signal, Closing Price Cross below upperband
% % % CloseCrossBelowUpperBand = DataTable.Close < DataTable.UpperBand;
% % % CoverSignal = [0, diff(CloseCrossBelowUpperBand)']';
% % % CoverSignal(CoverSignal == -1) = 0;
% % % 
% % % DataTable.CoverSignal = CoverSignal;
% % % 
% % % %   Long Signal, Closing Price below lowerband
% % % CloseBelowLowerBand = DataTable.Close <= DataTable.LowerBand;
% % % LongSignal = CloseBelowLowerBand;
% % % DataTable.LongSignal = LongSignal;
% % % 
% % % %   Close Signal, Closing Price Cross above lowerband
% % % CloseCrossAboveLowerBand = DataTable.Close > DataTable.LowerBand;
% % % CloseSignal = [0, diff(CloseCrossAboveLowerBand)']';
% % % CloseSignal(CloseSignal == -1) = 0;
% % % CloseSignal = -CloseSignal;
% % % DataTable.CloseSignal = CloseSignal;
% % % %   Signal: -1 means close & go short 1 means cover & go long
% % % Signal = (LongSignal + ShortSignal) .* 2;
% % % Signal = Signal + CloseSignal + CoverSignal;
% % % DataTable.Signal = Signal;
% % % 
% % % 
% % % end
% % % 
% % % function [DataTable, TradeTable] = Trading701819606(StartingDateIndex, DataTable, InvestmentAmount, Size)
% % % 
% % % %       Bloomberg Startegy Ignore repeat signals in the same direction.
% % % 
% % %     LongSignalCount = sum(DataTable.Signal == 2);
% % %     ShortSignalCount = sum(DataTable.Signal == -2);
% % %     TradeTable = table;
% % %     Tra_Tbl = struct;
% % %     TradeTableCurrentRow = 1;
% % %     if LongSignalCount == 0 && ShortSignalCount == 0 %% In case there is no trade happens
% % %         Portfolio = PortfolioInitialization701819606(InvestmentAmount, StartingDateIndex, DataTable.Date);
% % %         Tra_Tbl = WriteTradeTable701819606(Portfolio, Tra_Tbl, TradeTableCurrentRow);
% % %         Port_Avai_Cap(1:length(DataTable.Date)) = Portfolio.AvailableCapital;
% % %         Port_Value(1:length(DataTable.Date)) = Portfolio.Value;
% % %         Port_Pos_Status(1:length(DataTable.Date)) = Portfolio.PositionStatus;
% % %         Port_Position(1:length(DataTable.Date)) = Portfolio.Position;
% % %         Port_Ent_Px(1:length(DataTable.Date)) = Portfolio.EntryPrice;
% % %         Port_Ent_Dt(1:length(DataTable.Date)) = Portfolio.EntryDate;
% % %     else
% % %         for TradingDayIndex = StartingDateIndex:length(DataTable.Date)
% % %             if TradingDayIndex == StartingDateIndex
% % %                 Portfolio = PortfolioInitialization701819606(InvestmentAmount, TradingDayIndex, DataTable.Date);
% % %             end
% % %             %   Trading at current close
% % %             TradingPX = DataTable.Close(TradingDayIndex);
% % %             CurrentSignal = DataTable.Signal(TradingDayIndex);
% % %             switch CurrentSignal
% % %                 case 0
% % %                     %   Hold Executor
% % %                     Portfolio = Executor701819606(Portfolio, TradingPX, DataTable.Date, TradingDayIndex, 0);
% % % 
% % %                     Port_Avai_Cap(TradingDayIndex) = Portfolio.AvailableCapital;
% % %                     Port_Value(TradingDayIndex) = Portfolio.Value;
% % %                     Port_Pos_Status(TradingDayIndex) = Portfolio.PositionStatus;
% % %                     Port_Position(TradingDayIndex) = Portfolio.Position;
% % %                     Port_Ent_Px(TradingDayIndex) = Portfolio.EntryPrice;
% % %                     Port_Ent_Dt(TradingDayIndex) = Portfolio.EntryDate;
% % % 
% % %                 case 2
% % %                     %   Long Executor(handling Long Signals) Action 1
% % %                     if Portfolio.Position < 0   %   Cover First
% % %                         Portfolio = Executor701819606(Portfolio, TradingPX, DataTable.Date, TradingDayIndex, 1);
% % %                     end
% % %                     %   Action 2
% % %                     if Portfolio.Position == 0  %   Go Long
% % %                         try
% % %                             Portfolio = Executor701819606(Portfolio, TradingPX, DataTable.Date, TradingDayIndex, 2, Size);
% % %                         catch
% % %                             Portfolio = Executor701819606(Portfolio, TradingPX, DataTable.Date, TradingDayIndex, 2);
% % %                         end
% % %                         %   Write the trade into trade table
% % %                         Tra_Tbl = WriteTradeTable701819606(Portfolio, Tra_Tbl, TradeTableCurrentRow);
% % %                         TradeTableCurrentRow = TradeTableCurrentRow + 1;
% % %                     end
% % %                     %   Recording Actions
% % %                     Port_Avai_Cap(TradingDayIndex) = Portfolio.AvailableCapital;
% % %                     Port_Value(TradingDayIndex) = Portfolio.Value;
% % %                     Port_Pos_Status(TradingDayIndex) = Portfolio.PositionStatus;
% % %                     Port_Position(TradingDayIndex) = Portfolio.Position;
% % %                     Port_Ent_Px(TradingDayIndex) = Portfolio.EntryPrice;
% % %                     Port_Ent_Dt(TradingDayIndex) = Portfolio.EntryDate;
% % %                 case 1
% % %                     %   Cover Executor (handling Cover Signals) Action 1
% % %                     %%%%
% % %                     %   Not in use for this strategy
% % %                     
% % %                 case -2
% % %                     %   Short Executor (handling Short Signals) Action 1
% % %                     if Portfolio.Position > 0  %   Close First
% % %                         Portfolio = Executor701819606(Portfolio, TradingPX, DataTable.Date, TradingDayIndex, -1); 
% % %                     end
% % %                     %   Action 2
% % %                     if Portfolio.Position == 0%   Go Short
% % %                         try
% % %                             Portfolio = Executor701819606(Portfolio, TradingPX, DataTable.Date, TradingDayIndex, -2, Size);
% % %                         catch
% % %                             Portfolio = Executor701819606(Portfolio, TradingPX, DataTable.Date, TradingDayIndex, -2);
% % %                         end                    
% % %                         %   Write the trade into trade table
% % %                         Tra_Tbl = WriteTradeTable701819606(Portfolio, Tra_Tbl, TradeTableCurrentRow);
% % %                         TradeTableCurrentRow = TradeTableCurrentRow + 1;
% % %                     end
% % %                     %   Recording Actions
% % %                     Port_Avai_Cap(TradingDayIndex) = Portfolio.AvailableCapital;
% % %                     Port_Value(TradingDayIndex) = Portfolio.Value;
% % %                     Port_Pos_Status(TradingDayIndex) = Portfolio.PositionStatus;
% % %                     Port_Position(TradingDayIndex) = Portfolio.Position;
% % %                     Port_Ent_Px(TradingDayIndex) = Portfolio.EntryPrice;
% % %                     Port_Ent_Dt(TradingDayIndex) = Portfolio.EntryDate;
% % %                     
% % %                 case -1
% % %                     %   Close Executor (handling Close Signals) Action 1
% % %                     %%%%
% % %                     %   Not in use for this strategy
% % %                 end
% % %         end
% % %     end
% % %         DataTable.Port_Avai_Cap = Port_Avai_Cap';
% % %         DataTable.Port_Value = Port_Value';
% % %         DataTable.Port_Pos_Status = Port_Pos_Status';
% % %         DataTable.Port_Position = Port_Position';
% % %         DataTable.Port_Ent_Px = Port_Ent_Px';
% % %         DataTable.Port_Ent_Dt = Port_Ent_Dt';
% % % 
% % %         %%  Trading results
% % %         TradeTable.TradeNumber = Tra_Tbl.TradeNumber';
% % %         TradeTable.Position = Tra_Tbl.Position';
% % %         TradeTable.EntryDate = Tra_Tbl.Ent_Date';
% % %         TradeTable.EntryPrice = Tra_Tbl.Ent_Px';
% % %         TradeTable.Size = Tra_Tbl.Size';
% % %         TradeTable.AvailableCapital = Tra_Tbl.Avai_Cap';
% % %     
% % % 
% % % end
% % % 
% % % function [DataTable, TradeTable] = Trading701819606_strategy1(StartingDateIndex, DataTable, InvestmentAmount, Size)
% % % 
% % % %       Bloomberg Startegy Ignore repeat signals in the same direction.
% % % 
% % %     LongSignalCount = sum(DataTable.Signal == 2);
% % %     ShortSignalCount = sum(DataTable.Signal == -2);
% % %     TradeTable = table;
% % %     Tra_Tbl = struct;
% % %     TradeTableCurrentRow = 1;
% % %     if LongSignalCount == 0 && ShortSignalCount == 0 %% In case there is no trade happens
% % %         Portfolio = PortfolioInitialization701819606(InvestmentAmount, StartingDateIndex, DataTable.Date);
% % %         Tra_Tbl = WriteTradeTable701819606(Portfolio, Tra_Tbl, TradeTableCurrentRow);
% % %         Port_Avai_Cap(1:length(DataTable.Date)) = Portfolio.AvailableCapital;
% % %         Port_Value(1:length(DataTable.Date)) = Portfolio.Value;
% % %         Port_Pos_Status(1:length(DataTable.Date)) = Portfolio.PositionStatus;
% % %         Port_Position(1:length(DataTable.Date)) = Portfolio.Position;
% % %         Port_Ent_Px(1:length(DataTable.Date)) = Portfolio.EntryPrice;
% % %         Port_Ent_Dt(1:length(DataTable.Date)) = Portfolio.EntryDate;
% % %     else
% % %         for TradingDayIndex = StartingDateIndex:length(DataTable.Date)
% % %             if TradingDayIndex == StartingDateIndex
% % %                 Portfolio = PortfolioInitialization701819606(InvestmentAmount, TradingDayIndex, DataTable.Date);
% % %             end
% % %             %   Trading at current close
% % %             TradingPX = DataTable.Close(TradingDayIndex);
% % %             CurrentSignal = DataTable.Signal(TradingDayIndex);
% % %             switch CurrentSignal
% % %                 case 0
% % %                     %   Hold Executor
% % %                     Portfolio = Executor701819606(Portfolio, TradingPX, DataTable.Date, TradingDayIndex, 0);
% % % 
% % %                     Port_Avai_Cap(TradingDayIndex) = Portfolio.AvailableCapital;
% % %                     Port_Value(TradingDayIndex) = Portfolio.Value;
% % %                     Port_Pos_Status(TradingDayIndex) = Portfolio.PositionStatus;
% % %                     Port_Position(TradingDayIndex) = Portfolio.Position;
% % %                     Port_Ent_Px(TradingDayIndex) = Portfolio.EntryPrice;
% % %                     Port_Ent_Dt(TradingDayIndex) = Portfolio.EntryDate;
% % % 
% % %                 case 2
% % %                     %   Long Executor(handling Long Signals) Action 1
% % %                     if Portfolio.Position < 0   %   Cover First
% % %                         Portfolio = Executor701819606(Portfolio, TradingPX, DataTable.Date, TradingDayIndex, 1);
% % %                     end
% % %                     %   Action 2
% % %                     if Portfolio.Position == 0  %   Go Long
% % %                         try
% % %                             Portfolio = Executor701819606(Portfolio, TradingPX, DataTable.Date, TradingDayIndex, 2, Size);
% % %                         catch
% % %                             Portfolio = Executor701819606(Portfolio, TradingPX, DataTable.Date, TradingDayIndex, 2);
% % %                         end
% % %                         %   Write the trade into trade table
% % %                         Tra_Tbl = WriteTradeTable701819606(Portfolio, Tra_Tbl, TradeTableCurrentRow);
% % %                         TradeTableCurrentRow = TradeTableCurrentRow + 1;
% % %                     end
% % %                     %   Recording Actions
% % %                     Port_Avai_Cap(TradingDayIndex) = Portfolio.AvailableCapital;
% % %                     Port_Value(TradingDayIndex) = Portfolio.Value;
% % %                     Port_Pos_Status(TradingDayIndex) = Portfolio.PositionStatus;
% % %                     Port_Position(TradingDayIndex) = Portfolio.Position;
% % %                     Port_Ent_Px(TradingDayIndex) = Portfolio.EntryPrice;
% % %                     Port_Ent_Dt(TradingDayIndex) = Portfolio.EntryDate;
% % %                 case 1
% % %                     %   Cover Executor (handling Cover Signals) Action 1
% % %                     %%%%
% % %                     %   Not in use for this strategy
% % %                     
% % %                 case -2
% % %                     %   Short Executor (handling Short Signals) Action 1
% % %                     if Portfolio.Position > 0  %   Close First
% % %                         Portfolio = Executor701819606(Portfolio, TradingPX, DataTable.Date, TradingDayIndex, -1); 
% % %                     end
% % %                     %   Action 2
% % %                     if Portfolio.Position == 0%   Go Short
% % %                         try
% % %                             Portfolio = Executor701819606(Portfolio, TradingPX, DataTable.Date, TradingDayIndex, -2, Size);
% % %                         catch
% % %                             Portfolio = Executor701819606(Portfolio, TradingPX, DataTable.Date, TradingDayIndex, -2);
% % %                         end                    
% % %                         %   Write the trade into trade table
% % %                         Tra_Tbl = WriteTradeTable701819606(Portfolio, Tra_Tbl, TradeTableCurrentRow);
% % %                         TradeTableCurrentRow = TradeTableCurrentRow + 1;
% % %                     end
% % %                     %   Recording Actions
% % %                     Port_Avai_Cap(TradingDayIndex) = Portfolio.AvailableCapital;
% % %                     Port_Value(TradingDayIndex) = Portfolio.Value;
% % %                     Port_Pos_Status(TradingDayIndex) = Portfolio.PositionStatus;
% % %                     Port_Position(TradingDayIndex) = Portfolio.Position;
% % %                     Port_Ent_Px(TradingDayIndex) = Portfolio.EntryPrice;
% % %                     Port_Ent_Dt(TradingDayIndex) = Portfolio.EntryDate;
% % %                     
% % %                 case -1
% % %                     %   Close Executor (handling Close Signals) Action 1
% % %                     %%%%
% % %                     %   Not in use for this strategy
% % %                 end
% % %         end
% % %     end
% % %         DataTable.Port_Avai_Cap = Port_Avai_Cap';
% % %         DataTable.Port_Value = Port_Value';
% % %         DataTable.Port_Pos_Status = Port_Pos_Status';
% % %         DataTable.Port_Position = Port_Position';
% % %         DataTable.Port_Ent_Px = Port_Ent_Px';
% % %         DataTable.Port_Ent_Dt = Port_Ent_Dt';
% % % 
% % %         %%  Trading results
% % %         TradeTable.TradeNumber = Tra_Tbl.TradeNumber';
% % %         TradeTable.Position = Tra_Tbl.Position';
% % %         TradeTable.EntryDate = Tra_Tbl.Ent_Date';
% % %         TradeTable.EntryPrice = Tra_Tbl.Ent_Px';
% % %         TradeTable.Size = Tra_Tbl.Size';
% % %         TradeTable.AvailableCapital = Tra_Tbl.Avai_Cap';
% % %     
% % % 
% % % end
% % % 
% % % function [DataTable, TradeTable] = Trading701819606_strategy2(StartingDateIndex, DataTable, InvestmentAmount, Size)
% % % 
% % % %       Bloomberg Startegy Ignore repeat signals in the same direction.
% % % 
% % %     LongSignalCount = sum(DataTable.Signal == 2);
% % %     ShortSignalCount = sum(DataTable.Signal == -2);
% % %     TradeTable = table;
% % %     Tra_Tbl = struct;
% % %     TradeTableCurrentRow = 1;
% % %     if LongSignalCount == 0 && ShortSignalCount == 0 %% In case there is no trade happens
% % %         Portfolio = PortfolioInitialization701819606(InvestmentAmount, StartingDateIndex, DataTable.Date);
% % %         Tra_Tbl = WriteTradeTable701819606(Portfolio, Tra_Tbl, TradeTableCurrentRow);
% % %         Port_Avai_Cap(1:length(DataTable.Date)) = Portfolio.AvailableCapital;
% % %         Port_Value(1:length(DataTable.Date)) = Portfolio.Value;
% % %         Port_Pos_Status(1:length(DataTable.Date)) = Portfolio.PositionStatus;
% % %         Port_Position(1:length(DataTable.Date)) = Portfolio.Position;
% % %         Port_Ent_Px(1:length(DataTable.Date)) = Portfolio.EntryPrice;
% % %         Port_Ent_Dt(1:length(DataTable.Date)) = Portfolio.EntryDate;
% % %     else
% % %         for TradingDayIndex = StartingDateIndex:length(DataTable.Date)
% % %             if TradingDayIndex == StartingDateIndex
% % %                 Portfolio = PortfolioInitialization701819606(InvestmentAmount, TradingDayIndex, DataTable.Date);
% % %             end
% % %             %   Trading at current close
% % %             TradingPX = DataTable.Close(TradingDayIndex);
% % %             CurrentSignal = DataTable.Signal(TradingDayIndex);
% % %             switch CurrentSignal
% % %                 case 0
% % %                     %   Hold Executor
% % %                     Portfolio = Executor701819606(Portfolio, TradingPX, DataTable.Date, TradingDayIndex, 0);
% % % 
% % %                     Port_Avai_Cap(TradingDayIndex) = Portfolio.AvailableCapital;
% % %                     Port_Value(TradingDayIndex) = Portfolio.Value;
% % %                     Port_Pos_Status(TradingDayIndex) = Portfolio.PositionStatus;
% % %                     Port_Position(TradingDayIndex) = Portfolio.Position;
% % %                     Port_Ent_Px(TradingDayIndex) = Portfolio.EntryPrice;
% % %                     Port_Ent_Dt(TradingDayIndex) = Portfolio.EntryDate;
% % % 
% % %                 case 2
% % %                     %   Long Executor(handling Long Signals) Action 1
% % %                     if Portfolio.Position < 0   %   Cover First
% % %                         Portfolio = Executor701819606(Portfolio, TradingPX, DataTable.Date, TradingDayIndex, 1);
% % %                     end
% % %                     %   Action 2
% % %                     if Portfolio.Position >= 0  %   Go Long
% % %                         try
% % %                             Portfolio = Executor701819606(Portfolio, TradingPX, DataTable.Date, TradingDayIndex, 2, Size);
% % %                         catch
% % %                             Portfolio = Executor701819606(Portfolio, TradingPX, DataTable.Date, TradingDayIndex, 2);
% % %                         end
% % %                         %   Write the trade into trade table
% % %                         Tra_Tbl = WriteTradeTable701819606(Portfolio, Tra_Tbl, TradeTableCurrentRow);
% % %                         TradeTableCurrentRow = TradeTableCurrentRow + 1;
% % %                     end
% % %                     %   Recording Actions
% % %                     Port_Avai_Cap(TradingDayIndex) = Portfolio.AvailableCapital;
% % %                     Port_Value(TradingDayIndex) = Portfolio.Value;
% % %                     Port_Pos_Status(TradingDayIndex) = Portfolio.PositionStatus;
% % %                     Port_Position(TradingDayIndex) = Portfolio.Position;
% % %                     Port_Ent_Px(TradingDayIndex) = Portfolio.EntryPrice;
% % %                     Port_Ent_Dt(TradingDayIndex) = Portfolio.EntryDate;
% % %                 case 1
% % %                     %   Cover Executor (handling Cover Signals) Action 1
% % %                     if Portfolio.Position < 0   %   Cover First
% % %                         Portfolio = Executor701819606(Portfolio, TradingPX, DataTable.Date, TradingDayIndex, 1);
% % % 
% % %                         %   Write the trade into trade table
% % %                         Tra_Tbl = WriteTradeTable701819606(Portfolio, Tra_Tbl, TradeTableCurrentRow);
% % %                         TradeTableCurrentRow = TradeTableCurrentRow + 1;  
% % %                     end
% % % 
% % %                     %   Recording Actions
% % %                     Port_Avai_Cap(TradingDayIndex) = Portfolio.AvailableCapital;
% % %                     Port_Value(TradingDayIndex) = Portfolio.Value;
% % %                     Port_Pos_Status(TradingDayIndex) = Portfolio.PositionStatus;
% % %                     Port_Position(TradingDayIndex) = Portfolio.Position;
% % %                     Port_Ent_Px(TradingDayIndex) = Portfolio.EntryPrice;
% % %                     Port_Ent_Dt(TradingDayIndex) = Portfolio.EntryDate;
% % %                     
% % %                     
% % %                 case -2
% % %                     %   Short Executor (handling Short Signals) Action 1
% % %                     if Portfolio.Position > 0  %   Close First
% % %                         Portfolio = Executor701819606(Portfolio, TradingPX, DataTable.Date, TradingDayIndex, -1); 
% % %                     end
% % %                     %   Action 2
% % %                     if Portfolio.Position <= 0%   Go Short
% % %                         try
% % %                             Portfolio = Executor701819606(Portfolio, TradingPX, DataTable.Date, TradingDayIndex, -2, Size);
% % %                         catch
% % %                             Portfolio = Executor701819606(Portfolio, TradingPX, DataTable.Date, TradingDayIndex, -2);
% % %                         end                    
% % %                         %   Write the trade into trade table
% % %                         Tra_Tbl = WriteTradeTable701819606(Portfolio, Tra_Tbl, TradeTableCurrentRow);
% % %                         TradeTableCurrentRow = TradeTableCurrentRow + 1;
% % %                     end
% % %                     %   Recording Actions
% % %                     Port_Avai_Cap(TradingDayIndex) = Portfolio.AvailableCapital;
% % %                     Port_Value(TradingDayIndex) = Portfolio.Value;
% % %                     Port_Pos_Status(TradingDayIndex) = Portfolio.PositionStatus;
% % %                     Port_Position(TradingDayIndex) = Portfolio.Position;
% % %                     Port_Ent_Px(TradingDayIndex) = Portfolio.EntryPrice;
% % %                     Port_Ent_Dt(TradingDayIndex) = Portfolio.EntryDate;
% % %                     
% % %                 case -1
% % %                     %   Close Executor (handling Close Signals) Action 1
% % %                     if Portfolio.Position > 0  %   Close First
% % %                         Portfolio = Executor701819606(Portfolio, TradingPX, DataTable.Date, TradingDayIndex, -1); 
% % % 
% % %                         %   Write the trade into trade table
% % %                         Tra_Tbl = WriteTradeTable701819606(Portfolio, Tra_Tbl, TradeTableCurrentRow);
% % %                         TradeTableCurrentRow = TradeTableCurrentRow + 1;  
% % %                     end
% % %                     %   Recording Actions
% % %                     Port_Avai_Cap(TradingDayIndex) = Portfolio.AvailableCapital;
% % %                     Port_Value(TradingDayIndex) = Portfolio.Value;
% % %                     Port_Pos_Status(TradingDayIndex) = Portfolio.PositionStatus;
% % %                     Port_Position(TradingDayIndex) = Portfolio.Position;
% % %                     Port_Ent_Px(TradingDayIndex) = Portfolio.EntryPrice;
% % %                     Port_Ent_Dt(TradingDayIndex) = Portfolio.EntryDate;
% % %                     
% % %                 end
% % %         end
% % %     end
% % %         DataTable.Port_Avai_Cap = Port_Avai_Cap';
% % %         DataTable.Port_Value = Port_Value';
% % %         DataTable.Port_Pos_Status = Port_Pos_Status';
% % %         DataTable.Port_Position = Port_Position';
% % %         DataTable.Port_Ent_Px = Port_Ent_Px';
% % %         DataTable.Port_Ent_Dt = Port_Ent_Dt';
% % % 
% % %         %%  Trading results
% % %         TradeTable.TradeNumber = Tra_Tbl.TradeNumber';
% % %         TradeTable.Position = Tra_Tbl.Position';
% % %         TradeTable.EntryDate = Tra_Tbl.Ent_Date';
% % %         TradeTable.EntryPrice = Tra_Tbl.Ent_Px';
% % %         TradeTable.Size = Tra_Tbl.Size';
% % %         TradeTable.AvailableCapital = Tra_Tbl.Avai_Cap';
% % %     
% % % 
% % % end
% % % 
% % % function portfolio = Executor701819606(Portfolio, DayClose, Date, TradingDayIndex, Action, Size)
% % % %   List of Action: Action == 2, Long Action == 1, Cover Action == 0, Hold
% % % %   Action == -1, Close Action == -2, Short
% % %     try
% % %         Size;
% % %     catch
% % %         Size = abs(fix(Portfolio.AvailableCapital / DayClose));
% % %     end
% % %     if Action == 2 && Portfolio.Position > 0 && Portfolio.AvailableCapital < abs(Size * DayClose)
% % %         Action = 0;
% % %     elseif Action == -2 && Portfolio.Position < 0 && (Portfolio.AvailableCapital - 2 * Portfolio.InitialInvestment) < abs(Size * DayClose)
% % %         Action = 0;
% % %     end
% % %     
% % %     switch Action 
% % %         case 2  %   Long
% % %           
% % %         Value = Size * DayClose;
% % %         AvailableCapital = Portfolio.AvailableCapital - Value;
% % %         Position = Portfolio.Position + Size;
% % %         PositionStatus = 1;
% % %         EntryPrice = DayClose;
% % %         EntryDate = Date(TradingDayIndex);
% % %         Balance = abs(Portfolio.Balance - abs(Value));
% % %         
% % %         case 1  %   Cover
% % %         Size = abs(Portfolio.Position);
% % %         Value = Size * DayClose;
% % %         AvailableCapital = Portfolio.AvailableCapital - Value;
% % %         Position = Portfolio.Position + Size;
% % %         PositionStatus = 0;
% % %         EntryPrice = DayClose;
% % %         EntryDate = Date(TradingDayIndex);
% % %         Balance = abs(Portfolio.Balance + abs(Value));
% % %         
% % %         case 0  %   Hold
% % %         Size = Portfolio.Size;
% % %         Value = Portfolio.Size * DayClose;
% % %         AvailableCapital = Portfolio.AvailableCapital;
% % %         Position = Portfolio.Position;
% % %         PositionStatus = Portfolio.PositionStatus;
% % %         EntryPrice = Portfolio.EntryPrice;        
% % %         EntryDate = Portfolio.EntryDate;
% % %         Balance = Portfolio.Balance;
% % %         
% % %         case -1 %   Close
% % %         Size = abs(Portfolio.Position);
% % %         Value = Size * DayClose;
% % %         AvailableCapital = Portfolio.AvailableCapital + Value;
% % %         Position = Portfolio.Position - Size;
% % %         PositionStatus = 0;
% % %         EntryPrice = DayClose;
% % %         EntryDate = Date(TradingDayIndex);
% % %         Balance = abs(Portfolio.Balance + abs(Value));
% % %         
% % %         case -2 %   Short
% % %         Value = Size * DayClose;
% % %         AvailableCapital = Portfolio.AvailableCapital + Value;
% % %         Position = Portfolio.Position - Size;
% % %         PositionStatus = -1;
% % %         EntryPrice = DayClose;
% % %         EntryDate = Date(TradingDayIndex);
% % %         Balance = abs(Portfolio.Balance - abs(Value));
% % %     end
% % %     
% % %     portfolio.Size = Size;
% % %     portfolio.AvailableCapital = AvailableCapital;
% % %     portfolio.Value = Value;
% % %     portfolio.Position = Position;
% % %     portfolio.PositionStatus = PositionStatus;
% % %     portfolio.EntryPrice = EntryPrice;
% % %     portfolio.EntryDate = EntryDate;
% % %     portfolio.Balance = Balance;
% % %     portfolio.InitialInvestment = Portfolio.InitialInvestment;
% % % end
% % % 
% % % function portfolio = PortfolioInitialization701819606(InvestmentAmount, TradingDayIndex, Date)
% % %     portfolio.AvailableCapital = InvestmentAmount;
% % %     portfolio.Value = 0;
% % %     portfolio.Position = 0;
% % %     portfolio.PositionStatus = nan;
% % %     portfolio.EntryPrice = 0;
% % %     portfolio.EntryDate = Date(TradingDayIndex);
% % %     portfolio.Size = 0;
% % %     portfolio.InitialInvestment = InvestmentAmount;
% % %     portfolio.Balance = InvestmentAmount;
% % % end
% % % 
% % % function TradeTable = WriteTradeTable701819606(Portfolio, TradeTable, TradeTableCurrentRow)
% % % 
% % % 
% % %     TradeTable.TradeNumber(TradeTableCurrentRow) = TradeTableCurrentRow;
% % %     TradeTable.Position(TradeTableCurrentRow) = Portfolio.PositionStatus;
% % %     TradeTable.Ent_Date(TradeTableCurrentRow) = Portfolio.EntryDate;
% % %     TradeTable.Ent_Px(TradeTableCurrentRow) = Portfolio.EntryPrice;
% % %     TradeTable.Size(TradeTableCurrentRow) = Portfolio.Size;
% % %     TradeTable.Avai_Cap(TradeTableCurrentRow) = Portfolio.AvailableCapital;
% % %     
% % %     
% % % end
% % % 
% % % function Stat_Trading = Statistics701819606(TradeTable, DataTable, InvestmentAmount, StartingDateIndex, RiskFreeRate)
% % %     %   Trading Summary
% % %     StatTable = TradeTable;
% % %     for i = 1:length(StatTable.TradeNumber)
% % %         StatTable_EntryDateIndex(i) = find(DataTable.Date == StatTable.EntryDate(i));
% % %         StatTable_ExitDateIndex(i) = find(DataTable.Date == StatTable.ExitDate(i));  
% % %     end
% % %     StatTable.EntryDateIndex = StatTable_EntryDateIndex';
% % %     StatTable.ExitDateIndex = StatTable_ExitDateIndex';
% % %     StatTable.Duration = StatTable.ExitDateIndex - StatTable.EntryDateIndex;
% % % 
% % %     Stat_LongRowIndex = StatTable.Position == 1;
% % %     Stat_ShortRowIndex = StatTable.Position == -1;
% % %     StatTable_Long_tbl = StatTable(Stat_LongRowIndex,StatTable.Properties.VariableNames);
% % %     StatTable_Short_tbl = StatTable(Stat_ShortRowIndex,StatTable.Properties.VariableNames);
% % % 
% % %     Stat_Trading = struct;
% % % 
% % %     Stat_Trading.LongTrades = length(StatTable_Long_tbl.TradeNumber);
% % %     Stat_Trading.LongWins = length(find(StatTable_Long_tbl.ProfitandLoss > 0));
% % %     Stat_Trading.LongLosses = length(find(StatTable_Long_tbl.ProfitandLoss <=0));
% % %     Stat_Trading.LongTotal = Stat_Trading.LongWins + Stat_Trading.LongLosses;
% % %     Stat_Trading.LongPnL = sum(StatTable_Long_tbl.ProfitandLoss);
% % %     Stat_Trading.LongPnLpctg = Stat_Trading.LongPnL/InvestmentAmount * 100;
% % % 
% % %     Stat_Trading.ShortTrades = length(StatTable_Short_tbl.TradeNumber);
% % %     Stat_Trading.ShortWins = length(find(StatTable_Short_tbl.ProfitandLoss > 0));
% % %     Stat_Trading.ShortLosses = length(find(StatTable_Short_tbl.ProfitandLoss <=0));
% % %     Stat_Trading.ShortTotal = Stat_Trading.ShortWins + Stat_Trading.ShortLosses;
% % %     Stat_Trading.ShortPnL = sum(StatTable_Short_tbl.ProfitandLoss);
% % %     Stat_Trading.ShortPnLpctg = Stat_Trading.ShortPnL/InvestmentAmount * 100;
% % % 
% % %     Stat_Trading.TotalTrades = Stat_Trading.LongTrades + Stat_Trading.ShortTrades;
% % %     Stat_Trading.TotalWins = length(find(StatTable.ProfitandLoss > 0));
% % %     Stat_Trading.TotalLosses = length(find(StatTable.ProfitandLoss <=0));
% % %     Stat_Trading.TotalTotal = Stat_Trading.TotalWins + Stat_Trading.TotalLosses;
% % %     Stat_Trading.TotalPnL = sum(StatTable.ProfitandLoss);
% % %     Stat_Trading.TotalPnLpctg = Stat_Trading.TotalPnL/InvestmentAmount * 100;
% % % 
% % %     %   Additional Statistics For Long Positions
% % %     Stat_Trading.LongAveragePnL = Stat_Trading.LongPnL / Stat_Trading.LongTrades;
% % %     Stat_Trading.LongTotalWins = sum(StatTable_Long_tbl.ProfitandLoss(StatTable_Long_tbl.ProfitandLoss > 0));
% % %     Stat_Trading.LongTotalLosses = abs(sum(StatTable_Long_tbl.ProfitandLoss(StatTable_Long_tbl.ProfitandLoss <= 0)));
% % %     Stat_Trading.LongAverageWins = mean(StatTable_Long_tbl.ProfitandLoss(StatTable_Long_tbl.ProfitandLoss > 0));
% % %     Stat_Trading.LongAverageLosses = abs(mean(StatTable_Long_tbl.ProfitandLoss(StatTable_Long_tbl.ProfitandLoss <= 0)));
% % %     Stat_Trading.LongMaxWin = StatTable_Long_tbl.ProfitandLoss(StatTable_Long_tbl.ProfitandLoss == max(StatTable_Long_tbl.ProfitandLoss));
% % %     Stat_Trading.LongMaxLoss = StatTable_Long_tbl.ProfitandLoss(StatTable_Long_tbl.ProfitandLoss == min(StatTable_Long_tbl.ProfitandLoss));
% % %     
% % %     
% % %     if isempty(Stat_Trading.LongMaxWin) || Stat_Trading.LongMaxWin < 0  
% % %         Stat_Trading.LongMaxWin = 0;
% % %     end
% % %     if isempty(Stat_Trading.LongMaxLoss) || Stat_Trading.LongMaxLoss > 0
% % %         Stat_Trading.LongMaxLoss = 0;
% % %     else
% % %         Stat_Trading.LongMaxLoss = abs(Stat_Trading.LongMaxLoss);
% % %     end
% % %     Stat_Trading.LongDuration = sum(StatTable_Long_tbl.Duration);
% % % 
% % %     %   For Short Positions
% % %     Stat_Trading.ShortAveragePnL = Stat_Trading.ShortPnL / Stat_Trading.ShortTrades;
% % %     Stat_Trading.ShortTotalWins = sum(StatTable_Short_tbl.ProfitandLoss(StatTable_Short_tbl.ProfitandLoss > 0));
% % %     Stat_Trading.ShortTotalLosses = abs(sum(StatTable_Short_tbl.ProfitandLoss(StatTable_Short_tbl.ProfitandLoss <= 0)));
% % %     Stat_Trading.ShortAverageWins = mean(StatTable_Short_tbl.ProfitandLoss(StatTable_Short_tbl.ProfitandLoss > 0));
% % %     Stat_Trading.ShortAverageLosses = abs(mean(StatTable_Short_tbl.ProfitandLoss(StatTable_Short_tbl.ProfitandLoss <= 0)));
% % %     Stat_Trading.ShortMaxWin = StatTable_Short_tbl.ProfitandLoss(StatTable_Short_tbl.ProfitandLoss == max(StatTable_Short_tbl.ProfitandLoss));
% % %     Stat_Trading.ShortMaxLoss = StatTable_Short_tbl.ProfitandLoss(StatTable_Short_tbl.ProfitandLoss == min(StatTable_Short_tbl.ProfitandLoss));
% % %     
% % %     if length(Stat_Trading.ShortMaxLoss) > 1;
% % %         Stat_Trading.ShortMaxLoss = Stat_Trading.ShortMaxLoss(1);
% % %     end
% % %     if length(Stat_Trading.ShortMaxWin) > 1;
% % %         Stat_Trading.ShortMaxWin = Stat_Trading.ShortMaxWin(1);
% % %     end
% % %     if isempty(Stat_Trading.ShortMaxWin) || Stat_Trading.ShortMaxWin < 0  
% % %         Stat_Trading.ShortMaxWin = 0;
% % %     end
% % %     if isempty(Stat_Trading.ShortMaxLoss) || Stat_Trading.ShortMaxLoss > 0
% % %         Stat_Trading.ShortMaxLoss = 0;
% % %     else
% % %         Stat_Trading.ShortMaxLoss = abs(Stat_Trading.ShortMaxLoss);
% % %     end
% % %     Stat_Trading.ShortDuration = sum(StatTable_Short_tbl.Duration);
% % % 
% % %     %   For Totals
% % %     Stat_Trading.TotalAveragePnL = Stat_Trading.TotalPnL / Stat_Trading.TotalTrades;
% % %     Stat_Trading.TotalTotalWins = Stat_Trading.LongTotalWins + Stat_Trading.ShortTotalWins;
% % %     Stat_Trading.TotalTotalLosses = Stat_Trading.LongTotalLosses + Stat_Trading.ShortTotalLosses;
% % %     Stat_Trading.TotalAverageWins = Stat_Trading.TotalTotalWins / Stat_Trading.TotalWins;
% % %     Stat_Trading.TotalAverageLosses = Stat_Trading.TotalTotalLosses / Stat_Trading.TotalLosses;
% % %     Stat_Trading.TotalMaxWin = max(Stat_Trading.LongMaxWin, Stat_Trading.ShortMaxWin);
% % %     Stat_Trading.TotalMaxLoss = max(Stat_Trading.LongMaxLoss, Stat_Trading.ShortMaxLoss);
% % %     Stat_Trading.TotalDuration = Stat_Trading.LongDuration + Stat_Trading.ShortDuration;
% % % 
% % %     Stat_Port_Value = DataTable.Port_Value(StartingDateIndex:end) .* DataTable.Port_Pos_Status(StartingDateIndex:end) + DataTable.Port_Avai_Cap(StartingDateIndex:end);
% % %     Stat_Port_Return = Stat_Port_Value ./ InvestmentAmount - 1;
% % %     % % % % % % % % % % % % % % % % % % % % % % % KInput: RiskFreeRate
% % %     try 
% % %         RiskFreeRate;
% % %     catch
% % %         RiskFreeRate = 0.0136;
% % %     end
% % % 
% % %     Stat_Trading.AverageDuration = Stat_Trading.TotalDuration / Stat_Trading.TotalTrades;
% % %     Stat_Trading.SharpeRatio = (mean(Stat_Port_Return) - RiskFreeRate) / std(Stat_Port_Return, 1);
% % %     Stat_Trading.SortinoRatio = (mean(Stat_Port_Return) - RiskFreeRate) / std(Stat_Port_Return(Stat_Port_Return < 0), 1);
% % %     Stat_Trading.TotalReturn = Stat_Trading.TotalPnLpctg;  
% % % 
% % %     Stat_Trading.Mx_Return_Pctg = max(Stat_Port_Return) * 100;
% % %     Stat_Trading.Mn_Return_Pctg = min(Stat_Port_Return) * 100;
% % % 
% % %     %   MaxDrawDown
% % %     [Stat_Port_H, Stat_Port_HIndex, Stat_Port_L, Stat_Port_LIndex, ~, ~] = TradeMaxDD701819606(Stat_Port_Value, 1);
% % %     Stat_Trading.MaxDD = (Stat_Port_H - Stat_Port_L) / Stat_Port_H * 100;
% % %     Stat_Trading.MaxDDLength = Stat_Port_LIndex - Stat_Port_HIndex;
% % %     
% % % end
% % % 
% % % function [Op_PeakPX, Op_PeakIndex, Op_BottomPX, Op_BottomIndex, Op_RecovPX, Op_RecovIndex] = TradeMaxDD701819606(Price, PositionStatus)
% % % %   Input: Price:  a series of price PositionStatus: 1 for long position,
% % % %   -1 for short position
% % % 
% % %     temp_PeakPX = Price(1);
% % %     PeakIndex = 1;
% % %     temp_BottomPX = Price(1);
% % %     BottomIndex = 1;
% % %     Op_RecovPX = [];
% % %     Op_RecovIndex = nan;
% % %     PX_DD = -99999;
% % %     switch PositionStatus
% % %         case 1 %    Long Position
% % %             for i = 2:length(Price)
% % %                 temp_CurrentPX = Price(i);
% % %                 if Price(i) > temp_PeakPX
% % %                     temp_PeakPX = Price(i);
% % %                     temp_BottomPX = Price(i);
% % %                     PeakIndex = i;
% % %                     BottomIndex = i;
% % %                 elseif Price(i) <= temp_BottomPX
% % %                     temp_BottomPX = Price(i);
% % %                     BottomIndex = i;
% % %                 end
% % % 
% % %                 temp_DD = abs((temp_PeakPX - temp_BottomPX)/temp_PeakPX);
% % %                 if temp_DD > PX_DD
% % %                     PX_DD = temp_DD;
% % %                     Op_PeakIndex = PeakIndex;
% % %                     Op_BottomIndex = BottomIndex;
% % %                     Op_PeakPX = temp_PeakPX;
% % %                     Op_BottomPX = temp_BottomPX;
% % %                     Op_RecovPX = [];
% % %                     Op_RecovIndex = nan;
% % %                 end
% % % 
% % %                 try
% % %                     Op_BottomIndex;
% % %                 catch
% % %                     Op_BottomIndex = 0;
% % %                 end
% % %                 try
% % %                     Op_PeakPX;
% % %                 catch
% % %                     Op_PeakPX = 0;
% % %                 end
% % % 
% % %                 if i > Op_BottomIndex && Price(i) >= Op_PeakPX && isnan(Op_RecovIndex)
% % %                     Op_RecovPX = Price(i);
% % %                     Op_RecovIndex = i;
% % %                 end
% % %             end
% % %         case -1 %   Short Position
% % %             for i = 2:length(Price)
% % %                 temp_CurrentPX = Price(i);
% % %                 if Price(i) < temp_PeakPX
% % %                     temp_PeakPX = Price(i);
% % %                     temp_BottomPX = Price(i);
% % %                     PeakIndex = i;
% % %                     BottomIndex = i;
% % %                 elseif Price(i) >= temp_BottomPX
% % %                     temp_BottomPX = Price(i);
% % %                     BottomIndex = i;
% % %                 end
% % % 
% % %                 temp_DD = abs((temp_PeakPX - temp_BottomPX)/temp_PeakPX);
% % %                 if temp_DD > PX_DD
% % %                     PX_DD = temp_DD;
% % %                     Op_PeakIndex = PeakIndex;
% % %                     Op_BottomIndex = BottomIndex;
% % %                     Op_PeakPX = temp_PeakPX;
% % %                     Op_BottomPX = temp_BottomPX;
% % %                     Op_RecovPX = [];
% % %                     Op_RecovIndex = nan;
% % %                 end
% % % 
% % %                 try
% % %                     Op_BottomIndex;
% % %                 catch
% % %                     Op_BottomIndex = 0;
% % %                 end
% % %                 try
% % %                     Op_PeakPX;
% % %                 catch
% % %                     Op_PeakPX = 0;
% % %                 end
% % % 
% % %                 if i > Op_BottomIndex && Price(i) <= Op_PeakPX && isnan(Op_RecovIndex) 
% % %                     Op_RecovPX = Price(i);
% % %                     Op_RecovIndex = i;
% % %                 end        
% % %             end
% % %     end
% % %    
% % %         
% % %     try
% % %         Op_PeakIndex;
% % %         Op_BottomIndex;
% % %         Op_PeakPX;
% % %         Op_BottomPX;
% % %     catch
% % %         try
% % %              i;
% % %         catch
% % %             i = 1;
% % %         end
% % %         if isempty(i)
% % %             i = 1;
% % %         end
% % %         Op_PeakIndex = i;
% % %         Op_BottomIndex = i;
% % %         Op_PeakPX = Price(i);
% % %         Op_BottomPX = Price(i);
% % %     end
% % % end
% % % 
% % % function [Op_PeakPX, Op_PeakIndex, Op_BottomPX, Op_BottomIndex] = MaxIncrease701819606(Price, PositionStatus)
% % % %   Input: Price:  a series of price PositionStatus: 1 for long position,
% % % %   -1 for short position
% % % 
% % %     temp_PeakPX = Price(1);
% % %     PeakIndex = 1;
% % %     temp_BottomPX = Price(1);
% % %     BottomIndex = 1;
% % %     PX_Increase = -99999;
% % % 
% % %     switch PositionStatus
% % %         case 1 %    Long Position
% % %             for i = 2:length(Price)
% % %                 temp_CurrentPX = Price(i);
% % %                 if Price(i) < temp_BottomPX
% % %                     temp_PeakPX = Price(i);
% % %                     temp_BottomPX = Price(i);
% % %                     PeakIndex = i;
% % %                     BottomIndex = i;
% % %                 elseif Price(i) >= temp_PeakPX
% % %                     temp_PeakPX = Price(i);
% % %                     PeakIndex = i;
% % %                 end
% % %                 
% % %                 temp_Increase = abs((temp_PeakPX - temp_BottomPX)/temp_BottomPX);
% % %                 if temp_Increase > PX_Increase
% % %                     PX_Increase = temp_Increase;
% % %                     Op_PeakIndex = PeakIndex;
% % %                     Op_BottomIndex = BottomIndex;
% % %                     Op_PeakPX = temp_PeakPX;
% % %                     Op_BottomPX = temp_BottomPX;
% % %                 end
% % %             end
% % %             
% % %         case -1 %   Short Position
% % %             for i = 2:length(Price)
% % %                 temp_CurrentPX = Price(i);
% % %                 if Price(i) > temp_PeakPX
% % %                     temp_PeakPX = Price(i);
% % %                     temp_BottomPX = Price(i);
% % %                     PeakIndex = i;
% % %                     BottomIndex = i;
% % %                 elseif Price(i) <= temp_BottomPX
% % %                     temp_BottomPX = Price(i);
% % %                     BottomIndex = i;
% % %                 end
% % %                 
% % %                 temp_Increase = abs((temp_PeakPX - temp_BottomPX)/temp_PeakPX);
% % %                 if temp_Increase > PX_Increase
% % %                     PX_Increase = temp_Increase;
% % %                     Op_PeakIndex = PeakIndex;
% % %                     Op_BottomIndex = BottomIndex;
% % %                     Op_PeakPX = temp_PeakPX;
% % %                     Op_BottomPX = temp_BottomPX;
% % %                 end  
% % %             end
% % %     end
% % % 
% % %         
% % %     try
% % %         Op_PeakIndex;
% % %         Op_BottomIndex;
% % %         Op_PeakPX;
% % %         Op_BottomPX;
% % %     catch
% % %         try
% % %             i;
% % %         catch
% % %             i = 1;
% % %         end
% % %         if isempty(i)
% % %             i = 1;
% % %         end
% % %         Op_PeakIndex = i;
% % %         Op_BottomIndex = i;
% % %         Op_PeakPX = Price(i);
% % %         Op_BottomPX = Price(i);
% % %     end
% % % end
