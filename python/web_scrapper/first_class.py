class EndResults:
    content_sales = []
    content_olx = []
    content_imoti = []

    def __init__(self):
        print('Processing results')

    def resultsSales(self,sites):
        self.sites = sites 

        for site in sites:
            if 'sales.bcpea.org' in site:
                if config.SALES_ENABLED == True:
                    content_sales += scrap_sales(site)
        if content_sales:
            send_email(content_sales,subject = 'PUBLIC SALES Listings')

