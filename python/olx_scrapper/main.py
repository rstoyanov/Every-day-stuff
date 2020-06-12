URL = 'https://www.olx.bg/nedvizhimi-imoti/prodazhbi/garazhi-parkomesta/oblast-sofiya-grad/q-%D0%B3%D0%B0%D1%80%D0%B0%D0%B6/'

def scrap(URL):

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
    
content = scrap(URL)

print(content)
