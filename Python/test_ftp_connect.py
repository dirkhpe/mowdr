#!/opt/csw/bin/python3
from ftplib import FTP

user = "SteenhaJu@www.mobielvlaanderen.be"
user_local = "SteenhaJu"

passwd = "xxxxxxxx"

host = "proxyservers.vlaanderen.be"
host_local = "www.mobielvlaanderen.be"

ftpdir = "apc"


ftp = FTP()
ftp.set_pasv(True)

# Connect over Fortigate - not working
# Connect works fine
ftp.connect(host=host, timeout=10)
# Login timeout
ftp.login(user=user, passwd=passwd)

# Direct connection on home (local) PC - working
"""
# Connect works fine
ftp.connect(host=host_local, timeout=10)
# Login OK
ftp.login(user=user_local, passwd=passwd)
"""


ftp.cwd(ftpdir)
res = ftp.mlsd()
for line in res:
    print("{l}".format(l=line))

ftp.quit()
