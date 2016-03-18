"""
This script will create a dcat_ap catalog file for the MOW Dataroom Open Data.
"""

from Datastore import Datastore
from datetime import datetime
from Ftp_Handler import Ftp_Handler
from lib import my_env
from xml.etree.ElementTree import ElementTree, Element, SubElement


# Initialize Environment
projectname = "mowdr"
modulename = my_env.get_modulename(__file__)
config = my_env.get_inifile(projectname, __file__)
my_log = my_env.init_loghandler(config, modulename)
my_log.info('Start Application')
ds = Datastore(config)
store = config['xmlns']['store']
lang = {'xml:lang': 'nl'}


# Define URI's for resources
catalog_uri = store + 'dr_catalog'
publ_uri = store + 'organisatie'    # Publisher
contact_uri = store + 'contact'     # ContactPoint


def get_license(el):
    """
    This method will add the license resource to the specified element
    :param el: element to which the license resource need to be added
    :return lic_res: License Resource object
    """
    lic_dict = {'rdf:resource': config['dcat_ap']['license_res']}
    lic_res = SubElement(el, 'dcterms:license', **lic_dict)
    return lic_res


def get_publisher(el):
    """
    This method will add the publisher resource to the specified element
    :param el: element to which the publisher resource need to be added
    :return publ_res: Publisher Resource object
    """
    publ_dict = {'rdf:resource': publ_uri}
    publ_res = SubElement(el, 'dcterms:publisher', **publ_dict)
    return publ_res


def get_contactpoint(el):
    """
    This method will add the contactPoint resource to the specified element
    :param el: element to which the contactPoint resource need to be added
    :return contact_res: ContactPoint Resource object
    """
    contact_dict = {'rdf:resource': contact_uri}
    contact_res = SubElement(el, 'dcat:contactPoint', **contact_dict)
    return contact_res


def get_language(el):
    """
    This method will add the language resource to the specified element
    :param el: element to which the language resource need to be added
    :return lang_res: Language Resource object
    """
    lang_uri = config['dcat_ap']['language_uri']
    lang_dict = {'rdf:resource': lang_uri}
    lang_res = SubElement(el, 'dcterms:language', **lang_dict)
    return lang_res


# Get xmlns Name Space variables from the config file.
xmlns_config = config['xmlns']
xmlns_hash = {}
for k in xmlns_config:
    xmlns_hash['xmlns:'+k] = xmlns_config[k]

# Initialize dcat_ap object
root = Element('rdf:RDF', **xmlns_hash)

# Create catalog object in the profile
catalog_obj = SubElement(root, 'dcat:Catalog', attrib={'rdf:about': catalog_uri})
# Add catalog attributes
catalog_title = SubElement(catalog_obj, 'dcterms:title', **lang)
catalog_title.text = config['dcat_ap']['catalog_title']
catalog_desc = SubElement(catalog_obj, 'dcterms:description', **lang)
catalog_desc.text = config['dcat_ap']['catalog_desc']
catalog_issued = SubElement(catalog_obj, 'dcterms:issued', attrib={'dcterms:date': config['dcat_ap']['catalog_issued']})
curr_date = datetime.now().strftime("%Y-%m-%d")
catalog_modified = SubElement(catalog_obj, 'dcterms:modified', attrib={'dcterms:date': curr_date})
catalog_lic = get_license(catalog_obj)
catalog_publ = get_publisher(catalog_obj)
catalog_lang = get_language(catalog_obj)

# Create Publisher object in the profile
publ_obj = SubElement(root, 'foaf:Agent', attrib={'rdf:about': publ_uri})
publ_name = SubElement(publ_obj, 'foaf:name')
publ_name.text = config['dcat_ap']['publ_name']
publ_type = SubElement(publ_obj, 'dcterms:type')
publ_type.text = 'organization'

# Create the ContactPoint object in the profile
contact_obj = SubElement(root, 'vcard:Kind', attrib={'rdf:about': contact_uri})
contact_name = SubElement(contact_obj, 'vcard:fn')
contact_name.text = config['dcat_ap']['contact_name']
contact_email = SubElement(contact_obj, 'vcard:hasEmail', attrib={'rdf:resource': config['OpenData']['author_email']})

# Find and create the Dataset objects in the profile.
for indic_id in ds.get_indicator_ids():
    dataset_uri = store + 'dataset' + my_env.get_dataset_id(indic_id)
    # Initialize dataset object
    dataset_obj = SubElement(root, 'dcat:Dataset', attrib={'rdf:about': dataset_uri})
    # Add dataset to Catalog object
    dcat_dataset = SubElement(catalog_obj, 'dcat:dataset', attrib={'rdf:resource': dataset_uri})
    # Add dataset attributes
    ind_modified = ds.get_indicator_val(indic_id, 'FicheBijgewerkt')[0:10]
    dataset_mod = SubElement(dataset_obj, 'dcterms:modified', attrib={'dcterms:date': ind_modified})
    # Todo - Add created time to indicators table
    dataset_issued = SubElement(dataset_obj, 'dcterms:issued', attrib={'dcterms:date': ind_modified})
    dataset_title = SubElement(dataset_obj, 'dcterms:title', **lang)
    dataset_title.text = ds.get_indicator_val(indic_id, 'title')
    dataset_desc = SubElement(dataset_obj, 'dcterms:description', **lang)
    dataset_desc.text = ds.get_indicator_val(indic_id, 'notes')
    dataset_publ = get_publisher(dataset_obj)
    dataset_contact = get_contactpoint(dataset_obj)
    dataset_lang = get_language(dataset_obj)
    landing_page = config['dcat_ap']['landing_url'] + my_env.get_name_from_indic(config, indic_id)
    dataset_lp = SubElement(dataset_obj, 'dcat:landingPage', attrib={'rdf:resource': landing_page})
    dataset_theme_datathank = SubElement(dataset_obj, 'dcat:theme',
                                         attrib={'rdf:resource': config['dcat_ap']['datathank_theme']})
    dataset_theme_fedgov = SubElement(dataset_obj, 'dcat:theme',
                                         attrib={'rdf:resource': config['dcat_ap']['fedgov_theme']})

    # Now handle all distributions
    for distr in my_env.get_resource_types():
        distr_url_attr = 'url_' + distr
        if ds.get_indicator_value(indic_id, distr_url_attr):
            # Distribution exist for this resource type
            distr_uri = store + distr + my_env.get_dataset_id(indic_id)
            distr_obj = SubElement(root, 'dcat:Distribution', attrib={'rdf:about': distr_uri})
            dataset_distr = SubElement(dataset_obj, 'dcat:distribution', attrib={'rdf:resource': distr_uri})
            distr_loc = ds.get_indicator_val(indic_id, distr_url_attr)
            distr_url = SubElement(distr_obj, 'dcat:accessURL', attrib={'rdf:resource': distr_loc})
            distr_lic = get_license(distr_obj)
            distr_format = SubElement(distr_obj, 'dcterms:format')
            distr_format.text = ds.get_indicator_val(indic_id, 'format_' + distr)
            distr_desc = SubElement(distr_obj, 'dcterms:description', **lang)
            distr_desc.text = ds.get_indicator_val(indic_id, 'description_' + distr)

# Write the profile contents to file
res = ElementTree(element=root)
dcat_file = config['dcat_ap']['dcat_file']
res.write(dcat_file, encoding="utf-8", xml_declaration=True, method='xml')

# Load file on FTP Server
ftp = Ftp_Handler(config)
ftp.load_file(dcat_file)
