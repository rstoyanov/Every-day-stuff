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

scrap_olx('https://www.olx.bg/nedvizhimi-imoti/prodazhbi/garazhi-parkomesta/oblast-sofiya-grad/q-%D0%B3%D0%B0%D1%80%D0%B0%D0%B6/?page=1')