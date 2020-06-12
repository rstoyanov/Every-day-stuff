urls = ['https://www.imoti.net/bg/obiavi/r/prodava/sofia/garaj/?sid=icfFoO', 
       'https://www.olx.bg/nedvizhimi-imoti/prodazhbi/garazhi-parkomesta/oblast-sofiya-grad/q-%D0%B3%D0%B0%D1%80%D0%B0%D0%B6/',
       'http://sales.bcpea.org/bg/properties.html?court=28&type=8&city=1']

content = ""

for url in urls:
    if "imoti.net" in url:
        imoti_url = url
    if "olx.bg" in url:
        olx_url = url
    if "sales" in url:
        sales_url = url
    else: 
        pass
    
def scrap_sales(sales_url):

    import requests
    from bs4 import BeautifulSoup

    page = requests.get(sales_url)

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
        result += "Обяви от ЧСИ \n\n {}, {}, {}, Link: {} \n\n".format(title,price,details,link)
    return result


def scrap_imoti(imoti_url):

    import requests
    from bs4 import BeautifulSoup



    page = requests.get(imoti_url)

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
        result += "Обяви от imoti.net \n\n {}, {}, {}, {}, {}, {} \n\n".format(title,price,price_per_m2,location,details,link)
    return result
    
def scrap_olx(olx_url):

    import requests
    from bs4 import BeautifulSoup

    page = requests.get(olx_url)

    soup = BeautifulSoup(page.content, 'html.parser')
    results = soup.find(id='offers_table')
    content_elems = results.find_all('div', class_ = 'offer-wrapper')

    result = ""

    for content_elem in content_elems:
        title = content_elem.tbody.tr.h3.text.strip()
        price = content_elem.find('p', class_='price').text.strip()
        details = content_elem.find('span').text
        link = content_elem.find('a').get('href').split('#')[0]
        result += "Обяви от OLX \n\n {}, {}, {}, Link: {} \n\n".format(title,price,details,link)
        return result

content_sales = scrap_sales(sales_url)
content_imoti = scrap_imoti(imoti_url)
content_olx = scrap_olx(olx_url)
print(content_olx)
