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

    # Importing moduls used in this function
    print("Importing modules")
    import requests
    from bs4 import BeautifulSoup
    import pickle

    # Defining variables
    print("defining global variables")
    result = ""
    p = 1

    # Opens the content database and imports it to a variable. 
    # If the file does not exist, it creates an empty list.
    try:
        print("Opening the database file and importing to a variable")
        with open('sales_list.db', 'rb') as f:
            ad_list = pickle.load(f)
    except IOError:
        ad_list = []

    # Checking how many pages there are with results
    print("Checking for how many pages there are with results")
    page = requests.get(URL)
    soup = BeautifulSoup(page.content, 'html.parser')
    found_results = int(soup.select('.sort_results')[0].strong.text) 
    page_count = round(found_results / 10 + 2)
    print("{} pages for processing".format(page_count))

    # Processing each page and parsing the content
    while p < page_count:

        print("processing page {}".format(p))
        URL_page = URL[:39-1]+'{}'.format(p) + URL[39:]
        print("URL is {}".format(URL_page))
        page = requests.get(URL_page)
        soup = BeautifulSoup(page.content, 'html.parser')
        results = soup.find(id='content')
        content_elems = results.find_all('li')

        for content_elem in content_elems:
            title = content_elem.h2.a.text
            price = content_elem.div.text.split()
            price = price[2]
            details = " ".join(content_elem.p.text.split())
            link = content_elem.find('a').get('href')
            link = "http://sales.bcpea.org" + link
            ad = "{}, {}, {}.\n {} \n\n".format(title,price,details,link)
            print("Processed {}".format(ad))
            
            # Checking if the current ad processed is alreay in the database. 
            # It skips the ones already written.
            if ad not in ad_list:
                ad_list.append(ad)
                print("Added to list: {}".format(ad))
                result += ad

        p = p + 1

    # Dumps the list with ads to a database file
    print("Saving new records to a file")
    print("{} Records written".format(len(ad_list)))
    with open('sales_list.db', 'wb') as f:
        pickle.dump(ad_list, f) 
    return result


# Scrapper for olx.bg
def scrap_olx(URL):

    """
    This function web scrapes 
    the listing of ads from olx.bg
    """

    # Importing the modules
    import requests
    from bs4 import BeautifulSoup
    import pickle

    # Defining global variables
    result = ""
    p = 1

    # Opens the content database and imports it to a variable. 
    # If the file does not exist, it creates an empty list.
    try:
        with open('olx_list.db', 'rb') as f:
            ad_list = pickle.load(f)
    except IOError:
        ad_list = []

    # Checking how many pages there are for scraping
    page = requests.get(URL)
    print('Checking {}'.format(URL))
    soup = BeautifulSoup(page.text, 'lxml')
    results_found = int(soup.find('p', class_='color-2').text.split()[1])
    page_count = int(round((results_found / 40) +2))
    print("{} pages for processing".format(page_count))

    # Processing each page and parsing the content
    while p < page_count:

        print("processing page {}".format(p))
        idx = len(URL)
        URL_page = URL[:idx-1]+'{}'.format(p)
        print("URL is {}".format(URL_page))

        page = requests.get(URL_page)
        soup = BeautifulSoup(page.content, 'html.parser')
        results = soup.find(id='offers_table')
        content_elems = results.find_all('div', class_ = 'offer-wrapper')

        for content_elem in content_elems:
            title = content_elem.tbody.tr.h3.text.strip()
            price = content_elem.find('p', class_='price').text.strip()
            details = content_elem.find('span').text
            link = content_elem.find('a').get('href').split('#')[0]
            ad = "{}, {}, {}.\n {} \n\n".format(title,price,details,link)

            if ad not in ad_list:
                ad_list.append(ad)
                print("Added to list: {}".format(ad))
                result += ad

        p = p + 1
    
    print("Saving new records to a file")
    print("{} Records written".format(len(ad_list)))
    with open('olx_list.db', 'wb') as f:
        pickle.dump(ad_list, f) 

    return result

# Scrapper for imoti.net
def scrap_imoti(URL):

    """
    The function is designed to web scrap imoti.net
    It gets all the listed ads for specific URL
    """

    # Importing modules
    import requests
    from bs4 import BeautifulSoup
    import pickle

    # Defining global variables
    result = ""
    p = 1
    price_list_m2 = []

    # Opens the content database and imports it to a variable. 
    # If the file does not exist, it creates an empty list.
    try:
        with open('imoti_list.db', 'rb') as f:
            ad_list = pickle.load(f)
    except IOError:
        ad_list = []
    
    # Checking how many pages there are with results
    page = requests.get(URL)
    soup = BeautifulSoup(page.text, 'lxml')
    found_results = int(soup.find(id='number-of-estates').text.replace('/','').split()[0])
    page_count = round((found_results / 30) +2)
    print("{} pages for processing".format(page_count))

    # Processing each page and parsing the content
    while p < page_count:

        print("processing page {}".format(p))
        idx = URL.index("page=")
        URL_page = URL[:idx+5]+'{}'.format(p)+URL[idx+6:]
        print("URL is {}".format(URL_page))
        page = requests.get(URL_page)
        soup = BeautifulSoup(page.content, 'html.parser')
        results = soup.find('ul', class_='list-view real-estates')
        content_elems = results.find_all('li', class_ = 'clearfix')

        for content_elem in content_elems:
            title = content_elem.h3.text
            price = content_elem.header.strong.text.replace('EUR', '').strip()

            try:
                price_per_m2_raw = content_elem.li.text.split()
            except:
                continue

            price_per_m2 = [float(s) for s in price_per_m2_raw if s.isdigit()]
            location = content_elem.header.div.find('span', class_='location').text
            details = content_elem.select('p')[1].get_text(strip = True)
            link = "https://www.imoti.net" + content_elem.find('a').get('href').split('#')[0]
            ad = "{}, {}, {}, {}.\n {} \n{} \n\n".format(title,price,price_per_m2,location,details,link)
            print("Processed {}".format(ad))
            price_list_m2 += price_per_m2

            if ad not in ad_list:
                ad_list.append(ad)
                print("Added to list: {}".format(ad))
                result += ad

        p = p + 1
        
    print("Saving new records to a file")
    print("{} Records written".format(len(ad_list)))
    with open('imoti_list.db', 'wb') as f:
        pickle.dump(ad_list, f) 

    return result, price_list_m2

# Class for processing results and sending email

class EndResults:
    content_sales = []
    content_olx = []
    content_imoti = []

    def __init__(self):
        print('Processing results')

    def resultsSales(self,sites):
        self.sites = sites 

        for site in sites:
            if 'sales.bcpea.org' in site:
                if config.SALES_ENABLED == True:
                    content_sales += scrap_sales(site)
        if content_sales:
            send_email(content_sales,subject = 'PUBLIC SALES Listings')

exec = EndResults
exec.resultsSales(sites)

#Calculating average price per m2

if config.AVERAGE_PRICE_M2_ENABLED == True:
    price_list_m2 = scrap_imoti(config.URL_AVG_PRICE_M2)[1]
    avg = round(calculate_average(price_list_m2))
    #ts = time.time()
    #insert_date = datetime.datetime.fromtimestamp(ts).strftime('%Y-%m-%d %H:%M:%S')
    unix_time = int(time.time()) 
    write_db(unix_time,'garage',avg)
    #print(avg)