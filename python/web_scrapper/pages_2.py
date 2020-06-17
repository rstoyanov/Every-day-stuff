def scrap_sales(URL):

    import requests
    from bs4 import BeautifulSoup
    import pickle

    result = ""
    p = 1

    try:
        with open('sales_list.txt', 'rb') as f:
            ad_list = pickle.load(f)
    except IOError:
        ad_list = []

    page = requests.get(URL)
    soup = BeautifulSoup(page.content, 'html.parser')
    found_results = int(soup.select('.sort_results')[0].strong.text) 
    page_count = round(found_results / 10 + 2)

    while p < page_count:

        URL_page = URL[:39-1]+'{}'.format(p) + URL[39:]
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
            
            if ad not in ad_list:
                ad_list.append(ad)
                result += ad

        p = p + 1
        with open('sales_list.txt', 'wb') as f:
            pickle.dump(ad_list, f) 
    return result

        
final_result = scrap_sales('http://sales.bcpea.org/bg/properties-p1.html?type=16')
print(final_result)
