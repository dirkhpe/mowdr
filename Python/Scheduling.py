#!/opt/csw/bin/python3

"""
This script will check scheduling practices, preferably in a while loop and launched from command line. (with ampersand)
"""
import datetime as dt
# import os
import subprocess
import sys
import time
from lib import my_env

def publish_status(deltatime):
    """
    This method will publish next run report to FTP Server.
    :return:
    """
    scandir = config['Main']['scandir']
    redirect_filename = 'nextrun.html'
    redirect_file = scandir + '/' + redirect_filename
    # Write Multiple Lines:
    # http://stackoverflow.com/questions/16162383/how-to-easily-write-a-multi-line-file-with-variables-python-2-6
    redirect_contents = """
    <!DOCTYPE HTML>
    <html lang="en-US">
    <head>
        <title>Open Data Refresh</title>
    </head>
        <body>
        <h1>Open Data Refresh</h1>
        Last run at {currtime},<br>Next run at {nexttime}.
        </body>
    </html>
    """
    context = {
        "currtime": dt.datetime.today().strftime("%d-%m-%Y %H:%M:%S"),
        "nexttime": deltatime
    }
    with open(redirect_file, 'w') as myfile:
        myfile.write(redirect_contents.format(**context))
    my_log.debug("File " + redirect_file + " created")
    return


# Initialize Environment
projectname = "mowdr"
modulename = my_env.get_modulename(__file__)
config = my_env.get_inifile(projectname, __file__)
my_log = my_env.init_loghandler(config, modulename)  # New date = new logfile
cmdline = config["Main"]["cmdline"]
while True:
    # Continuous loop - Reload environment
    config = my_env.get_inifile(projectname, __file__)
    my_log.info("In loop")
    cycletime = config['Main']['cycletime']
    try:
        sleeptime = int(cycletime)
    except ValueError:
        my_log.info("cycletime is not an integer: " + str(cycletime) + ", exit")
        sys.exit(1)
    else:
        if sleeptime > 0:
            subprocess.call(cmdline, shell=True)
            nextrun = dt.datetime.today() + dt.timedelta(0, sleeptime)
            next_run = nextrun.strftime("%d-%m-%Y %H:%M:%S")
            # publish_status(next_run)
            my_log.info("Going to sleep for " + cycletime + " seconds.")
            my_log.info("Next run is at %s", next_run)
            time.sleep(sleeptime)
        else:
            my_log.info("Sleeptime zero or less: " + cycletime + ", exiting...")
            sys.exit(1)
