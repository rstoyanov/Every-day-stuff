import config
URL = config.URL_OLX

def send_email(content):
    import smtplib
    from email.message import EmailMessage

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
        result += "{}, {}, {}, Link: {} \n\n".format(title,price,details,link)
    return result
    
content = scrap_olx(URL)
send_email(content)


