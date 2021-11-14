# The settings used in this file are imported from config.py
import config

import time
import datetime
import pickle

sites = config.URLS

# A function for calculating average prices. Takes list of prices as a parameter.
def calculate_average(list_prices):
    from statistics import mean
    return mean(list_prices)

# A function for sending emails. Parameters, email text and subject.
def send_email(content,subject):
    import smtplib
    from email.message import EmailMessage

    msg = EmailMessage()
    msg.set_content(content)

    msg['Subject'] = subject
    msg['From'] = config.FROM
    msg['To'] = config.TO

    s = smtplib.SMTP(host=config.SERVER, port=config.PORT)
    s.starttls()
    s.login(config.EMAIL, config.PASSWORD)

    s.send_message(msg)
    s.quit()

# Insert into MySQL 
def write_db(unix_time,type,price):
    # pip install mysql-connector-python
    import mysql.connector

    db = mysql.connector.connect(
    host = config.MYSQL_HOST,
    user = config.MYSQL_USER,
    password = config.MYSQL_PASS,
    database = config.MYSQL_DB
    ) 

    mycursor = db.cursor()
    
    sql = "INSERT INTO avg_prices_m2 (unix_time,type,price) VALUES (%s, %s, %s)"
    val = unix_time,type,price

    mycursor.execute(sql, val)
    db.commit()
    print(mycursor.rowcount, "was inserted.")

# Scrapper for public sales website: http://sales.bcpea.org/
def scrap_sales(URL):

    import requests
    from bs4 import BeautifulSoup

    page = requests.get(URL)

    soup = BeautifulSoup(page.content, 'html.parser')
    results = soup.find(id='content')
    content_elems = results.find_all('li')

    try:
        with open('sales_list.txt', 'rb') as f:
            ad_list = pickle.load(f)
    except IOError:
        ad_list = []
    
    result = ""

    for content_elem in content_elems:
        title = content_elem.h2.a.text
        price = content_elem.div.text.split()
        price = price[2]
        details = " ".join(content_elem.p.text.split())
        link = content_elem.find('a').get('href')
        link = "http://sales.bcpea.org" + link
        ad = "{}, {}, {}.\n {} \n\n".format(title,price,details,link)
        
        if ad not in ad_list:
            ad_list.append(ad)
            result += ad

    with open('sales_list.txt', 'wb') as f:
        pickle.dump(ad_list, f)            

    return result

# Scrapper for olx.bg
def scrap_olx(URL):

    import requests
    from bs4 import BeautifulSoup

    page = requests.get(URL)

    soup = BeautifulSoup(page.content, 'html.parser')
    results = soup.find(id='offers_table')
    content_elems = results.find_all('div', class_ = 'offer-wrapper')

    try:
        with open('olx_list.txt', 'rb') as f:
            ad_list = pickle.load(f)
    except IOError:
        ad_list = []

    result = ""

    for content_elem in content_elems:
        title = content_elem.tbody.tr.h3.text.strip()
        price = content_elem.find('p', class_='price').text.strip()
        details = content_elem.find('span').text
        link = content_elem.find('a').get('href').split('#')[0]
        ad = "{}, {}, {}.\n {} \n\n".format(title,price,details,link)

        if ad not in ad_list:
            ad_list.append(ad)
            result += ad

    with open('olx_list.txt', 'wb') as f:
        pickle.dump(ad_list, f) 

    return result

# Scrapper for imoti.net
def scrap_imoti(URL):

    import requests
    from bs4 import BeautifulSoup

    page = requests.get(URL)

    soup = BeautifulSoup(page.content, 'html.parser')
    results = soup.find('ul', class_='list-view real-estates')
    content_elems = results.find_all('li', class_ = 'clearfix')

    try:
        with open('imoti_list.txt', 'rb') as f:
            ad_list = pickle.load(f)
    except IOError:
        ad_list = []

    result = ""
    price_list_m2 = []

    for content_elem in content_elems:
        title = content_elem.h3.text
        price = content_elem.header.strong.text.replace('EUR', '').strip()
        price_per_m2_raw = content_elem.li.text.split()
        price_per_m2 = [float(s) for s in price_per_m2_raw if s.isdigit()]
        location = content_elem.header.div.find('span', class_='location').text
        details = content_elem.select('p')[1].get_text(strip = True)
        link = "https://www.imoti.net" + content_elem.find('a').get('href').split('#')[0]
        ad = "{}, {}, {}, {}.\n {} \n{} \n\n".format(title,price,price_per_m2,location,details,link)
        price_list_m2 += price_per_m2

        if ad not in ad_list:
            ad_list.append(ad)
            result += ad

    with open('imoti_list.txt', 'wb') as f:
        pickle.dump(ad_list, f) 

    return result, price_list_m2

for site in sites:
    
    if 'sales.bcpea.org' in site:
        if config.SALES_ENABLED == True:

            content_sales = scrap_sales(site)
            subject = "PUBLIC SALES Listings"

            if content_sales:
                send_email(content_sales,subject)

    if 'olx.bg' in site:
        if config.OLX_ENABLED == True:

            content_olx = scrap_olx(site)
            subject = "OLX Listings"

            if content_olx:
                send_email(content_olx,subject)
                

    if 'imoti.net' in site:   
        if config.IMOTI_ENABLED == True:

            content_imoti = scrap_imoti(site)[0]
            subject = "IMOTI.NET Listings"

            if content_imoti:
                send_email(content_imoti,subject)


#Calculating average price per m2

if config.AVERAGE_PRICE_M2_ENABLED == True:
    price_list_m2 = scrap_imoti(config.URL_AVG_PRICE_M2)[1]
    avg = round(calculate_average(price_list_m2))
    #ts = time.time()
    #insert_date = datetime.datetime.fromtimestamp(ts).strftime('%Y-%m-%d %H:%M:%S')
    unix_time = int(time.time()) 
    write_db(unix_time,'garage',avg)
    #print(avg)