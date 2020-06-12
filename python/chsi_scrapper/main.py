URL = 'http://sales.bcpea.org/bg/properties.html?court=28&type=8&city=1'
#URL = 'http://sales.bcpea.org/bg/properties.html?court=28&type=3&city=1'

def scrap(URL):

    import requests
    from bs4 import BeautifulSoup

    page = requests.get(URL)

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
        result += "{}, {}, {}, Link: {} \n\n".format(title,price,details,link)
    return result

content = scrap(URL)


### Send the result to email

import smtplib
import config

from string import Template

from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText

def get_contacts(filename):


    #Return two lists names, emails containing names and email addresses
    #read from a file specified by filename.
    
    names = []
    emails = []
    with open(filename, mode='r', encoding='utf-8') as contacts_file:
        for a_contact in contacts_file:
            names.append(a_contact.split()[0])
            emails.append(a_contact.split()[1])
    return names, emails

def read_template(filename):
    
    #Returns a Template object comprising the contents of the 
    #file specified by filename.
    
    
    with open(filename, 'r', encoding='utf-8') as template_file:
        template_file_content = template_file.read()
    return Template(template_file_content)

def main():
    names, emails = get_contacts('mycontacts.txt') # read contacts
    message_template = read_template('message.txt')

    # set up the SMTP server
    s = smtplib.SMTP(host=config.SERVER, port=config.PORT)
    s.starttls()
    s.login(config.EMAIL, config.PASSWORD)

    # For each contact, send the email:
    for name, email in zip(names, emails):
        msg = MIMEMultipart()       # create a message

        # add in the actual person name to the message template
        message = message_template.substitute(PERSON_NAME=name.title())

        # Prints out the message body for our sake
        print(content)

        # setup the parameters of the message
        msg['From']=config.EMAIL
        msg['To']=email
        msg['Subject']="Latest ads"
        
        # add in the message body
        msg.attach(MIMEText(content, 'plain'))
        
        # send the message via the server set up earlier.
        s.send_message(msg)
        del msg
        
    # Terminate the SMTP session and close the connection
    s.quit()
    
if __name__ == '__main__':
    main()