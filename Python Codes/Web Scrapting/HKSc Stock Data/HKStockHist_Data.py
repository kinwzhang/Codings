'''
Function:   Obtain historical data for specific stock traded in HKEx
Outputs:    Data table stored in CSV files (one stock one CSV file)
Inputs:     Ticker list
Author:     Kin.Z
Date:       11/06/2017
'''


from urllib.request import urlopen as uReq
from bs4 import BeautifulSoup as soup
import time
import sys
import pandas as pd
import json


def get_hist_data(ticker):
    # my_url = 'http://hkf10.eastmoney.com/F9HKStock/GetStockDailyMarketDataList.do?securityCode=00700.HK'
    my_url = 'http://hkf10.eastmoney.com/F9HKStock/GetStockDailyMarketDataList.do?securityCode=' + ticker
    print('Working on ' + ticker)
    
    #   Download data from the url
    start_dl = time.time()
    uClient = uReq(my_url)
    page_html = uClient.read()
    uClient.close()
    end_dl = time.time()
    print('Download used: ' + str(end_dl - start_dl) + ' seonds.')
    
    #   format downloaded data
    start_gdr = time.time()
    page_data_li = json.loads(page_html)
    col_li = page_data_li[0].keys()
    hist_data_df = pd.DataFrame([], columns = col_li)
    end_gdr = time.time()
    print('Getting data ready used: ' + str(end_gdr - start_gdr) + ' seconds.')

    #   putting data into DataFrame
    print('Current stock has ' + str(len(page_data_li)) + ' days of data.')
    start_wdtdf = time.time()
    for i in range(len(page_data_li)):
        temp_df = pd.DataFrame([page_data_li[i].values()], columns = col_li)
        hist_data_df = pd.concat([hist_data_df, temp_df])
    end_wdtdf = time.time()
    print('Writing dataframe used: ' + str(end_wdtdf - start_wdtdf) + ' seconds.')
    hist_data_df = hist_data_df.set_index('TRADEDATE')

    return hist_data_df

if __name__ == '__main__':
    #   Sample ticker list
    t_list = list(range(1, 10))
    #   format ticker from number into xxxxx.HK
    for i in t_list:
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
        filename = ticker + '.csv'
        hist_data_df = get_hist_data(ticker)
        hist_data_df.to_csv(filename)