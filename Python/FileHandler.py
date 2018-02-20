#!/opt/csw/bin/python3

"""
This is the main application to handle files from Dataroom and process them for loading on the Open Data Platform.
File types handled are:
1. 'cijfersXML': XML representation of the Cijfers file. This file is mandatory to make Dataset
on Open Data platform public.
2. 'cijfersTable': HTML table representation of the Cijfers file. Optional.
3. 'commentaar': XML representation of the Commentaar file. Optional.
Apart from above 3 resources, the PublicCognos is handled as an additional resource without input file.
"""

import logging
import os
import re
import sys
import xml.etree.ElementTree as Et
from Datastore import Datastore
from Ftp_Handler import Ftp_Handler
from lib import my_env


class FileHandler:
    def __init__(self, config):
        self.config = config
        self.ds = Datastore(config)
        self.ftp = Ftp_Handler(self.config)

    def bijsluiter(self, indic_id):
        """
        This method will handle a bijsluiter file for this indicator. The bijsluiter file will be created, then
        copied to the ftp server. The url will be added to the indicators table so that the dcat_ap profile
        generator will pick up the bijsluiter.

        :param indic_id:

        :return:
        """
        bs_file = self.create_bijsluiter_file(indic_id)
        self.ftp.load_file(bs_file)
        # Calculate URL
        url = self.calculate_url(os.path.basename(bs_file))
        # Add URL to indicators table
        self.ds.insert_indicator(indic_id, "bijsluiter", url)
        return

    def create_bijsluiter_file(self, indic_id):
        """
        This method will create a bijsluiter file for the indicator.

        :param indic_id:

        :return: Filename of the bijsluiter file. Filename is in standard format for resources: resource_indicid.html
        Resource is 'bijsluiter', indicid is indicator ID, 3 characters or longer.
        """
        handledir = self.config['Main']['handledir']
        title = self.ds.get_indicator_val(indic_id, 'title')
        bs_head = """
<!DOCTYPE html>
<html>
    <title>Bijsluiter {title}</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <!-- Bootstrap -->
    <link href="//cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/3.3.7/css/bootstrap.min.css"
        rel="stylesheet">
    <link rel="stylesheet" href="/static/style.css">
<body>
<div class="container"><div class="row">
        """.format(title=title)
        gh = my_env.get_global_header(self.config)
        gf = my_env.get_global_footer(self.config)
        bs_h1 = "<h1>Bijsluiter {title}</h1>".format(title=title)
        bs_intro = "{inleiding}".format(inleiding=self.config["bijsluiter"]["inleiding"])
        bs_slot = "{bijkomende_info}".format(bijkomende_info=self.config["bijsluiter"]["bijkomende_info"])
        bs_close = "</div></div></body></html>"
        bs_table = '<h2>Informatie</h2><table class="table table-striped table-bordered table-condensed">'
        bs_table += '<thead><tr><th scope="col">Veld</th><th scope="col">Waarde</th></tr></thead><tbody>'
        attribs = self.ds.get_extra_values(indic_id)
        for k in attribs:
            bs_table += "<tr><td>{k}</td><td>{v}</td></tr>".format(k=k, v=attribs[k])
        bs_table += '</tbody></table>'
        bs = bs_head + gh + bs_h1 + bs_intro + bs_table + bs_slot + gf + bs_close
        bs_filename = "bijsluiter_{indic}.html".format(indic=str(indic_id).zfill(3))
        bs_file = os.path.join(handledir, bs_filename)
        bsh = open(bs_file, mode='w')
        bsh.write(bs)
        bsh.close()
        return bs_file

    def calculate_url(self, file):
        """
        This method will calculate URL for a file.

        :param file: Filename (not including path).

        :return: URL for the file, including FTP directory.
        """
        # Calculate URL
        ftp_home = self.config['FTPServer']['ftp_home']
        # Add FTP Subdirectory (if any)
        ftpdir = self.config['FTPServer']['dir']
        url = "{home}/{dir}/{file}".format(home=ftp_home, dir=ftpdir, file=file)
        return url

    def url_in_db(self, file):
        """
        Remove the url attribute for this resource.
        If file does not contain 'empty', then calculate URL the file and set result in indicators table.

        :param file: Filename of the resource (not including path!)

        :return:
        """
        logging.debug('Add/Remove file %s to indicators table.', file)
        indic_id = my_env.indic_from_file(file)
        attribute = my_env.attr_from_file('url', file)
        # Always remove attribute for this indicator. Then no insert / update logic is required.
        self.ds.remove_indicator_attribute(indic_id, attribute)
        if 'empty' not in file:
            url = self.calculate_url(file)
            # Add URL to indicator table.
            self.ds.insert_indicator(indic_id, attribute, url)
        return

    def size_of_file(self, handledir, file):
        """
        Remove the size attribute for this resource.
        If file does not contain 'empty', then calculate Size of the file and set result in indicators table.

        :param handledir: Current directory of the file.

        :param file:

        :return:
        """
        logging.debug('Add/Remove filesize %s to indicators table.', file)
        indic_id = my_env.indic_from_file(file)
        attribute = my_env.attr_from_file('size', file)
        # Always remove attribute for this indicator. Then no insert / update logic is required.
        self.ds.remove_indicator_attribute(indic_id, attribute)
        if 'empty' not in file:
            # Calculate size of file
            filename = os.path.join(handledir, file)
            size = os.path.getsize(filename)
            # Add size of file to indicator table.
            self.ds.insert_indicator(indic_id, attribute, size)
        return

    def load_metadata(self, metafile, indic_id):
        """
        For this indicator the metadata and/or resource files have been created or updated.
        Read the file with metadata and add or replace the information in table 'indicators'. This procedure will
        populate all fields that come from the 'Dataroom'.
        Call function to populate the dataset if this is a new dataset or an update of the dataset.
        Pre-requisite for this call is that dataset exists already.
        Cognos Add / Remove needs to be added here.

        :param metafile: pointer to the file with metadata.

        :param indic_id: Indicator ID

        :return:
        """
        # TODO: Add URL for 'bijsluiter' to database
        log_msg = "In load_metadata for file " + metafile
        logging.debug(log_msg)
        try:
            tree = Et.parse(metafile)
        except:  # catch all errors for now, try to be more specific in the future.
            e = sys.exc_info()[1]
            ec = sys.exc_info()[0]
            log_msg = "Error during parsing metafile xml: %s %s"
            logging.critical(log_msg, e, ec)
            return
        root = tree.getroot()
        # metadata is available, get list of attributes from Dataroom Application and required for Dataset Page.
        # First collect all attribute names in list attrib_names.
        attrib_names = []
        attribs = self.ds.get_attribs_source('Dataroom')
        for row in attribs:
            attrib_names.append(row[0])
        # Then remove information from Dataroom for Dataset for this indicator ID.
        for attrib_name in attrib_names:
            self.ds.remove_indicator_attribute(indic_id, attrib_name)
        # indicatorname = ""
        # Add variable data from indicator metadata xml to indicator table.
        for child in root:
            # First get child text
            if child.text:
                child_text = child.text.strip()
            else:
                # Metadata entry does not have a value (key only).
                child_text = '(niet ingevuld)'
            # Then see how to handle this text depending on the attribute
            if child.tag in attrib_names:
                # Metadata entry exists as an attribute
                self.ds.insert_indicator(indic_id, child.tag, child_text)
                # Some metadata fields will be used more than once in Open Data set.
                # The 'notes' field is a copy of 'definitie'.
                if child.tag.lower() == 'definitie':
                    self.ds.insert_indicator(indic_id, 'notes', child_text)
            # The 'title' field will be used for all Dataset and all resources and gets special treatment.
            elif child.tag.lower() == 'title':
                # Set Title for cijfers, commentaar and Cognos report (to do).
                indicatorname = child_text
                name_cijfersxml = child_text + " - cijfers (XML)"
                name_cijferstable = child_text + " - cijfers (Tabel)"
                name_commentaar = child_text + " - commentaar"
                name_cognos = indicatorname + " - cognos"
                self.ds.insert_indicator(indic_id, 'title', indicatorname)
                self.ds.insert_indicator(indic_id, 'name_cijfersxml', name_cijfersxml)
                self.ds.insert_indicator(indic_id, 'name_commentaar', name_commentaar)
                self.ds.insert_indicator(indic_id, 'name_cijferstable', name_cijferstable)
                self.ds.insert_indicator(indic_id, 'name_cognos', name_cognos)
            elif child.tag != 'id':
                log_msg = "Found Dataroom Attribute **" + child.tag + "** not required for Open Data Dataset"
                logging.warning(log_msg)

        # Add fixed information from 'OpenData' section in Config file to indicator table.
        additional_attribs = ['description_cijfersxml', 'format_cijfersxml', 'tdt_cijfersxml',
                              'description_cijferstable', 'format_cijferstable', 'tdt_cijferstable',
                              'description_commentaar', 'format_commentaar', 'tdt_commentaar',
                              'description_cognos', 'format_cognos', 'tdt_cognos', 'license_id',
                              'author_name', 'author_email', 'maintainer_name', 'maintainer_email',
                              'language']
        for add_attrib in additional_attribs:
            self.ds.insert_indicator(indic_id, add_attrib, self.config['OpenData'][add_attrib])
        # Create Bijsluiter file based on new metadata file and publish this on the FTP site
        self.bijsluiter(indic_id)
        return True

    def process_input_directory(self):
        """
        Function to scan input directory for new files in groups. First group contains the resource files commentaar,
        cijfersXML and cijfersTable.
        The second group of files is the metadata files.
        In the first group of files, the file is moved first. Then if the file contains string 'empty' then the file
        is removed from FTP site since it cannot be available for external parties anymore. Then the resource
        information is removed from CKAN.
        If the file is valid information (does not contain string 'empty') then the file is loaded on the FTP site.
        In both cases the size of the file and the url are calculated and handled: added to the database or removed
        from the database if filename contains 'empty'.
        Then the second group of files is handled: the metadata. The file is moved first. Then if the dataset exists
        on the Open Data platform and the string contains 'empty' or cijfersxml does not exist, then the update_package
        method is called to display the package as private on Open Data.
        Else (the dataset does not yet exist or cijfersxml does exist so a dataset package must be created) the
        load_metadata method is called.

        :return:
        """
        # Get ckan connection first
        scandir = self.config['Main']['scandir']
        handledir = self.config['Main']['handledir']
        log_msg = "Scan %s for files"
        logging.debug(log_msg, scandir)
        # Don't use os.listdir in for loop since I'll move files. For loop will get confused.
        # Extract filelist first for cijfersXML, cijfersTable or commentaar types. Cognos is also known as
        # resource type, but no files expected so no problem in leaving this.
        type_list = my_env.get_resource_types()
        filelist = [file for file in os.listdir(scandir) if my_env.type_from_file(file) in type_list]
        for file in filelist:
            log_msg = "Filename: %s"
            logging.debug(log_msg, file)
            my_env.move_file(file, scandir, handledir)  # Move file is done in separate function.
            if 'empty' in file:
                # remove_file handles paths, empty in filename, ...
                self.ftp.remove_file(file=file)
                # Strip empty from filename
                filename = re.sub('empty\.', '', file)
                indic_id = my_env.indic_from_file(filename)
                res_type = my_env.type_from_file(filename)
                attribute = "id_" + res_type
                self.ds.remove_indicator_attribute(indic_id, attribute)
            else:
                self.ftp.load_file(file=os.path.join(handledir, file))
            self.size_of_file(handledir, file)
            self.url_in_db(file)
        # Now handle meta-data
        filelist = [file for file in os.listdir(scandir) if 'metadata' in file]
        for file in filelist:
            # At least one update, so set flag for dcat_ap create. If any change then new metafile is required,
            # so no need to have create in block above.
            open(os.path.join(scandir, "dcat_ap_create"), 'w').close()
            log_msg = "Filename: %s"
            logging.debug(log_msg, file)
            my_env.move_file(file, scandir, handledir)  # Move file done in separate function.
            # Get indic_id before adding pathname to filename.
            indic_id = my_env.indic_from_file(file)
            filename = os.path.join(handledir, file)
            # Rework logic.
            # Remove bijsluiter from indicators table. It will be added if required.
            self.ds.remove_indicator_attribute(indic_id, "bijsluiter")
            # If cijfersxml does not exist or metadata file has empty string, then set package to private.
            if ('empty' in file) or (self.ds.get_indicator_value(indic_id, 'cijfersxml') == 'niet gevonden'):
                # Required and sufficient reason to set package to private.
                # For Harvester I can forget all about the package.
                self.ds.remove_indicator(indic_id)
            else:
                # Dataset package does not yet exist or new valid resource file available and cijfersxml exist.
                self.load_metadata(filename, indic_id)
        return
