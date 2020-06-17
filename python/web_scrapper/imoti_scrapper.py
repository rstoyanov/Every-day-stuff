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

scrap_imoti('https://www.imoti.net/bg/obiavi/r/prodava/sofia/garaj/?page=1&sid=icfFoO')