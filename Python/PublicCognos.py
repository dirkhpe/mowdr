#!/opt/csw/bin/python3

"""
This class consolidates functions related to the Public Cognos URL.
An instance (object) is created for each indicator. The Cognos URL is calculated by default.
Checking if the site exists and adding the URL to the database and the Open Data website.
Note that the Public Cognos URL is too long for ckan. When trying to create a resource with a link of this size (or
complexity?) ckan fails with an internal server errror. (exact reason has not been investigated).
Therefore ckan will be provided the link to a (shorter, less complex) redirect page.
"""

# import httplib2
import logging
from urllib.request import urlopen
from urllib.parse import quote


class PublicCognos:

    def __init__(self, indicator_name):
        """
        Method to instantiate the class in an object for the indicator name.
        :param indicator_name: Name of the indicator.
        :return: Object to manage Public Cognos behaviour for the indicator name.
        """
        self.indicator_name = indicator_name
        self.cognos_url = self._set_cognos_url()
        return

    def _set_cognos_url(self):
        """
        Internal method to calculate the Public Cognos URL for the Indicator.
        :return:
        """
        encoded_name = quote(self.indicator_name, safe='/()')  # parentheses not encoded by Cognos...
        url_part1 = "http://vobippubliek.vlaanderen.be/cognos10/cgi-bin/cognosisapi.dll?"
        url_part2 = "b_action=cognosViewer&ui.action=run&ui.object=%2fcontent%2ffolder%5b%40name%3d%271M%20-%20"
        url_part3 = "Mobiliteit%20en%20Openbare%20Werken%20(MOW)%27%5d%2ffolder%5b%40name%3d%27Dataroom%27%5d%2ffolder"
        url_part4 = "%5b%40name%3d%27Standaardrapporten%27%5d%2ffolder%5b%40name%3d%27{0}%27%5d%2f"
        url_part5 = "report%5b%40name%3d%27{0}%27%5d"
        url_part6 = "&ui.name={0}&run.outputFormat=&ui.backURL=%2fcognos10%2fcgi-bin%2fcognosisapi.dll"
        url_part7 = "%3fb_action%3dxts.run%26m%3dportal%2fcc.xts%26m_folder%3di5883F6B255F74A60BA041D645258BA30"
        url_raw = url_part1 + url_part2 + url_part3 + url_part4 + url_part5 + url_part6 + url_part7
        url = url_raw.format(encoded_name)
        logging.debug("Cognos URL: " + url)
        return url

    def get_cognos_url(self):
        """
        Method to return the Public Cognos URL for the indicator name.
        Note that this should not be used, as the Redirect-URL on the Repository server will be used.
        :return:
        """
        return self.cognos_url

    def check_if_cognos_report_exists(self):
        """
        Method to check if Public Cognos URL exists.
        If the Public Cognos URL exists, then a KeyError is returned. So KeyError is the expected and valid response.
        Else False is returned.
        :return: True if Public Cognos URL exists. False otherwise.
        """
        logging.debug("Check Cognos for " + self.indicator_name)
        # h = httplib2.Http()
        # resp = h.request(self.cognos_url)
        resp = urlopen(self.cognos_url)
        logging.debug("Message: " + str(resp.msg) + " - Status: " + str(resp.status))
        logging.debug(resp.read())
        if 'getFormWarpRequest' in str(resp.read()):
            logging.debug("Cognos URL for " + self.indicator_name + " exists.")
            return True
        else:
            logging.debug("Cognos URL for " + self.indicator_name + " does not exists.")
            return False

    def redirect2cognos_page(self, indic_id, config_hdl):
        """
        This method will create the Redirect page to Public Cognos URL. The full path of the page will be returned to
        the calling program, so the calling program can post it on the repository server.
        :param indic_id: Indicator ID.
        :param config_hdl: Handle to the config file (ini) object.
        :return: Filename (including path) of the redirect page.
        :return: URL to the redirect page.
        """
        pc_prefix = config_hdl['OpenData']['public_cognos_prefix']
        scandir = config_hdl['Main']['scandir']
        ftphome = config_hdl['FTPServer']['ftp_home']
        ftpdir = config_hdl['FTPServer']['dir']
        redirect_filename = pc_prefix + str(indic_id).zfill(3) + '.html'
        redirect_file = scandir + '/' + redirect_filename
        redirect_url = ftphome + '/' + ftpdir + '/' + redirect_filename
        # Write Multiple Lines:
        # http://stackoverflow.com/questions/16162383/how-to-easily-write-a-multi-line-file-with-variables-python-2-6
        redirect_contents = """
        <!DOCTYPE HTML>
        <html lang="en-US">
        <head>
            <meta charset="UTF-8">
            <meta http-equiv="refresh" content="1;url={pc_url}">
            <script type="text/javascript">
                window.location.href = "{pc_url}"
            </script>
            <title>Page Redirection</title>
        </head>
        <body>
            <!-- Note: don't tell people to `click` the link, just tell them that it is a link. -->
            If you are not redirected automatically, follow the <a href='{pc_url}'>link to Public Cognos Report
            for {indicator}</a>
        </body>
        </html>
        """
        context = {
            "pc_url": self.cognos_url,
            "indicator": self.indicator_name
        }
        with open(redirect_file, 'w') as myfile:
            myfile.write(redirect_contents.format(**context))
        logging.debug("File " + redirect_file + " created for loading on " + redirect_url)
        return redirect_file, redirect_url
