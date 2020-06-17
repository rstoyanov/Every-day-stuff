def scrap_sales(URL):

    import requests
    from bs4 import BeautifulSoup
    import pickle

    page = requests.get(URL)
    soup = BeautifulSoup(page.text, 'lxml')
    page_content = soup.select('.pager')
    page_list_raw = page_content[0].text.split()
    page_list = [int(p) for p in page_list_raw if p.isdigit()]
    first_page = page_list[0]
    last_page = page_list[-1]
    print(first_page)
    print(last_page)
    result = ""

    for p in range(first_page,last_page):
        if p == 1:
            page = requests.get(URL)
            soup = BeautifulSoup(page.content, 'html.parser')
            results = soup.find(id='content')
            content_elems = results.find_all('li')

            try:
                with open('sales_list.txt', 'rb') as f:
                    ad_list = pickle.load(f)
            except IOError:
                ad_list = []

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
               
        if p != 1: 
            URL_page = URL[:36]+'-p{}'.format(p) + URL[36:]
            
            page = requests.get(URL_page)
            soup = BeautifulSoup(page.content, 'html.parser')
            results = soup.find(id='content')
            content_elems = results.find_all('li')

            try:
                with open('sales_list.txt', 'rb') as f:
                    ad_list = pickle.load(f)
            except IOError:
                ad_list = []

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

        #scrape all other pages.
        
final_result = scrap_sales('http://sales.bcpea.org/bg/properties.html?type=16')
print(final_result)

u = 'http://sales.bcpea.org/bg/properties.html?type=16'