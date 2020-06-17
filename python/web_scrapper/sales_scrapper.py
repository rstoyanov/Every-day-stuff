def scrap_sales(URL):

    # Importing moduls used in this function
    print("Importing modules")
    import requests
    from bs4 import BeautifulSoup
    import pickle

    # Defining variables
    print("defining global variables")
    result = ""
    p = 1

    # Opens the content database and imports it to a variable. If the file does not exist, it creates an empty list.
    try:
        print("Opening the database file and importing to a variable")
        with open('sales_list.txt', 'rb') as f:
            ad_list = pickle.load(f)
    except IOError:
        ad_list = []

    # Checking how many pages there are with results
    print("Checking for how many pages there are with results")
    page = requests.get(URL)
    soup = BeautifulSoup(page.content, 'html.parser')
    found_results = int(soup.select('.sort_results')[0].strong.text) 
    page_count = round(found_results / 10 + 2)
    print("{} pages for processing".format(page_count))

    # Processing each page and parsing the content
    while p < page_count:

        print("processing page {}".format(p))
        URL_page = URL[:39-1]+'{}'.format(p) + URL[39:]
        print("URL is {}".format(URL_page))
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
            print("Processed {}".format(ad))
            
            # Checking if the current ad processed is alreay in the database. 
            # It skips the ones already written.
            if ad not in ad_list:
                ad_list.append(ad)
                print("Added to list: {}".format(ad))
                result += ad

        p = p + 1

    # Dumps the list with ads to a database file
    print("Saving new adds to a file")
    print("{} Records written".format(len(ad_list)))
    with open('sales_list.txt', 'wb') as f:
        pickle.dump(ad_list, f) 
    return result

        
final_result = scrap_sales('http://sales.bcpea.org/bg/properties-p1.html?type=16')
print(final_result)
