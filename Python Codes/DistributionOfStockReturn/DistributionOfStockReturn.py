#   Question: Is stock return normal distributed?
#   Conclusion: Yes, stock returns are normally distributed.
#   Date:   9/16/2018
#   Author: Kin Z

import requests
from bs4 import BeautifulSoup as soup
import csv
import pandas as pd
import pandas_datareader as pdr
from datetime import datetime
import os
import matplotlib.pyplot as plt
import seaborn as sns
import numpy as np
import random


def make_soup(dest_url):
    result = requests.get(dest_url)
    WebsiteHTML = result.content
    pageSoup = soup(WebsiteHTML, 'html.parser')
    result.connection.close()
    return pageSoup

def obtain_company_list():
    #   Sources: Wikipedia S&P500 company list
    dest_url = 'https://en.wikipedia.org/wiki/List_of_S%26P_500_companies'
    pageSoup = make_soup(dest_url)
    #   Obtain table head
    tableHead_li = []
    tableHead_soup = pageSoup.find('table', {'class':'wikitable sortable'}).find_all('th')
    for i in range(len(tableHead_soup)):
        appendingStr = tableHead_soup[i].text
        appendingStr = appendingStr.split('[')[0].split('\n')[0]
        tableHead_li.append(appendingStr)
    
    result_df = pd.DataFrame(columns = tableHead_li)
    #   Obtain table content
    tableRow_soup = pageSoup.find('table', {'class':'wikitable sortable'}).find_all('tr')
    for i in range(1, len(tableRow_soup)):
        tableRow_li = []
        singleRow_soup = tableRow_soup[i].find_all('td')
        for j in range(len(singleRow_soup)):
            appendingTableRow_str = singleRow_soup[j].text.split('\n')[0]
            print(appendingTableRow_str)
            tableRow_li.append(appendingTableRow_str)
        singleRow_df = pd.DataFrame([tableRow_li], columns = tableHead_li)
        result_df = result_df.append(singleRow_df)
    return result_df    

def obtain_closing_price(ticker, startingDate, endingDate, wantedColumns):
    #   ticker:         (single)String
    #   startingDate:   datetime
    #   endingDate:     datetime
    #   wantedColumns:  one or more from ['High', 'Low', 'Open', 'Close', 'Volume', 'Adj Close']

    stock_df = pdr.get_data_yahoo(symbols = ticker, start = startingDate, end = endingDate)
    output_df = stock_df[wantedColumns]
    output_df.name = ticker
    return output_df

def subsetting_company(companyList, stockReturn_df, columnFilter, columnValue):
    #   companyList_df: DataFrame from Wikipedia
    #   stockReturn_df: DataFrame containing stock return data
    #   columnFilter:   filter according to which column
    #   columnValue:    what value wanted from the specific column
    neededTickerList = companyList[companyList[columnFilter] == columnValue]['Ticker symbol'].tolist()
    validTickerList = []
    for ticker in neededTickerList:
        if ticker in stockReturn_df.columns:
            validTickerList.append(ticker)
    
    output_df = stockReturn_df[validTickerList]
    return output_df   

if __name__ == '__main__':
    os.chdir(r'D:\Python Exercise\DistributionOfStockReturn')
    try:
        companyList = pd.read_csv('companyList.csv', index_col = 0)     
    except: #   reading the list takes some time.
        companyList = obtain_company_list()
        companyList.to_csv('companyList.csv', encoding = 'utf-8')

    tickerList = companyList['Ticker symbol'].tolist()
    startingDate = datetime(2015, 12, 31) # Last trading day in 2015
    endingDate = datetime(2017, 12, 31)
    wantedColumns = 'Adj Close'
    #   Getting Closing Price
    try:
        closingPrice_df = pd.read_csv('closingPrice.csv', index_col = 0) 
    except:
        firstTimeIndicator = 1
        counter = 1
        for ticker in tickerList:
            try:
                stockClosingPrice_df = obtain_closing_price(ticker, startingDate, endingDate, wantedColumns)
                if firstTimeIndicator == 1:
                    firstTimeIndicator = 0
                    closingPrice_df = stockClosingPrice_df
                else:
                    closingPrice_df = pd.concat([closingPrice_df, stockClosingPrice_df], axis = 1)
                print(counter)
                counter += 1
            except:
                #   For some reasons, certain ticker doesn't have enough data.
                #   However, 99% of tickers get no missing data.
                print('Insufficient length of stock data in required period. Ticker: ' + ticker + '.')
             

        closingPrice_df.to_csv('closingPrice.csv', encoding = 'utf-8')  #   Save data to csv

    #   Getting Return
    closingPriceDiff_df = closingPrice_df.diff()
    closingPriceDiff_df = closingPriceDiff_df.iloc[1:]
    closingPrice_df = closingPrice_df.iloc[1:]
    stockReturn_df = closingPriceDiff_df.div(closingPrice_df)   #   Stock Return in decimal
    stockReturn_df = stockReturn_df.fillna(0)
    stockReturnPct_df = stockReturn_df.mul(100) #   Stock Return in Percentage
    stockReturnPct_df = stockReturnPct_df.fillna(0)

    #   Plotting
    #   Plotting one day return
    plottingArray = np.array(stockReturnPct_df.iloc[-1].tolist())
    plot1 = sns.distplot(plottingArray, rug = 1, kde = 1)
    plot1.set(xlabel = 'Stork Returns(%)', ylabel = 'Frequency', title = 'One-day Stock Returns Distribution')
    plt.savefig('plot_1.png')
    plt.clf()

    '''
    Comment: 
    From the plot (plot 1), stock returns are normally distributed.
    The overall distribution is skewed left, because the tail on the left side is much longer than the other side.
    '''

    #   Randomly select days to plot
    plotAmount = 50
    dayList = []
    while len(dayList) <= plotAmount:
        dayIndex = random.randint(0, len(stockReturnPct_df))
        if dayIndex not in dayList:
            dayList.append(dayIndex)
        

    for i in dayList:
        plottingArray = np.array(stockReturnPct_df.iloc[i].tolist())
        plot2 = sns.distplot(plottingArray, hist = 0)
    
    plot2.set(xlabel = 'Stork Returns (%)', ylabel = 'Frequency', title = '50-day Stock Returns Distribution')   
    plt.savefig('plot_2.png')
    plt.clf()

    #   Trying to shift each series, so that their means are closer to each other for easier conclusion
    for i in dayList:
        plottingArray = np.array(stockReturnPct_df.iloc[i].tolist())
        plottingArray = np.mean(plottingArray) - plottingArray
        plot3 = sns.distplot(plottingArray, hist = 0)

    plot3.set(xlabel = 'Stork Returns (%)', ylabel = 'Frequency', title = '50-day Stock Returns Distribution (shifted mean to 0)')         
    plt.savefig('plot_3.png')
    plt.clf()

    '''
    Comment:
    From the above two plot, stock returns are still normally distributed.
    The overall distribution is becoming symmetric because both tails are having equal length.
    '''
    
    #   Look at stock returns distributions by sectors (one-day)
    sectorList = list(set(companyList['GICS Sector'].tolist()))
    columnFilter = 'GICS Sector'
    for sector in sectorList:
        sector_df = subsetting_company(companyList, stockReturnPct_df, columnFilter, sector)
        sectorPlottingArray = np.array(sector_df.iloc[-1].tolist())
        sectorPlot = sns.distplot(sectorPlottingArray, rug = 1, kde = 1)
        sectorPlot.set(xlabel = 'Stork Returns(%)', ylabel = 'Frequency', title = 'One-day Stock Returns Distribution in Sector: ' + sector)
        fileName = sector + '_1d_return_dist.png'
        plt.savefig(fileName)
        plt.clf()

    '''
    Comment:
    Above 11 plots show the stock return distribution on the last trading day of 2017.
    I noticed almost all sectors are having a normal distribution on their returns, except the telecommunication services section, which is less “normal”.
    However, since each sector are containing less sample, therefore distributions maybe not as powerful as putting all sector together.
    '''

    #   Look at stock returns distributions by sectors (50-day)
    for sector in sectorList:
        sector_df = subsetting_company(companyList, stockReturnPct_df, columnFilter, sector)
        for i in dayList:
            sectorPlottingArray = np.array(sector_df.iloc[i].tolist())
            sectorPlot = sns.distplot(sectorPlottingArray, hist = 0)
        sectorPlot.set(xlabel = 'Stork Returns(%)', ylabel = 'Frequency', title = '50-day Stock Returns Distribution in Sector: ' + sector)
        fileName = sector + '_50d_return_dist.png'
        plt.savefig(fileName)
        plt.clf()

    '''
    Comment:
    Above 11 plots are showing return distribution by sectors in random 50 days. 
    It looks like, the distribution of return by sectors are still normal from general.
    Interestingly, it can be easily found that the IT sector has better performance than others because it skewed to right, meaning more outliers on the positive side;
    While the energy sector is not as good as others as it has more outliers on the negative side.
    '''

'''
Summary:
According to presented data, stock returns are distributed normally, with symmetric pattern, from a general/overall market aspect. 
Looking from sector to sector, stock returns are still distributed normally, but will more significant skewness from plots. 
However, reasons for the skewness could be varies, such as short in sample size (both in amounts of company and/or amounts of day included).
In short, stock returns are normally distributed.
'''