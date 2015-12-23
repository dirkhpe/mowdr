#!/opt/csw/bin/python3

import logging
import sys
import ckanapi
from lib import my_env


class CKANConnector:
    def __init__(self, config, datastore):
        self.config = config
        self.ds = datastore
        self.ckan_conn = self._connect()
        return

    def _connect(self):
        """
        Internal method to configure the connection to ckan Open Data Platform.
        :return: ckan connected object.
        """
        logging.debug("Setup connection to ckan Server")
        url = self.config['CKANServer']['url']
        api = self.config['CKANServer']['api']
        try:
            ckan_conn = ckanapi.RemoteCKAN(url, apikey=api)
        except:
            e = sys.exc_info()[1]
            ec = sys.exc_info()[0]
            log_msg = "Connect to RemoteCKAN not successful %s %s"
            logging.critical(log_msg, e, ec)
            sys.exit(1)
        return ckan_conn

    def create_package(self, indic_id):
        """
        This method will create a brand new Dataset on Open Data platform. The package is created with minimal
        parameters: only the name, title, license ID and owner organization are provided. These are the mandatory
        parameters to create a package. The ID of the created package is stored in the indicator table.
        :param indic_id:
        :return:
        """
        log_msg = "In create_package for Indicator %s"
        logging.debug(log_msg, indic_id)
        # Get mandatory items for the package: Title,name and owner_org
        title_list = self.ds.get_indicator_value(indic_id, 'title')
        # I need to have exact 1 title
        if len(title_list) == 0:
            log_msg = "No Title defined for Indicator ID %s, using 'Indicator %s' instead."
            logging.error(log_msg, indic_id, indic_id)
            title = "Indicator" + str(indic_id) + " (name still to be defined)."
        elif len(title_list) == 1:
            title = title_list[0][0]
        else:
            log_msg = "Multiple titles (?) defined for Indicator ID %s"
            logging.error(log_msg, len(title_list), indic_id)
            # return False
        # OK, 1 title found. Convert it to a name
        name = my_env.get_name_from_indic(self.config, indic_id)
        logging.info("Name: %s", name)
        # Other fixed param values are added to indicator table first.
        # Todo - consistent approach of fixed param values. This seems to be best approach.
        # On second thought, the trick with indicator table may be easier since it allows more automation.
        # Name, title, owner_org and license_id are the mandatory parameters to create a package.
        my_param = {
            'name': name,
            'title': title,
            'owner_org': self.config['OpenData']['owner_org'],
            'license_id': self.config['OpenData']['license_id'],
        }
        logging.debug("Parameters: %s", my_param)
        try:
            pkg = self.ckan_conn.action.package_create(**my_param)
        except:
            e = sys.exc_info()[1]
            ec = sys.exc_info()[0]
            log_msg = "Package Create not successful %s %s"
            logging.error(log_msg, e, ec)
            return False
        else:
            # Collect Package information and set it in the database.
            pkg_attrib = 'id'
            try:
                val_id = pkg[pkg_attrib]
            except:
                log_msg = "Create package with no errors, but no package ID found..."
                logging.error(log_msg)
                return False
            else:
                # Store package ID in indicators table
                self.ds.insert_indicator(indic_id, pkg_attrib, val_id)
                log_msg = 'Looks like I have my package...'
                logging.info(log_msg)
        log_msg = "End of create_package processing for Indicator %s"
        logging.info(log_msg, indic_id)
        return True

    def update_package(self, indic_id):
        """
        This procedure will update Package information for the indicator ID.
        :param indic_id:
        :return:
        """
        log_msg = "Update Package for Indicator %s"
        logging.info(log_msg, indic_id)
        # Get Open Data ID of the package
        res = self.ds.get_indicator_value(indic_id, 'id')
        dataset_id = res[0][0]  # Remember ID of the package in params dictionary. First element in first array is id.
        logging.debug("Dataset ID: %s", dataset_id)
        # First check if there is a 'cijfersXML' URL available.
        # If not, then set dataset to private.
        if self.check_resource(indic_id, 'cijfersxml'):
            self.set_pkg_public(indic_id, dataset_id)
        else:
            self.set_pkg_private(dataset_id)

    def set_pkg_private(self, dataset_id):
        """
        This indicator does not have a cijfersxml file associated or metadata filename has empty, set it to 'private'.
        :param dataset_id: ID of the dataset on Open Data platform.
        :return:
        """
        params = {
            'id': dataset_id,
            'private': True,
        }
        log_msg = "Trying to update package with params %s"
        logging.debug(log_msg, params)
        try:
            pkg = self.ckan_conn.action.package_patch(**params)
        except:
            e = sys.exc_info()[1]
            ec = sys.exc_info()[0]
            log_msg = "Package Update not successful %s %s"
            logging.error(log_msg, e, ec)
        else:
            log_msg = "Package Update successful %s"
            logging.info(log_msg, pkg)
        return

    def set_pkg_public(self, indic_id, dataset_id):
        """
        This Indicator has a cijfer file available, so dataset can be published as Public on Open Data Platform.
        :param indic_id: Indicator ID
        :param dataset_id: ID of dataset on Open Data platform.
        :return:
        """
        logging.debug("Setting package for indicator " + str(indic_id) + " public.")
        params = {
            'id': dataset_id,
            'private': False,
        }
        # First get attribute names and related open data field name for 'Extra' fields
        source = 'Dataroom'
        target = 'Dataset'
        action = 'Extra'
        res = self.ds.get_attrib_od_pairs(source, target, action)
        # Remember the attribute - od_field translation
        od_field = {}
        for [k, v] in res:
            od_field[k] = v
        # Then get values for the attribute names
        # Collect all unique attribute names in array attribs first.
        attribs = [res[i][0] for i in range(len(res))]
        # For all attribute names find corresponding value in indicators table
        res = self.ds.get_indicator_attrib_values(indic_id, attribs)
        extra_arr = []
        for [k, v] in res:
            attrib_dict = {
                'key': od_field[k],  # Use human readable label as key
                'value': v
            }
            extra_arr.append(attrib_dict)
        # Add extras dictionary to params dictionary
        params['extras'] = extra_arr
        # Then get attribute names for Main fields
        action = 'Main'
        res = self.ds.get_attrib_od_pairs(source, target, action)
        # Remember the attribute - od_field translation for Main field
        od_field = {}
        for [k, v] in res:
            od_field[k] = v
        # Then get values for the Main attribute names
        attribs = [res[i][0] for i in range(len(res))]
        # With attribute names, find corresponding values in indicators table
        res = self.ds.get_indicator_attrib_values(indic_id, attribs)
        # Add the values to params dictionary
        for [k, v] in res:
            params[od_field[k]] = v
        log_msg = "Trying to update package with params %s"
        logging.debug(log_msg, params)
        try:
            self.ckan_conn.action.package_patch(**params)
        except:
            e = sys.exc_info()[1]
            ec = sys.exc_info()[0]
            log_msg = "Package Update not successful %s %s"
            logging.error(log_msg, e, ec)
            return
        log_msg = "Package Update successful for indicator ID %s, now update resources."
        logging.info(log_msg, indic_id)
        # Check all resource types
        # I know for sure that the cijfersXML_ind.xml is on the FTP server, so check will always return TRUE.
        res_types = my_env.get_resource_types()
        for res_type in res_types:
            if self.check_resource(indic_id, res_type):
                self.manage_resource(indic_id, dataset_id, res_type)
        return

    def check_dataset(self, indic_id):
        """
        This method will check if the dataset exists. A dataset exists if an ID is found in the indicator table and if
        the package exists on Open Data for this ID. Checking of Open Data is not yet implemented.
        :param indic_id:
        :return:
        """
        values_lst = self.ds.get_indicator_value(indic_id, 'id')
        # I want to have 0 or 1 rows in the list
        if len(values_lst) == 0:
            # No reply, Dataset does not yet exist.
            return False
        elif len(values_lst) == 1:
            # 1 return ID
            return True
        else:
            msg = "Found multiple IDs for this indicator: " + str(len(values_lst))
            logging.warning(msg)
            return True


    def check_resource(self, indic_id, res_type):
        """
        This procedure will check if the resource URL is available.
        If URL is available then resource needs to be created/updated.
        This procedure will be called with resource type 'cijfersxml' to decide if package is public or private.
        (This could be method of Datastore.py)
        :param indic_id: Indicator ID.
        :param res_type: Resource Type for which URL is searched.
        :return: True if the URL for the resource on Repository server is available in indicator table. False otherwise.
        """
        # TODO: This method is now available on Datastore.py. Remove from class CKANConnector.py.
        attribute = "url_" + res_type
        res = self.ds.get_indicator_value(indic_id, attribute)
        log_msg = "Check for Resource %s, Result: %s"
        logging.debug(log_msg, res_type, res)
        if len(res) == 0:
            return False
        elif len(res) == 1:
            return True
        else:
            log_msg = "Unexpected number of URLs found for Resource %s and indicator ID %s"
            logging.error(log_msg, res_type, indic_id)
            return False

    def manage_resource(self, indic_id, dataset_id, res_type):
        """
        This function will manage the resource patch. Check if cijfer resource or commentaar resource needs to be
        created or updated.
        A resource needs to have resource ID in table indicators - then it will be updated.
        If there is no entry in the indicators table for the resource ID, then the resource will be created.
        :param indic_id: Indicator ID that is currently being processed.
        :param dataset_id: Package ID of the package that is currently handled.
        :param res_type: Type of the resource.
        :return: nothing
        """
        logging.debug("Managing resource: " + str(indic_id) + " for package " + str(dataset_id))
        params = {
            'package_id': dataset_id,
        }
        # Collect data fields for resource
        # First get attribute names for Resource from Dataroom
        source = ['Dataroom', 'Repository']
        target = my_env.get_target(res_type)
        action = 'Resource'
        res = self.ds.get_attrib_od_pairs(source, target, action)
        # Remember the attribute - od_field translation for Main field
        od_field = {}
        for [k, v] in res:
            od_field[k] = v
        # Then get values for these Resource attribute names
        attribs = [res[i][0] for i in range(len(res))]
        # With attribute names, find corresponding values in indicators table
        res = self.ds.get_indicator_attrib_values(indic_id, attribs)
        # Add the values with Open Data Keys to params dictionary
        for [k, v] in res:
            params[od_field[k]] = v
        # Now check if this is a new resource or an update for a resource
        id_name = "id_" + res_type
        res = self.ds.get_indicator_value(indic_id, id_name)
        log_msg = "Result for id_name %s: %s"
        logging.debug(log_msg, id_name, res)
        log_msg = "Length: %s"
        logging.debug(log_msg, len(res))
        if len(res) == 0:
            # Resource_Create
            self.create_resource(indic_id, params, res_type)
        elif len(res) == 1:
            # Check if resource still exists. In case of Cognos, resource can be removed
            resource_id = res[0][0]
            if self.verify_resource(resource_id):
                params['id'] = res[0][0]  # Resource ID exists.
                self.update_resource(indic_id, params)
            else:
                self.create_resource(indic_id, params, res_type)   # Resource didn't exist, remove...
        else:
            log_msg = "Unexpected number of Resource record IDs for indicator ID %s and resource %s"
            logging.error(log_msg, indic_id, res_type)
        return

    def create_resource(self, indic_id, params, res_type):
        """
        This procedure will create a resource.
        :param indic_id: indicator ID.
        :param params: Array of attribute / values or dictionaries to load in the resource.
        :return:
        """
        logging.debug("Trying to create resource, parameters: %s (type: %s)", params, res_type)
        try:
            pkg = self.ckan_conn.action.resource_create(**params)
        except:
            e = sys.exc_info()[1]
            ec = sys.exc_info()[0]
            log_msg = "Resource Create not successful %s %s"
            logging.error(log_msg, e, ec)
            return
        log_msg = "Resource has been created: %s, Update info for Indicator: %s"
        logging.debug(log_msg, pkg, indic_id)
        # Collect Resource information and set it in the database.
        try:
            val_id = pkg['id']
        except:
            log_msg = "Create resource with no errors, but no package ID found..."
            logging.error(log_msg)
            return
        else:
            # Store resource ID in indicators table
            attribute = "id_" + res_type
            self.ds.insert_indicator(indic_id, attribute, val_id)
        log_msg = 'Looks like I have my %s Resource...'
        logging.info(log_msg, res_type)
        return

    def update_resource(self, indic_id, params):
        """
        This procedure will update an existing resource.
        No need to specify cijfersXML / cijfersTable / commentaar / cognos resource type.
        :param indic_id: indicator ID.
        :param params: Array of attribute / values or dictionaries to load.
        :return:
        """
        logging.debug("Trying to update resource, parameters: %s", params)
        try:
            pkg = self.ckan_conn.action.resource_patch(**params)
        except:
            e = sys.exc_info()[1]
            ec = sys.exc_info()[0]
            log_msg = "Resource Update not successful %s %s"
            logging.error(log_msg, e, ec)
            return
        log_msg = "Resource has been updated: %s, Update info for Indicator: %s"
        logging.debug(log_msg, pkg, indic_id)
        # Test if resource_id from updated package is same as original resource_id.
        if pkg['id'] == params['id']:
            logging.debug("Resource ID returned same as ID sent.")
        else:
            logging.error("Resource ID returned different from ID sent")

    def remove_resource(self, indic_id, res_type):
        """
        This procedure knows that resource URL does not exist. If there is a resource on Open Data platform, then
        remove this resource. A resource on Open Data Platform exists if the resource ID (e.g. id_cijfersxml) exists
        in the indicator table.
        :param indic_id: Indicator ID.
        :param res_type: Resource Type of the resource that needs to be removed.
        :return:
        """
        attribute = "id_" + res_type
        res = self.ds.get_indicator_value(indic_id, attribute)
        log_msg = "Removing resource %s check, Result: %s"
        logging.debug(log_msg, res_type, res)
        if len(res) == 0:
            # OK, resource does not exist, no further action.
            return
        elif len(res) > 1:
            log_msg = "Unexpected number of URLs found for Resource %s and indicator ID %s, I'll remove them all."
            logging.error(log_msg, res_type, indic_id)
        for row in res:
            params = {
                'id': row[0],
            }
            try:
                pkg = self.ckan_conn.action.resource_delete(**params)
            except:
                e = sys.exc_info()[1]
                ec = sys.exc_info()[0]
                log_msg = "Resource Delete not successful %s %s"
                logging.error(log_msg, e, ec)
            else:
                log_msg = "Resource has been deleted: %s for Indicator: %s"
                logging.debug(log_msg, pkg, indic_id)
            # Remove all id_resource entries
            self.ds.remove_indicator_attribute(indic_id, attribute)
        return

    def verify_resource(self, res_id):
        """
        This method will check if a resource exists before trying to update the resource.
        :param res_id:
        :return:
        """
        try:
            self.ckan_conn.action.resource_show(id=res_id, include_tracking=1)
        except ckanapi.NotFound:
            msg = "Resource " + str(res_id) + " not found."
            logging.debug(msg)
        except:
            e = sys.exc_info()[1]
            ec = sys.exc_info()[0]
            log_msg = "Resource Delete not successful %s %s"
            logging.error(log_msg, e, ec)
            return False
        else:
            return True
