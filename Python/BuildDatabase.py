#!/opt/csw/bin/python3

"""
This script will rebuild the database from scratch. It should run only once during production
and many times during development.
"""

import logging
from Datastore import Datatstore
from lib import my_env

def create_db():
    # Create table
    query = 'CREATE TABLE attribute_action ' \
            '(id integer primary key, attribute text unique, od_field text, ' \
            'action text, source text, target text, created text)'
    try:
        conn.execute(query)
    except:
        e = sys.exc_info()[1]
        ec = sys.exc_info()[0]
        log_msg = "Error during query execution - Attribute_action: %s %s"
        logging.error(log_msg, e, ec)
        return
    query = 'CREATE TABLE indicators ' \
            '(id integer primary key, indicator_id integer, attribute text, ' \
            'value text, created text, ' \
            'FOREIGN KEY(attribute) REFERENCES attribute_action(attribute))'
    try:
        conn.execute(query)
    except:
        e = sys.exc_info()[1]
        ec = sys.exc_info()[0]
        log_msg = "Error during query execution - Indicators: %s %s"
        logging.error(log_msg, e, ec)
        return
    return True


def remove_tables():
    query = 'DROP TABLE IF EXISTS indicators'
    try:
        conn.execute(query)
    except:
        e = sys.exc_info()[1]
        ec = sys.exc_info()[0]
        log_msg = "Error during query execution: %s %s"
        logging.error(log_msg, e, ec)
        return
    query = 'DROP TABLE IF EXISTS attribute_action'
    try:
        conn.execute(query)
    except:
        e = sys.exc_info()[1]
        ec = sys.exc_info()[0]
        log_msg = "Error during query execution: %s %s"
        logging.error(log_msg, e, ec)
        return


def handle_attributes(source, target, action, attrib_dict):
    """
    This method gets a set of values for the attribute_action table.
    The method will collect all attribute records for this source - target - action triple.
    Then for each attribute in the attrib_dict the method will check if the record exists in attribute_action table.
    If so, no further action.
    If not then the record will be added.
    When all attributes are handled then the source-target-action attributes that were not requested for load but are in
    the table will be removed from the attribute_action table.
    :param source:
    :param target:
    :param action:
    :param attrib_dict: Dictionary with unique attribute name and Open Data name.
    :return:
    """
    msg = "Source: " + source + " - Target: " + target + " - Action: " + action
    print(msg)
    logging.debug(msg)
    # First get all pairs from attribute_action table for this source - target - action.
    in_action_tbl = ds.get_attrib_od_pairs(source, target, action)
    # Convert result in dictionary - Duplicate attributes will be hidden in dictionary, so check before on duplicates.
    curr_attrib_dict = {}
    for (attrib, od) in in_action_tbl:
        curr_attrib_dict[attrib] = od
    # Get attributes that are not in table now
    new_attribs = [attrib for attrib in attrib_dict.keys() if attrib not in curr_attrib_dict.keys()]
    msg = "New attributes: " + str(new_attribs)
    logging.debug(msg)
    print(msg)
    for attrib in new_attribs:
        ds.insert_attribute(attrib, attrib_dict[attrib], source, target, action)
    # Get attributes that are no longer required in table
    remove_attribs = [attrib for attrib in curr_attrib_dict.keys() if attrib not in attrib_dict.keys()]
    msg = "Remove attributes: " + str(remove_attribs)
    logging.debug(msg)
    print(msg)
    for attrib in remove_attribs:
        ds.remove_attribute(attrib)
    # Existing attributes, check Open Data field
    existing_attribs = [attrib for attrib in attrib_dict.keys() if attrib in curr_attrib_dict.keys()]
    od_field_update = [attrib for attrib in existing_attribs if attrib_dict[attrib] != curr_attrib_dict[attrib]]
    msg = "Existing attributes but Open Data field needs an update: " + str(od_field_update)
    logging.debug(msg)
    print(msg)
    for attrib in od_field_update:
        ds.update_attribute(attrib, attrib_dict[attrib])
    return


def populate_attribs_main():
    """
    This procedure will populate table attribute_action with the attributes that come from Dataroom
    and need to go to Dataset Metadata screen, Main.
    :return:
    """
    source = 'Dataroom'
    target = 'Dataset'
    action = 'Main'
    attrib_od_fields = {
        'title': 'title',
        'notes': 'notes',
        'author_name': 'author',
        'author_email': 'author_email',
        'maintainer_name': 'maintainer',
        'maintainer_email': 'maintainer_email',
        'language': 'language',
        'bijsluiter': 'url',
    }
    handle_attributes(source, target, action, attrib_od_fields)
    return


def populate_attribs_extra():
    """
    This procedure will populate table attribute_action with the attributes that come from Dataroom
    and need to go to Dataset Metadata screen, section 'Extra Informatie'.
    Note that it is mandatory that attribute name is unique.
    :return:
    """
    source = 'Dataroom'
    target = 'Dataset'
    action = 'Extra'
    attrib_od_fields = {
        'AantalPercentage': 'Aantal of Percentage',
        'Berekeningswijze': 'Berekeningswijze',
        'Definitie': 'Definitie',
        'Dimensies': 'Dimensies',
        'DoelMeting': 'Doel Meting',
        'Meeteenheid': 'Meeteenheid',
        'Meetfrequentie': 'Meetfrequentie',
        'Meettechniek': 'Meettechniek',
        'Tijdsvenster': 'Tijdsvenster',
        'TypeIndicator': 'Type Indicator',
        'FicheBijgewerkt': 'Gegevens Bijgewerkt',
        'CijfersBijgewerkt': 'Cijfers Bijgewerkt',
        'CommBijgewerkt': 'Commentaar Bijgewerkt',
    }
    handle_attributes(source, target, action, attrib_od_fields)
    return


def populate_attribs_main_ckan():
    """
    This procedure will populate table attribute_action with the attributes that come from ckan Open Data
    platform. Attributes name and license_id are a bit dubious here.
    :return:
    """
    source = 'Dataset'
    target = 'Dataset'
    action = 'Main'
    attrib_od_fields = {
        'id': 'id',
        'revision_id': 'revision_id',
        'name': 'name',
        'license_id': 'license_id'
    }
    handle_attributes(source, target, action, attrib_od_fields)
    return


def populate_attribs_resource(resource):
    """
    This procedure will populate table attribute_action with the attributes that come from Dataroom and need to go to
    the resource.
    Resources.
    :return:
    """
    source = 'Dataroom'
    target = my_env.get_target(resource)
    action = 'Resource'
    attrib_od_fields = {
        'format': 'format',
        'name': 'name',
        'description': 'description',
        'tdt': 'enable-tdt',
    }
    populate_attribs_from_resource(source, target, action, attrib_od_fields, resource)
    return


def populate_attribs_od_res(resource):
    """
    This procedure will populate table attribute_action with the attributes that come from Dataset to populate Resource.
    :return:
    """
    source = 'Dataset'
    target = my_env.get_target(resource)
    action = 'Resource'
    attrib_od_fields = {
        'id': 'id',
    }
    populate_attribs_from_resource(source, target, action, attrib_od_fields, resource)
    return


def populate_attribs_mv(resource):
    """
    This procedure will populate table attribute_action with the attributes that come from Mobiel Vlaanderen
    platform.
    :return:
    """
    source = 'Repository'
    target = my_env.get_target(resource)
    action = 'Resource'
    attrib_od_fields = {
        'url': 'url',
    }
    populate_attribs_from_resource(source, target, action, attrib_od_fields, resource)
    return


def populate_attribs_mv_file(resource):
    """
    This procedure will populate table attribute_action with the attributes that come from Mobiel Vlaanderen
    platform and a file is available.
    :return:
    """
    source = 'Repository'
    target = my_env.get_target(resource)
    action = 'FileResource'
    attrib_od_fields = {
        'size': 'Aantal Bytes',
    }
    populate_attribs_from_resource(source, target, action, attrib_od_fields, resource)
    return


def populate_attribs_from_resource(source, target, action, attrib_od_fields, resource):
    """
    This procedure will convert key values of dictionary attrib_od_fields to the key values for the resource, then load
    the fields in the table as specified.
    :param source:
    :param target:
    :param action:
    :param attrib_od_fields: Dictionary with generic attribute name, resource name to be added, and Open Data name.
    :return
    """
    # Create new array with attribute and resource fields
    attrib_res_fields = {}
    for key in attrib_od_fields.keys():
        new_key = key + "_" + resource
        attrib_res_fields[new_key] = attrib_od_fields[key]
    handle_attributes(source, target, action, attrib_res_fields)
    return


# Initialize Environment
projectname = "mowdr"
modulename = my_env.get_modulename(__file__)
config = my_env.get_inifile(projectname)
my_env.init_logfile(config, modulename)
ds = Datatstore(config)
logging.info('\n\n\nStart Application')
# all_attribs = ds.get_all_attribs()
logging.info("Handle Main Attributes on Dataset")
populate_attribs_main()
logging.info("Handle Extra Attributes on Dataset")
populate_attribs_extra()
logging.info("Handle Main Attributes that are populated from ckan")
populate_attribs_main_ckan()
resources = my_env.get_resource_types()
resource_files = my_env.get_resource_type_file()
for resource_name in resources:
    logging.info("Handle Resource Attributes for resource %s", resource_name)
    populate_attribs_resource(resource_name)
    logging.info("Handle Resource Attributes for resource %s from Open Data", resource_name)
    populate_attribs_od_res(resource_name)
    logging.info("Handle Resource Attributes for resource %s from Repository", resource_name)
    populate_attribs_mv(resource_name)
    if resource_name in resource_files:
        logging.info("Handle Resource Attributes for resource %s from Repository (File)", resource_name)
        populate_attribs_mv_file(resource_name)
logging.info('End Application')
