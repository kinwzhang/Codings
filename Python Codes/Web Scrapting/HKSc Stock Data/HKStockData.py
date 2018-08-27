'''
Function:   Obtain latest HKEx traded stock data from sina.com
Outputs:    Data table stored in CSV files
Inputs:     Ticker list
Author:     Kin.Z
Date:       11/01/2017
'''

from urllib.request import urlopen as uReq
from bs4 import BeautifulSoup as soup
import time
import sys
import pandas as pd

def get_data_core(ticker_li):
    #   prepare url for obtaining data
    ticker_str = ','.join(ticker_li)
    ticker_se = pd.Series(ticker_li)
    my_url = 'http://hq.sinajs.cn/list=' + ticker_str
    #   data for all tickers downloaded at a time
    uClient = uReq(my_url)
    page_html = uClient.read()
    uClient.close()
    page_soup = soup(page_html, 'html.parser')

    page_soup_li = page_soup.text.split('\n')

    col_name_li = ['Company',
                   'Company_Chinese_Name',
                   'Open','Pre_Close',
                   'High',
                   'Low',
                   'Current',
                   'Current_Earn',
                   'Current_Earn_Pct',
                   'Bid',
                   'Ask',
                   'Turnover',
                   'Volume',
                   'UnKnown_3',
                   'UnKnown_4',
                   '52_High',
                   '52_Low',
                   'Date',
                   'Time']

    data_df = pd.DataFrame([], columns = col_name_li)
    #   handling one ticker in each loop, until all ticker finished
    for i in range(len(page_soup_li) - 1):
        soup_str = page_soup_li[i]
        str_start = soup_str.index('=') + 2
        str_end = soup_str.rfind(';') - 1
        current_str = soup_str[str_start:str_end]
        #   if statement handle error ticker provided
        if len(current_str) == 0:
            current_str = 'ns,ns,ns,ns,ns,ns,ns,ns,ns,ns,ns,ns,ns,ns,ns,ns,ns,ns,ns'
        data_li = current_str.split(',')
        temp_df = pd.DataFrame([data_li], columns = col_name_li)
        data_df = pd.concat([data_df, temp_df])

    #   getting output dataframe ready
    data_df['Ticker'] = ticker_se.values
    data_df = data_df.set_index('Ticker')
    data_df = data_df[data_df.Company != 'ns']
    return data_df
'''
sina.com only accepts up to 1000 ticker at a time
the expanded function will break ticker list into multiple sub lists, 
which are less than 1000 elements
'''
def get_data_expanded(ticker_li):
    stock_df = pd.DataFrame([])
    while len(ticker_li) > 999:
        current_ticker_li = ticker_li[0:999]
        ticker_li = ticker_li[1000:]
        working_ticker_li = []
        for i in current_ticker_li:
            if len(str(i)) == 1:
                working_ticker_li.append('hk0000' + str(i))
            if len(str(i)) == 2:
                working_ticker_li.append('hk000' + str(i))
            if len(str(i)) == 3:
                working_ticker_li.append('hk00' + str(i))
            if len(str(i)) == 4:
                working_ticker_li.append('hk0' + str(i))
            if len(str(i)) == 5:
                working_ticker_li.append('hk' + str(i))
        #   getting data and put data into CSV file
        temp_df = get_data_core(working_ticker_li)
        stock_df = pd.concat([stock_df, temp_df])

    working_ticker_li = []
    for i in ticker_li:
        if len(str(i)) == 1:
            working_ticker_li.append('hk0000' + str(i))
        if len(str(i)) == 2:
            working_ticker_li.append('hk000' + str(i))
        if len(str(i)) == 3:
            working_ticker_li.append('hk00' + str(i))
        if len(str(i)) == 4:
            working_ticker_li.append('hk0' + str(i))
        if len(str(i)) == 5:
            working_ticker_li.append('hk' + str(i))
    #   getting data and put data into CSV file
    temp_df = get_data_core(working_ticker_li)
    stock_df = pd.concat([stock_df, temp_df])

    return stock_df


if __name__ == '__main__':
    #   Sample ticker list
    '''
    sina.com accepts：
    'hk' + 5-digit number for stocks trade in HKSx;
    'sz' + 6-digit number for stocks traded in SZ;
    'sh' + 6-digit number for stocks traded in SH;

    Although the API accepts sz and sh, the format of returned data are different,
    the code works for HK stocks so far.
    '''

    t_list = list(range(1, 10000))
    start = time.time()
    hk_stock_df = get_data_expanded(t_list)
    end = time.time()
    print('Runtime: ' + str(end - start) + ' seconds.')
    hk_stock_df.to_csv('hk_stock_latest.csv')
