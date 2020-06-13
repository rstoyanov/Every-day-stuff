URL = 'https://www.imoti.net/bg/obiavi/r/prodava/sofia/garaj/?sid=icfFoO'

def send_email(content):
    import smtplib
    from email.message import EmailMessage
    import config

    msg = EmailMessage()
    msg.set_content(content)

    msg['Subject'] = config.SUBJECT
    msg['From'] = config.FROM
    msg['To'] = config.TO

    s = smtplib.SMTP(host=config.SERVER, port=config.PORT)
    s.starttls()
    s.login(config.EMAIL, config.PASSWORD)

    s.send_message(msg)
    s.quit()

def scrap(URL):

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
        result += "{}, {}, {}, {}, {}, {} \n\n".format(title,price,price_per_m2,location,details,link)
    return result
    
content = scrap(URL)

send_email(content)
