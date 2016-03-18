from xml.etree import ElementTree
from xml.dom import minidom


def prettify(elem):
    """
    Return a pretty-printed XML string for the Element.
    :param elem: The Element that needs to be prettified.
    :return Prettified element
    """
    rough_string = ElementTree.tostring(elem, 'utf-8')
    reparsed = minidom.parseString(rough_string)
    return reparsed.toprettyxml(indent="  ")
