import datetime
from polygon import RESTClient
import ta
import config
import pandas as pd
import json 
import ndjson
from ta.volatility import BollingerBands, AverageTrueRange
from ta.trend import IchimokuIndicator
from elasticsearch import Elasticsearch


def ts_to_datetime(ts) -> str:
    return datetime.datetime.fromtimestamp(ts / 1000.0).strftime('%Y-%m-%d %H:%M')


def main():
    key = "ASgqNjwGk9Odpeje4ry_x_3pMSNMDyAo"
    es = Elasticsearch([{'host': 'localhost', 'port': 9200}], http_auth=('elastic', 'changeme'))
    # RESTClient can be used as a context manager to facilitate closing the underlying http session
    # https://requests.readthedocs.io/en/master/user/advanced/#session-objects
    with RESTClient(key) as client:
        from_ = "2021-06-01"
        to = "2021-06-18"
        resp = client.stocks_equities_aggregates("SPY", 60, "minute", from_, to, unadjusted=False)

        print(type(resp.results))

        jsString = json.dumps(resp.results)
        #print(type(jsString))
        #print(jsString)

        #print(f"Minute aggregates for {resp.ticker} between {from_} and {to}.")

        #for result in resp.results:
        #    dt = ts_to_datetime(result["t"])
         #   print(f"{dt}\n\tO: {result['o']}\n\tH: {result['h']}\n\tL: {result['l']}\n\tC: {result['c']} ")
        for timeint in resp.results:
            #dt = ts_to_datetime(result["t"])
            timeint['sym'] = 'SPY'
            timeint['t'] = ts_to_datetime(timeint["t"])
            js = json.dumps(timeint)
            print(js)
            res = es.index(index='stock',doc_type='spy',body=js)
        
if __name__ == '__main__':
    main()
