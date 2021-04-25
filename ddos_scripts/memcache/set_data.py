import memcache
import sys

mc = memcache.Client([sys.argv[1]+':11211'],debug=True)
val = '''
        aaasdasaddsadsadsasdadsadasdaasdsaddsa
        dasdasaddsadsadsasdadsadasdaasdsaddsa
        dsadasdsdadsadsadsadsadsasdadsaads
        sadasdsadsdasaddsadsadsadsadsasdasad
        dsadassdasdadasdsadsadsadsadsadsadsa
        dasdsasdadsasdadsasdasdadasadsdsasda
        dsasadsdasaddsasdadsadsadasdsasdasda
        dsasdadsadsadsadsadsasdadsasdadsasad
        sadadssdadsasdadsadassdadsadsadas
        dsasadsadsdadsadsaadsadsdasdasdas
        sdadsaadssaddsadsasdadsadsadsadsasda
        sdasdadsadsasaddsadsasdadsadsadsasdasad
        sdasdasdadsasadsdadsadsadsdsadasdassadsaddsa
        dsadasdsdadsadsadsadsadsasdadsaads
        sadasdsadsdasaddsadsadsadsadsasdasad
        dsadassdasdadasdsadsadsadsadsadsadsa
        dasdsasdadsasdadsasdasdadasadsdsasda
        dsasadsdasaddsasdadsadsadasdsasdasda
        dsasdadsadsadsadsadsasdadsasdadsasad
        sadadssdadsasdadsadassdadsadsadas
        dsasadsadsdadsadsaadsadsdasdasdas
        sdadsaadssaddsadsasdadsadsadsadsasda
        sdasdadsadsasaddsadsasdadsadsadsasdasad
        ssdasaddsadsadsasdadsadasdaasdsaddsa
        dasdasaddsadsadsasdadsadasdaasdsaddsa
        dsadasdsdadsadsadsadsadsasdadsaads
        sadasdsadsdasaddsadsadsadsadsasdasad
        dsadassdasdadasdsadsadsadsadsadsadsa
        dasdsasdadsasdadsasdasdadasadsdsasda
        dsasadsdasaddsasdadsadsadasdsasdasda
        dsasdadsadsadsadsadsasdadsasdadsasad
        sadadssdadsasdadsadassdadsadsadas
        dsasadsadsdadsadsaadsadsdasdasdas
        sdadsaadssaddsadsasdadsadsadsadsasda
        sdasdadsadsasaddsadsasdadsadsadsasdasad
        sdasdasdadsasadsdadsadsadsdsadasdassadsaddsa
        dsadasdsdadsadsadsadsadsasdadsaads
        sadasdsadsdasaddsadsadsadsadsasdasad
        dsadassdasdadasdsadsadsadsadsadsadsa
        dasdsasdadsasdadsasdasdadasadsdsasda
        dsasadsdasaddsasdadsadsadasdsasdasda
        dsasdadsadsadsadsadsasdadsasdadsasad
        sadadssdadsasdadsadassdadsadsadas
        dsasadsadsdadsadsaadsadsdasdasdas
        sdadsaadssaddsadsasdadsadsadsadsasda
        sdasdadsadsasaddsadsasdadsadsadsasdasad
        ssdasaddsadsadsasdadsadasdaasdsaddsa
        dasdasaddsadsadsasdadsadasdaasdsaddsa
        dsadasdsdadsadsadsadsadsasdadsaads
        sadasdsadsdasaddsadsadsadsadsasdasad
        dsadassdasdadasdsadsadsadsadsadsadsa
        dasdsasdadsasdadsasdasdadasadsdsasda
        dsasadsdasaddsasdadsadsadasdsasdasda
        dsasdadsadsadsadsadsasdadsasdadsasad
        sadadssdadsasdadsadassdadsadsadas
        dsasadsadsdadsadsaadsadsdasdasdas
        sdadsaadssaddsadsasdadsadsadsadsasda
        sdasdadsadsasaddsadsasdadsadsadsasdasad
        sdasdasdadsasadsdadsadsadsdsadasdassadsaddsa
        dsadasdsdadsadsadsadsadsasdadsaads
        sadasdsadsdasaddsadsadsadsadsasdasad
        dsadassdasdadasdsadsadsadsadsadsadsa
        dasdsasdadsasdadsasdasdadasadsdsasda
        dsasadsdasaddsasdadsadsadasdsasdasda
        dsasdadsadsadsadsadsasdadsasdadsasad
        sadadssdadsasdadsadassdadsadsadas
        dsasadsadsdadsadsaadsadsdasdasdas
        sdadsaadssaddsadsasdadsadsadsadsasda
        sdasdadsadsasaddsadsasdadsadsadsasdasad
        sdasdasdadsasadsdadsadsadsdsadasdassadsaddsa
        dsadsadsaadsdsadsadsadsaaaaaaaaaaaaaaaaaaaaaaa
        saddsadsasdadsasdasaddsadsadsasdadsadsadsa
        dssdasaddsadsadsasdadsadsadassdasaddsadsadsa
        sadsadsdsaadsadssdadsadsadsasaddasdsasdadsa
        dsaadsdsadsadsasdsdadsadsadsadsasdaasdsda
        dsadsadsadsadsasaddsasdadsaadsdsasdasdadsasadsda
        dsadsadsadsaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaadsadsadsa
        '''
mc.set('xah',val,90000)
#from pymemcache.client import base
#client = base.Client(('192.168.122.138', 11211))

#client.set('xah',s,90000)

#client.get('some_key')
