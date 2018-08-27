# -*- coding: utf-8 -*-
'''
Function:   Obtain historical performance data for specific stock traded in HKEx
Outputs:    Data table stored in CSV files (one stock one CSV file)
Inputs:     Ticker list
Author:     Kin.Z
Date:       11/08/2017
'''

#import os
#os.chdir(r'D:\GtechFin\20171106\HKStockData')

from urllib.request import urlopen as uReq
from bs4 import BeautifulSoup as soup
import time
import sys
import pandas as pd
import json
import HKExListofSecurity as HKLoS
import datetime


def get_analytics(ticker, year_no = 0):
   
    #   if input of year missing, obtain all available data since 2000, otherwise uses specific year 
    if year_no == 0:
        year_li = list(range(datetime.datetime.now().year, 1999, -1))
        year_str = ','.join(str(year_it) for year_it in year_li)
    else:
        year_str = str(year_no)

    #my_url = 'http://hkf10.eastmoney.com/F9HKStock/GetAnalysisSummaryData.do?securityCode=00700.HK&yearList=2017&reportTypeList=1,5,3,6&dateSearchType=1&listedType=0,1&reportTypeInScope=1&reportType=0&rotate=0&seperate=0&order=desc&cashType=0&exchangeValue=0&customSelect=0&CurrencySelect=0'
    my_url = 'http://hkf10.eastmoney.com/F9HKStock/GetAnalysisSummaryData.do?securityCode=00700.HK&yearList=' + year_str + '&reportTypeList=1,5,3,6&dateSearchType=1&listedType=0,1&reportTypeInScope=1&reportType=0&rotate=0&seperate=0&order=desc&cashType=0&exchangeValue=0&customSelect=0&CurrencySelect=0'

    uClient = uReq(my_url)
    page_html = uClient.read()
    uClient.close()

    page_data_li = json.loads(json.loads(page_html))
    
    col_li = page_data_li[0].keys()
    analytics_df = pd.DataFrame([], columns = col_li)

    for i in range(len(page_data_li)):
        temp_df = pd.DataFrame([page_data_li[i].values()], columns = col_li)
        analytics_df = pd.concat([analytics_df, temp_df])

    analytics_df =  analytics_df.drop(['IsShowChart', 'IsBold', 'Indent'], axis = 1)

    return analytics_df

def format_ticker(ticker_li):
    op_ticker_li = []
    for i in ticker_li:
        if len(str(i)) == 1:
            ticker = '0000' + str(i) + '.HK'
        if len(str(i)) == 2:
            ticker = '000' + str(i) + '.HK'
        if len(str(i)) == 3:
            ticker = '00' + str(i) + '.HK'
        if len(str(i)) == 4:
            ticker = '0' + str(i) + '.HK'
        if len(str(i)) == 5:
            ticker = str(i) + '.HK'
        op_ticker_li.append(ticker)
    return op_ticker_li

if __name__ == '__main__':
    #ticker_li = [700, 701, 702]
    test_indicator = 1
    try:
        tk_li = ticker_li
    except:
        #   Obtain ticker list from HKEx
        print('Obtaining ticker list from HKEx.')
        security_df = HKLoS.get_LoS()
        print('Ticker list download finished.')

        #   Keep if the security is equity
        equity_df = security_df[security_df.category == 'Equity']

        #   formatting ticker list into acceptable expression: xxxxx.HK
        ticker_li = equity_df['ticker'].tolist()

    #   if testing, run a small list
    if test_indicator == 1 and len(ticker_li) > 100:
        ticker_li = ticker_li[0:10]
        year_no = 2016
    ticker_li = format_ticker(ticker_li)

    # obtain data for each ticker
    for ticker in ticker_li:
        print('Working on ticker: ' + ticker)
        try:
            year_no
            ticker_df = get_analytics(ticker, year_no)
            filename = ticker + '_' + str(year_no) + '.csv'
            op_str = 'Year ' + str(year_no) + ' data for '
        except:
            ticker_df = get_analytics(ticker)
            filename = ticker + '_allyears.csv'
            op_str = 'All years data for '

        ticker_df.to_csv(filename)
        print(op_str + ticker + ' finished.')
