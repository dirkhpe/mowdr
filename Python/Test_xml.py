from lib.Elementtree_pretty import prettify
from lib import my_env
from xml.etree.ElementTree import ElementTree, Element, SubElement, Comment, tostring

# Initialize Environment
projectname = "mowdr"
modulename = my_env.get_modulename(__file__)
config = my_env.get_inifile(projectname, __file__)
my_log = my_env.init_loghandler(config, modulename)
my_log.info('Start Application')

xmlns_config = config['xmlns']
xmlns_hash = {}
for k in xmlns_config:
    xmlns_hash['xmlns:'+k] = xmlns_config[k]
root = Element('rdf:RDF', **xmlns_hash)
# root.set('xmlns:rdf', "http://www.w3.org/1999/02/22-rdf-syntax-ns#")

comment = Comment('Generated for PyMOTW')
root.append(comment)

child = SubElement(root, 'child')
child.text = 'This child contains text.'

child_with_tail = SubElement(root, 'child_with_tail')
child_with_tail.text = 'This child has regular text.'
child_with_tail.tail = 'And "tail" text.'

child_with_entity_ref = SubElement(root, 'child_with_entity_ref')
child_with_entity_ref.text = 'This & that'

res = ElementTree(element=root)
# res.write('c:/temp/dc.xml', xml_declaration=True, method='XML', short_empty_elements=True)
res.write('c:/temp/dc.xml', encoding="utf-8", xml_declaration=True, method='xml')
# print(tostring(root, encoding="unicode", short_empty_elements=True))
