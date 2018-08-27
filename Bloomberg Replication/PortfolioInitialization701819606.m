function portfolio = PortfolioInitialization701819606(InvestmentAmount, TradingDayIndex, Date)
    portfolio.AvailableCapital = InvestmentAmount;
    portfolio.Value = 0;
    portfolio.Position = 0;
    portfolio.PositionStatus = nan;
    portfolio.EntryPrice = 0;
    portfolio.EntryDate = Date(TradingDayIndex);
    portfolio.Size = 0;
    portfolio.InitialInvestment = InvestmentAmount;
    portfolio.Balance = InvestmentAmount;
end
