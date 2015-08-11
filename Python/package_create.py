import ckanapi


def create_it():
    beta_ckan = 'http://beta.ckan.org'
    beta_api = '342eb47e-d72d-4b45-bd8a-4fac7bcf59b7'
    my_ckan_conn = ckanapi.RemoteCKAN(beta_ckan, apikey=beta_api)
    my_param = {
        "name": "dvc",
        "title": "dvc",
        "owner_org": "testbeorg",
    }

    try:
        pkg = my_ckan_conn.action.package_create(**my_param)
    except ckanapi.NotAuthorized:
        print('user unauthorized or accessing a deleted item')
    except ckanapi.NotFound:
        print('name/id not found')
    except ckanapi.SearchError:
        print('There is a SearchError')
    except ckanapi.SearchIndexError:
        print('There is a SearchIndexError')
    except ckanapi.SearchQueryError:
        print('There is SearchQueryError')
    except ckanapi.ServerIncompatibleError:
        print('There is a ServerIncompatibleError')
    except ckanapi.ValidationError:
        print('Validation errors')
    except ckanapi.CKANAPIError:
        print('CatchAll - Incorrect use of ckanapi or unable to parse response')
    else:
        print('Package Create did not report a (known) error')
