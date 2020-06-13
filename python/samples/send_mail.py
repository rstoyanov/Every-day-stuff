def send_email(content):
    import smtplib
    from email.message import EmailMessage
    import config

    msg = EmailMessage()
    msg.set_content(content)

    msg['Subject'] = config.SUBJECT
    msg['From'] = config.FROM
    msg['To'] = config.TO

    s = smtplib.SMTP(host=config.SERVER, port=config.PORT)
    s.starttls()
    s.login(config.EMAIL, config.PASSWORD)

    s.send_message(msg)
    s.quit()





