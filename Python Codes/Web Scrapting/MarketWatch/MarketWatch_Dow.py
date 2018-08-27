from urllib.request import urlopen as uReq
from bs4 import BeautifulSoup as soup
import time
import sys
import pandas as pd


def get_indices(my_url):
    #my_url = 'https://www.marketwatch.com/tools/marketsummary'

    uClient = uReq(my_url)
    page_html = uClient.read()
    uClient.close()
    page_soup = soup(page_html, 'html.parser')

    market_soup = page_soup.find('div', {'id': 'mastheadmarket'})
    market_count = len(market_soup.find_all('a'))
    
    #page soup for name of index:
    index_name = market_soup.find_all('a')
    index_li = []
    
    #page soup for last market price
    ls_mkt_px = market_soup.find_all('div', {'class': 'bgLast marketprice'})
    ls_mkt_px_li = []

    #page soup for price change
    mkt_px_chg = market_soup.find_all('div', {'class': 'bgChange marketchange'})
    mkt_px_chg_li = []

    #page soup for price change in percentage
    mkt_px_chg_pct = market_soup.find_all('div', {'class': 'bgPercentChange marketpercent'})
    mkt_px_chg_pct_li = []

    #append all value to corresponding list
    for i in range(market_count):
        index_li.append(index_name[i].text)
        ls_mkt_px_li.append(ls_mkt_px[i].text)
        mkt_px_chg_li.append(mkt_px_chg[i].text)
        mkt_px_chg_pct_li.append(mkt_px_chg_pct[i].text)
    
    #putting list together as dataframe
    market_data = {'index_name': index_li, \
                   'Last_market_price': ls_mkt_px_li, \
                   'Market_price_change': mkt_px_chg_li, \
                   'Market_price_change_percentage':mkt_px_chg_pct_li}
    
    #set up dataframe
    market_df = pd.DataFrame(market_data).set_index('index_name')

    return market_df  

def get_mkt_breakdown(my_url):
    #my_url = 'https://www.marketwatch.com/tools/marketsummary'

    uClient = uReq(my_url)
    page_html = uClient.read()
    uClient.close()
    page_soup = soup(page_html, 'html.parser')
    
    #page soup for marketbreakdown table
    market_soup = page_soup.find('div', {'id': 'marketbreakdown'})

    #obtain column and row number from the marketbreakdown table
    col_count = len(market_soup.find('tr', {'class': 'aleft understated'}).find_all('td'))
    row_count = len(market_soup.find_all('tr'))
    
    #dataframe for output
    breakdown_tb = pd.DataFrame([])
    #loop over columns
    for col_index in range(col_count):
        col_li = []
        #loop over rows
        for row_index in range(row_count):
            try:
                col_li.append(market_soup.find_all('tr')[row_index].find_all('td')[col_index].text)
            except:
                col_li.append('')
        if col_index == 0:
            col_li.append('Time')
        elif col_index == 1:
            timestr = market_soup.find('div', {'class': 'understated'}).text
            for i, c in enumerate(timestr):
                if c.isdigit():
                    start = i
                    break
            end = timestr.rfind('M') + 1
            timestr1 = timestr[start: end]
            col_li.append(timestr1)
        else:
            col_li.append('')
        #putting different columns together
        col_li_df = pd.DataFrame({col_li[0]: col_li[1:]})
        breakdown_tb = pd.concat([breakdown_tb, col_li_df], axis = 1)

    #setting up index for dataframe
    breakdown_tb = breakdown_tb.set_index(breakdown_tb.columns[0])
    return breakdown_tb
       

if __name__ == '__main__':
    my_url = 'https://www.marketwatch.com/tools/marketsummary'
    market_indices = get_indices(my_url)
    market_breakdown = get_mkt_breakdown(my_url)
    print(market_indices)
    print(market_breakdown)


