import smtplib

client = smtplib.SMTP('localhost')

fromaddr = 'robb@tracer'
toaddrs = 'robb@tracer'
msg = 'Hello'

client.sendmail(fromaddr, toaddrs, msg)
client.quit()