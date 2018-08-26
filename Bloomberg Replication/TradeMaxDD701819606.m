function [Op_PeakPX, Op_PeakIndex, Op_BottomPX, Op_BottomIndex, Op_RecovPX, Op_RecovIndex] = TradeMaxDD701819606(Price, PositionStatus)
%   Input:
%   Price:  a series of price
%   PositionStatus: 1 for long position, -1 for short position

    temp_PeakPX = Price(1);
    PeakIndex = 1;
    temp_BottomPX = Price(1);
    BottomIndex = 1;
    Op_RecovPX = [];
    Op_RecovIndex = nan;
    PX_DD = -99999;
    switch PositionStatus
        case 1 %    Long Position
            for i = 2:length(Price)
                temp_CurrentPX = Price(i);
                if Price(i) > temp_PeakPX
                    temp_PeakPX = Price(i);
                    temp_BottomPX = Price(i);
                    PeakIndex = i;
                    BottomIndex = i;
                elseif Price(i) <= temp_BottomPX
                    temp_BottomPX = Price(i);
                    BottomIndex = i;
                end

                temp_DD = abs((temp_PeakPX - temp_BottomPX)/temp_PeakPX);
                if temp_DD > PX_DD
                    PX_DD = temp_DD;
                    Op_PeakIndex = PeakIndex;
                    Op_BottomIndex = BottomIndex;
                    Op_PeakPX = temp_PeakPX;
                    Op_BottomPX = temp_BottomPX;
                    Op_RecovPX = [];
                    Op_RecovIndex = nan;
                end

                try
                    Op_BottomIndex;
                catch
                    Op_BottomIndex = 0;
                end
                try
                    Op_PeakPX;
                catch
                    Op_PeakPX = 0;
                end

                if i > Op_BottomIndex && Price(i) >= Op_PeakPX && isnan(Op_RecovIndex)
                    Op_RecovPX = Price(i);
                    Op_RecovIndex = i;
                end
            end
        case -1 %   Short Position
            for i = 2:length(Price)
                temp_CurrentPX = Price(i);
                if Price(i) < temp_PeakPX
                    temp_PeakPX = Price(i);
                    temp_BottomPX = Price(i);
                    PeakIndex = i;
                    BottomIndex = i;
                elseif Price(i) >= temp_BottomPX
                    temp_BottomPX = Price(i);
                    BottomIndex = i;
                end

                temp_DD = abs((temp_PeakPX - temp_BottomPX)/temp_PeakPX);
                if temp_DD > PX_DD
                    PX_DD = temp_DD;
                    Op_PeakIndex = PeakIndex;
                    Op_BottomIndex = BottomIndex;
                    Op_PeakPX = temp_PeakPX;
                    Op_BottomPX = temp_BottomPX;
                    Op_RecovPX = [];
                    Op_RecovIndex = nan;
                end

                try
                    Op_BottomIndex;
                catch
                    Op_BottomIndex = 0;
                end
                try
                    Op_PeakPX;
                catch
                    Op_PeakPX = 0;
                end

                if i > Op_BottomIndex && Price(i) <= Op_PeakPX && isnan(Op_RecovIndex) 
                    Op_RecovPX = Price(i);
                    Op_RecovIndex = i;
                end        
            end
    end
   
        
    try
        Op_PeakIndex;
        Op_BottomIndex;
        Op_PeakPX;
        Op_BottomPX;
    catch
        try
             i;
        catch
            i = 1;
        end
        if isempty(i)
            i = 1;
        end
        Op_PeakIndex = i;
        Op_BottomIndex = i;
        Op_PeakPX = Price(i);
        Op_BottomPX = Price(i);
    end
end


        

    