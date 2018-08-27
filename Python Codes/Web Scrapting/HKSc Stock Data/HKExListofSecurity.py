'''
Function:   Obtain list of securities traded in Hong Kong Stock Exchange
Outputs:    Data table stored in CSV files (one stock one CSV file)
Inputs:     ----
Author:     Kin.Z
Date:       11/08/2017
'''

import pandas as pd

def get_LoS():
    url_eng = 'http://www.hkex.com.hk/eng/services/trading/securities/securitieslists/ListOfSecurities.xlsx'
    url_chn = 'http://www.hkex.com.hk/chi/services/trading/securities/securitieslists/ListOfSecurities_c.xlsx'

    hk_security_eng = pd.read_excel(url_eng, header = 2).iloc[:, 0:4]
    hk_security_chn = pd.read_excel(url_chn, header = 2).iloc[:, [0, 1]]

    hk_security_eng = hk_security_eng.set_index(hk_security_eng.columns[0])
    hk_security_chn = hk_security_chn.set_index(hk_security_chn.columns[0])
    hk_security_chn = hk_security_chn.rename(columns = {hk_security_chn.columns[0]:'Name of Equities in Chinese'})

    hk_security = pd.concat([hk_security_eng, hk_security_chn],axis = 1, join = 'inner').reset_index()
    hk_security = hk_security.rename(columns = {hk_security.columns[0]:'ticker', 
                                                hk_security.columns[1]:'name_en', 
                                                hk_security.columns[2]:'category', 
                                                hk_security.columns[3]:'sub_category',
                                                hk_security.columns[4]:'name_cn'
                                                })
    
    return hk_security

if __name__ == '__main__':
    print('Loading security list...')
    hk_security = get_LoS()
    print('Finished loading.')
    hk_security.to_csv('hk_security_info.csv')
    print('Security list saved.')