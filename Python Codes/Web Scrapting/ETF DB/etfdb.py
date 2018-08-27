from urllib.request import urlopen as uReq
from bs4 import BeautifulSoup as soup
import time
import sys
import pandas as pd
import time
from random import *

def get_link_list():
    #   getting all links for different types of etf
    my_url = 'http://etfdb.com/types/'
    uClient = uReq(my_url)
    page_html = uClient.read()
    uClient.close()
    page_soup = soup(page_html, 'html.parser')

    html_str = str(page_html)
    dymanic_str = html_str
    link_li = []
    #   extract link information from html string
    while len(dymanic_str) > 0:
        start_lookup_str = 'a href='
        end_lookup_str = '\">'
        dymanic_str.find(start_lookup_str)
        str_start = dymanic_str.find('a href=') + len(start_lookup_str) + 1
        dymanic_str = dymanic_str[str_start:-1]
        str_end = dymanic_str.find(end_lookup_str)
        link_str = dymanic_str[0:str_end]
        dymanic_str = dymanic_str[str_end:-1]
        if 'http://etfdb.com/type/' in link_str:
            link_li.append(link_str)
    return link_li

def get_data_in_list(my_url):
    #  get data in a list
    #  my_url = 'http://etfdb.com/type/bond/all-term/'

    uClient = uReq(my_url)
    page_html = uClient.read()
    uClient.close()
    page_soup = soup(page_html, 'html.parser')

    tabledata_li = []
    tablehead_li = []
    #tabledata_li.append(page_soup.find('div', {"class":"mm-heading-no-top-margin"}).text.replace('\n', ''))
    #   the code can only obtain ETFs within sub-categories, otherwise error will be rised
    #   therefore using try and except to skip any links are not sub-categories
    try:
        tabledata_li.append(page_soup.find('h1').text)
        tablehead_li.append('List')
    
        row_soup = page_soup.find('tbody').find('tr')
        tabledata_li_soup = row_soup.find_all('td')

        for i in [0, 1, 2]:
            tablehead_li.append(tabledata_li_soup[i].get('data-th'))
            tabledata_li.append(tabledata_li_soup[i].text)
        table_df = pd.DataFrame([tabledata_li], columns = tablehead_li)
    except:
        table_df = pd.DataFrame([])

    return table_df

def Main():
    link_li = get_link_list()
    op_df = pd.DataFrame([])
    i = 0
    for my_url in link_li:
        # the if statement is intent to slow down the speed of request toward the website.
        #   I noticed the website will refuse to connect after around 70 request received.
        if i%100 == 0 and i != 0:
            op_df.to_csv('list_of_etf.csv')
            print('Parial of ETF saved.')
            time.sleep(100 + i)
        else:
            random_time = randint(1, 10)
            print('Going to sleep for ' + str(random_time) + ' seconds.')
            time.sleep(random_time)

        table_df = get_data_in_list(my_url)
        op_df = pd.concat([op_df, table_df])
        i = i + 1
        print(str(i) + ' done!')
    op_df.to_csv('list of etf.csv')
    return op_df


if __name__ == '__main__':
    Main()
