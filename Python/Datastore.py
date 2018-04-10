#!/opt/csw/bin/python3

"""
This class consolidates functions related to the local datastore.
The local datastore contains 2 parts.
The attribute_action table understands all different fields, their source, destination and action (if applicable). The
attribute_action table is generic over all indicators.
The second part is the indicator table. This is the Open Data information related to the individual indicator. In a
future release, this indicator table should be replaced by the json information that is collected from the Open Data
website. This will remove the need to maintain data locally - on more that one place so more risk on errors.
An instance of the class will create a database handle and a cursor to the database.
"""

import logging
import sqlite3
import sys
from lib import my_env
from time import strftime


class Datastore:

    def __init__(self, config):
        """
        Method to instantiate the class in an object for the datastore.
        :param config object, to get connection parameters.
        :return: Object to handle datastore commands.
        """
        logging.debug("Initializing Datastore object")
        self.config = config
        self.dbConn, self.cur = self._connect2db()
        return

    def _connect2db(self):
        """
        Internal method to create a database connection and a cursor. This method is called during object
        initialization.
        Note that sqlite connection object does not test the Database connection. If database does not exist, this
        method will not fail. This is expected behaviour, since it will be called to create databases as well.
        :return: Database handle and cursor for the database.
        """
        logging.debug("Creating Datastore object and cursor")
        db = self.config['Main']['db']
        try:
            db_conn = sqlite3.connect(db)
        except:
            e = sys.exc_info()[1]
            ec = sys.exc_info()[0]
            log_msg = "Error during connect to database: %s %s"
            logging.error(log_msg, e, ec)
            return
        else:
            logging.debug("Datastore object and cursor are created")
            return db_conn, db_conn.cursor()

    def close_connection(self):
        """
        Method to close the Database Connection.
        :return:
        """
        logging.debug("Close connection to database")
        try:
            self.dbConn.close()
        except:
            e = sys.exc_info()[1]
            ec = sys.exc_info()[0]
            log_msg = "Error during close connect to database: %s %s"
            logging.error(log_msg, e, ec)
            return
        else:
            return

    def insert_indicator(self, indicator_id, attribute, value):
        """
        This method will insert a record in the indicators table. Date / Time of insert is calculated.
        :param indicator_id: ID of the indicator.
        :param attribute:  Attribute, this should be in attribute_action table (but not yet verified).
        :param value: related to the attribute.
        :return:
        """
        logging.debug("Remove then adding to indicator table ID: %s, Attribute: %s, Value: %s",
                      indicator_id, attribute, value)
        self.remove_indicator_attribute(indicator_id, attribute)
        now = strftime("%H:%M:%S %d-%m-%Y")
        query = "INSERT INTO indicators (indicator_id, attribute, value, created)" \
                "VALUES (?, ?, ?, ?)"
        self.dbConn.execute(query, (indicator_id, attribute, value, now))
        self.dbConn.commit()
        return

    def remove_indicator_attribute(self, indicator_id, attribute):
        """
        This method will remove the record for the indicator / attribute combination.

        :param indicator_id: ID of the indicator to be removed.

        :param attribute: Attribute related to the indicator.

        :return:
        """
        # TODO - Count number of records deleted.
        logging.debug("Removing from indicator table ID: %s, Attribute: %s", indicator_id, attribute)
        query = "DELETE FROM indicators WHERE indicator_id = ? AND attribute = ?"
        self.dbConn.execute(query, (indicator_id, attribute))
        self.dbConn.commit()
        return

    def get_extra_values(self, indic_id):
        """
        This method will collect all attributes with action 'Extra'. This information needs to go on the bijsluiter.

        :param indic_id:

        :return: dictionary with key attribute name and values.
        """
        query = """
            SELECT a.od_field, i.value
            FROM indicators AS i
            INNER JOIN attribute_action AS a
            ON a.attribute = i.attribute
            WHERE i.indicator_id = ?
            AND a.action = 'Extra'
            AND a.weight is not null
            ORDER BY a.weight
        """
        self.cur.execute(query, (indic_id, ))
        res = self.cur.fetchall()
        return res

    def get_indicator_value(self, indicator_id, attribute):
        """
        This method will get all values for attribute name and indicator ID in a list. Check with method
        'get_indicator_val' which will return result string, or 'niet gevonden' in case that result is not found.

        :param indicator_id:

        :param attribute: Name for which value is required.

        :return: Array of result lists. Each result list has one element, the required value. Empty list is returned if
        no values are found.
        """
        logging.debug("SELECT value FROM indicators WHERE indicator_id = %s and attribute = %s",
                      indicator_id, attribute)
        query = "SELECT value FROM indicators WHERE indicator_id = ? and attribute = ?"
        self.cur.execute(query, (indicator_id, attribute))
        values_lst = self.cur.fetchall()
        return values_lst

    def get_indicator_val(self, indicator_id, attribute):
        """
        This method will get the value for attribute name and indicator ID. Check with method 'get_indicator_value',
        which will return result array.

        :param indicator_id:

        :param attribute: Name for which value is required.

        :return: result string or 'niet gevonden'.
        """
        values_lst = self.get_indicator_value(indicator_id, attribute)
        if values_lst:
            res_str = values_lst[0][0]
        else:
            res_str = 'niet gevonden'
        return res_str

    def get_indicator_attrib_values(self, indicator_id, attribs):
        """
        This method gets an indicator ID and a list of attribute names. It will collect all values for available in
        indicator table for each of the attributes.

        :param indicator_id:

        :param attribs:

        :return: Array of (attribute, value) lists.
        """
        logging.debug("Get attribute/value pairs for indicator %s", indicator_id)
        query = "SELECT attribute, value FROM indicators WHERE indicator_id = ? AND attribute IN " + str(tuple(attribs))
        logging.debug("Query: %s", query)
        self.cur.execute(query, (indicator_id,))
        res = self.cur.fetchall()
        return res

    def get_indicator_ids(self):
        """
        This method will get all indicator IDs for indicators that are published for public on the Open Data Set. This
        is done by checking all distinct indicatorIDs for which an url_cijfersxml entry exists in the indicators table.

        :return: List of indicator IDs.
        """
        query = "SELECT distinct indicator_id FROM indicators WHERE attribute = 'url_cijfersxml'"
        logging.debug("Query: %s", query)
        self.cur.execute(query)
        res = self.cur.fetchall()
        indic_array = [indic_id[0] for indic_id in res]
        return indic_array

    def get_indicator_cognos_urls(self):
        """
        This method will get all indicator IDs for indicators that have a Cognos URL available (url_cognos exist).
        :return: List of indicator IDs with Cognos URL.
        """
        query = "SELECT distinct indicator_id FROM indicators WHERE attribute = 'url_cognos'"
        logging.debug("Query: %s", query)
        self.cur.execute(query)
        res = self.cur.fetchall()
        indic_array = [indic_id[0] for indic_id in res]
        return indic_array

    def check_resource(self, indic_id, res_type):
        """
        This procedure will check if the resource URL is available. If URL is available then resource can be
        created/updated.
        This procedure will be called with resource type 'cijfersxml' to decide if package is public or private.
        (This used to be a method of CKANConnector.py, but moved to Datastore.py since it will be called from
        Evaluate_Cognos.py and this script wants to avoid loading of the ckanapi.)
        Compare with check_resource_id, that will verify if a resource is published on Open Dataset.
        :param indic_id: Indicator ID.
        :param res_type: Resource Type for which URL is searched.
        :return: True if the URL for the resource on Repository server is available in indicator table. False otherwise.
        """
        attribute = "url_" + res_type
        res = self.get_indicator_value(indic_id, attribute)
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

    def check_resource_published(self, indic_id, res_type):
        """
        This procedure will check if the resource is published on Open Dataset. A resource is published on Open Dataset
        if the resource id (id_cognos, id_cijfersxml, ...) exists in the indicators table.
        Compare with check_resource, that will verify if the resource exists.
        :param indic_id: Indicator ID.
        :param res_type: Resource Type for which ID is searched.
        :return: True if the ID for the resource on Repository server is available in indicator table. False otherwise.
        """
        attribute = "id_" + res_type
        res = self.get_indicator_value(indic_id, attribute)
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

    def get_attribs_source(self, source):
        """
        This method collects all attributes for a specific source.
        :param source: Value of the source parameter
        :return: Array of result lists. Each result list has one element: the attribute name.
        """
        logging.debug("SELECT attribute FROM attribute_action WHERE source = '%s'",
                      source)
        query = "SELECT attribute FROM attribute_action WHERE source = ?"
        self.cur.execute(query, (source, ))
        attribs = self.cur.fetchall()
        return attribs

    def get_attrib_od_pairs(self, source, target, action):
        """
        This method returns the pairs (attribute_name, Open Data name) for all attributes from a specific action.
        Input parameters can be string or arrays. The query will check for all values in the array.

        :param source: Source for the attribute / Open data pairs

        :param target: Target for the attribute / Open data pairs

        :param action: The action field.

        :return: Array of (unique attribute name, Open Data name) lists.
        """
        source = my_env.get_array(source)
        target = my_env.get_array(target)
        action = my_env.get_array(action)
        query = "SELECT attribute, od_field FROM attribute_action " \
                "WHERE source IN " + source + " AND target IN " + target + " AND action IN " + action
        logging.debug("Query: %s", query)
        self.cur.execute(query)
        res = self.cur.fetchall()
        return res

    def get_all_attribs(self):
        """
        This method collects all attributes.

        :return: Array of attributes.
        """
        query = "SELECT attribute FROM attribute_action"
        logging.debug(query)
        self.cur.execute(query)
        attribs = self.cur.fetchall()
        attrib_array = [attrib[0] for attrib in attribs]
        return attrib_array

    def insert_attribute(self, **params):
        """
        This method will insert a record in the attribute_action table. Date / Time of insert is calculated.

        :param params: Dictionary with keys attribute, od_field, action, source, target

        :return:
        """
        logging.debug("Remove attribute, then add to attribute_action table attribute: {a}, od_field: {o}"
                      .format(a=params["attribute"], o=params["od_field"]))
        self.remove_attribute(params["attribute"])
        now = strftime("%H:%M:%S %d-%m-%Y")
        query = "INSERT INTO attribute_action (attribute, od_field, source, target, action, created)" \
                "VALUES (?, ?, ?, ?, ?, ?)"
        self.dbConn.execute(query, (params["attribute"], params["od_field"], params["source"],
                                    params["target"], params["action"], now))
        self.dbConn.commit()
        return

    def update_attribute(self, attribute, od_field):
        """
        This method will update the attribute in attribute_action with the od_field specified.
        :param attribute:
        :param od_field:
        :return:
        """
        logging.debug("Update attribute_action table - Attribute: %s, OD Field: %s", attribute, od_field)
        query = "UPDATE attribute_action SET od_field = ? WHERE attribute = ?"
        self.dbConn.execute(query, (od_field, attribute))
        self.dbConn.commit()
        return

    def remove_attribute(self, attribute):
        """
        This method will remove the attribute from attribute_action.
        :param attribute:
        :return:
        """
        logging.debug("Delete attribute %s from attribute_action table.", attribute)
        query = "DELETE FROM attribute_action WHERE attribute = ?"
        self.dbConn.execute(query, (attribute, ))
        self.dbConn.commit()
        return

    def remove_indicator(self, indic_id):
        """
        This method will remove all information from an indicator in the indicator table.

        :param indic_id: Indicator ID that needs to be removed

        :return:
        """
        query = "DELETE FROM indicators WHERE indicator_id = ?"
        self.dbConn.execute(query, (indic_id, ))
        self.dbConn.commit()
        return

    def db_consistency(self):
        """
        Purpose of this method is to check database consistency. Check that each attribute name in indicators
        table need to show up in attribute_action table.
        Then check if attributes in attribute_action table occur more than once.
        :return:
        """
        query = "SELECT distinct attribute FROM indicators"
        logging.debug('Query: %s', query)
        self.cur.execute(query)
        res = self.cur.fetchall()
        query = "SELECT attribute FROM attribute_action WHERE attribute = ?"
        for att_row in res:
            attribute = att_row[0]
            logging.debug("Now investigating: %s", attribute)
            self.cur.execute(query, (attribute,))
            res = self.cur.fetchall()
            if len(res) > 1:
                msg = "Attribute " + attribute + " in indicators table, multiple times in attribute_action."
            elif len(res) < 1:
                msg = "Attribute " + attribute + " in indicators table, not in attribute_action table."
            else:
                msg = ""
            if len(msg) > 0:
                print(msg)
                logging.error(msg)
        query = "SELECT count(*) as cnt, attribute from attribute_action " \
                "group by attribute " \
                "having cnt > 1 " \
                "order by cnt desc"
        self.cur.execute(query)
        res = self.cur.fetchall()
        for cnt, att in res:
            msg = "Attribute " + att + " occurs " + str(cnt) + " times in attribute_action Table"
            print(msg)
            logging.error(msg)
        return
