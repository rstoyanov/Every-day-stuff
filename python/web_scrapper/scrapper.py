import config

sites = config.URLS


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

def scrap_sales(URL):

    import requests
    from bs4 import BeautifulSoup

    page = requests.get(URL)

    soup = BeautifulSoup(page.content, 'html.parser')
    results = soup.find(id='content')
    content_elems = results.find_all('li')

    result = ""

    for content_elem in content_elems:
        title = content_elem.h2.a.text
        price = content_elem.div.text.split()
        price = price[2]
        details = " ".join(content_elem.p.text.split())
        link = content_elem.find('a').get('href')
        link = "http://sales.bcpea.org" + link
        result += "{}, {}, {}.\n {} \n\n".format(title,price,details,link)
    return result

def scrap_olx(URL):

    import requests
    from bs4 import BeautifulSoup

    page = requests.get(URL)

    soup = BeautifulSoup(page.content, 'html.parser')
    results = soup.find(id='offers_table')
    content_elems = results.find_all('div', class_ = 'offer-wrapper')

    result = ""

    for content_elem in content_elems:
        title = content_elem.tbody.tr.h3.text.strip()
        price = content_elem.find('p', class_='price').text.strip()
        details = content_elem.find('span').text
        link = content_elem.find('a').get('href').split('#')[0]
        result += "{}, {}, {}.\n {} \n\n".format(title,price,details,link)
    return result

def scrap_imoti(URL):

    import requests
    from bs4 import BeautifulSoup

    page = requests.get(URL)

    soup = BeautifulSoup(page.content, 'html.parser')
    results = soup.find('ul', class_='list-view real-estates')
    content_elems = results.find_all('li', class_ = 'clearfix')

    result = ""

    for content_elem in content_elems:
        title = content_elem.h3.text
        price = content_elem.header.strong.text.replace('EUR', '').strip()
        price_per_m2_raw = content_elem.li.text.split()
        price_per_m2 = [float(s) for s in price_per_m2_raw if s.isdigit()]
        location = content_elem.header.div.find('span', class_='location').text
        details = content_elem.select('p')[1].get_text(strip = True)
        link = "https://www.imoti.net" + content_elem.find('a').get('href').split('#')[0]
        result += "{}, {}, {}, {}.\n {} \n{} \n\n".format(title,price,price_per_m2,location,details,link)
    return result

for site in sites:
    
    if 'sales.bcpea.org' in site:
        if config.SALES_ENABLED == True:
            content_sales = scrap_sales(site)
            subject = "PUBLIC SALES Listings"
            send_email(content_sales,subject)

    if 'olx.bg' in site:
        if config.OLX_ENABLED == True:

            content_olx = scrap_olx(site)
            subject = "OLX Listings"
            send_email(content_olx,subject)

    if 'imoti.net' in site:   
        if config.IMOTI_ENABLED == True:

            content_imoti = scrap_imoti(site)
            subject = "IMOTI.NET Listings"
            send_email(content_imoti,subject)
