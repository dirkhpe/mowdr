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
from CKANConnector import CKANConnector
from Datastore import Datatstore
from Ftp_Handler import Ftp_Handler
from lib import my_env


class FileHandler:
    def __init__(self, config):
        self.config = config
        self.ds = Datatstore(config)
        self.ckan = CKANConnector(self.config, self.ds)
        self.ftp = Ftp_Handler(self.config)

    def url_in_db(self, file):
        """
        Remove the url attribute for this resource.
        If file does not contain 'empty', then calculate URL the file and set result in indicators table.
        :param file:
        :return:
        """
        logging.debug('Add/Remove file %s to indicators table.', file)
        indic_id = my_env.indic_from_file(file)
        attribute = my_env.attr_from_file('url', file)
        # Always remove attribute for this indicator. Then no insert / update logic is required.
        self.ds.remove_indicator_attribute(indic_id, attribute)
        if 'empty' not in file:
            # Calculate URL
            ftp_home = self.config['FTPServer']['ftp_home']
            # Add FTP Subdirectory (if any)
            ftpdir = self.config['FTPServer']['dir']
            if len(ftpdir) > 0:
                dirname = ftpdir + '/'
            else:
                dirname = ''
            url = ftp_home + '/' + dirname + file
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
        Read the file with metadata and add or replace the information to table indicators. This procedure will populate
        all fields that come from the 'Dataroom'.
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
        indicatorname = ""
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
            # The 'title' field will be used for all Dataset and all resources and gets special threatment.
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
                              'description_cognos', 'format_cognos', 'tdt_cognos',
                              'bijsluiter',
                              'author_name', 'author_email', 'maintainer_name', 'maintainer_email',
                              'language']
        for add_attrib in additional_attribs:
            self.ds.insert_indicator(indic_id, add_attrib, self.config['OpenData'][add_attrib])

        # Now check if dataset exist already: is there an ID available in the indicators table for this indicator.
        values_lst = self.ds.get_indicator_value(indic_id, 'id')
        upd_pkg = "NOK"
        # I want to have 0 or 1 rows in the list
        if len(values_lst) == 0:
            log_msg = "Open Data dataset is not registered for Indicator ID %s, this should have been done"
            logging.error(log_msg, indic_id)
        elif len(values_lst) == 1:
            log_msg = "Open Data dataset exists for Indicator ID %s, no need to create nor to complain about too many"
            logging.info(log_msg, indic_id)
            upd_pkg = "OK"
        else:
            log_msg = "Multiple Open Data dataset links found for Indicator ID %s, please review"
            logging.warning(log_msg, indic_id)
        if upd_pkg == "OK":
            self.ckan.update_package(indic_id)
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
        Then the second group of files is handled: the metadata. The file is moved to first. Then if the dataset exists
        on the Open Data platform and the string contains 'empty' or cijfersxml does not exist, then the update_package
        method is called to display the package as private on Open Data.
        Else (the dataset does not yet exist or cijfersxml does exist so a dataset package mmust be created) the
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
            my_env.move_file(file, scandir, handledir)  # Move file done in own function, such a hassle...
            if 'empty' in file:
                # remove_file handles paths, empty in filename, ...
                self.ftp.remove_file(file=file)
                # Strip empty from filename
                filename = re.sub('empty\.', '', file)
                indic_id = my_env.indic_from_file(filename)
                res_type = my_env.type_from_file(filename)
                self.ckan.remove_resource(indic_id, res_type)
            else:
                self.ftp.load_file(file=os.path.join(handledir, file))
            self.size_of_file(handledir, file)
            self.url_in_db(file)
        # Now handle meta-data
        filelist = [file for file in os.listdir(scandir) if 'metadata' in file]
        for file in filelist:
            log_msg = "Filename: %s"
            logging.debug(log_msg, file)
            my_env.move_file(file, scandir, handledir)  # Move file done in own function, such a hassle...
            # Get indic_id before adding pathname to filename.
            indic_id = my_env.indic_from_file(file)
            filename = os.path.join(handledir, file)
            # Rework logic.
            # If dataset does not exist, then it needs to be created here (not in load_metadata)
            if not self.ckan.check_dataset(indic_id):
                self.ckan.create_package(indic_id)
            # If cijfersxml does not exist or metadata file has empty string, then set package to private.
            if 'empty' in file or not self.ckan.check_resource(indic_id, 'cijfersxml'):
                # Required and sufficient reason to set package to private.
                # I'm sure that package ID exist.
                values_lst = self.ds.get_indicator_value(indic_id, 'id')
                self.ckan.set_pkg_private(values_lst[0][0])
            else:
                # Dataset package does not yet exist or new valid resource file available and cijfersxml exist.
                self.load_metadata(filename, indic_id)
        return

    def add_cognos_resources(self):
        """
        This procedure will find all indicators for which Cognos report is available but resource is not published on
        Open Dataset.
        The Resource will be published on the Open Dataset.
        :return:
        """
        logging.debug("In add_cognos_resources")
        for indic_id in self.ds.get_indicator_cognos_urls():
            if not self.ds.check_resource_published(indic_id, "cognos"):
                logging.info("Cognos URL available, but not yet on Open Dataset for ID {0}".format(str(indic_id)))
                self.ckan.update_package(indic_id)
