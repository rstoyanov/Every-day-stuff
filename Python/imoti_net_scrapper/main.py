URL = 'https://www.imoti.net/bg/obiavi/r/prodava/sofia/garaj/?sid=icfFoO'

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
        price_per_m2 = (content_elem.li.text.split())[3]
        location = content_elem.header.strong.text.strip()
        details = content_elem.select('p')[1].get_text(strip = True)
        link = content_elem.find('a').get('href').split('#')[0]
        result += "{}, {}, {}, {}, {} Link: {} \n\n".format(title,price,price_per_m2,location,details,link)
    return result
    
content = scrap(URL)

print(content)
