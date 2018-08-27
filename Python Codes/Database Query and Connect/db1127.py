
import numpy as np
import pandas as pd
import os

from security import Security


def relation_lookup(original_ticker, destination_ticker, lookup_ticker, lookup_df, path_li):
    print('Looking up ' + lookup_ticker + ', with origin: ' + original_ticker + ' and destination: ' + destination_ticker)
    result_ticker_li = set(lookup_df['lag_ticker'].tolist())    
    #   if found origianl ticker from the list, relation is invalid
    if destination_ticker in result_ticker_li:
        result = 'invalid'
        return result, path_li
    elif destination_ticker in path_li or original_ticker == destination_ticker:
        result = 'looping'
        return result, path_li
    else:
        for a_ticker in result_ticker_li:
            if a_ticker == lookup_ticker:
                result = 'looping'
                return result, path_li
            path_li.append(a_ticker)
            a_df = obtain_from_lead_df(a_ticker)
            result, path_li = relation_lookup(original_ticker, destination_ticker, a_ticker, a_df, path_li)
            return result, path_li

    
def obtain_from_lag_df(ticker):
    result_df = possible_relation_df.loc[(possible_relation_df['lag_ticker'] == ticker)]
    return result_df

def obtain_from_lead_df(ticker):
    result_df = possible_relation_df.loc[(possible_relation_df['lead_ticker'] == ticker)]
    return result_df

# step 1: database connection
# db = Security(user='readonly', password='', host='###IP ADDRESS', port=3306, db='###DATABASE')
try:
    db
except:
    print('Database connection is required to performance query.')

kzsql = 'select lead_ticker, lag_ticker, n, cc, p from bpccm;'
kzdf = db.get_data_with_sql(kzsql)
kzdf_2 = kzdf.loc[(kzdf['p'] <= 0.05)]
kzdf_2['lead_to_lag'] = np.where(kzdf_2['cc'] > 0, 1, -1)
kzdf_3 = kzdf.merge(kzdf_2, how = 'left').fillna(0)

possible_relation_df = kzdf_2.loc[(kzdf_2['lead_to_lag'] == -1)]
lead_ticker_li = set(possible_relation_df['lead_ticker'].tolist())
storage_df = possible_relation_df
for original_ticker in lead_ticker_li:
    current_df = obtain_from_lead_df(original_ticker)
    lag_ticker_li = set(current_df['lag_ticker'].tolist())
    for destination_ticker in lag_ticker_li:
        destination_df = obtain_from_lead_df(destination_ticker)
        lookup_ticker_li = set(destination_df['lag_ticker'].tolist())
        for lookup_ticker in lookup_ticker_li:
            #   Recording the path for tickers
            path_li = []
            path_li.append(original_ticker)
            path_li.append(lookup_ticker)
            #   Extract DataFrame for lookup
            lookup_df = obtain_from_lead_df(lookup_ticker)
            result, path_li = relation_lookup(original_ticker, destination_ticker, lookup_ticker, lookup_df, path_li)
            outcome_df = current_df.loc[(current_df['lag_ticker'] == destination_ticker)]
            outcome_df['validation'] = result
            outcome_df['path'] = '>'.join(path_li)
            storage_df = storage_df.merge(outcome_df, how = 'left')