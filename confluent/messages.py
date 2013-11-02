#Copyright 2013 IBM All rights reserved

# This module implements client/server messages emitted from plugins.
# Things are defined here to 'encourage' developers to coordinate information
# format.  This is also how different data formats are supported
import json

class ConfluentMessage(object):

    def __init__(self):
        raise NotImplementedError("Must be subclassed!")

    def json(self):
        # This will create the canonical json representation of this message
        return json.dumps(self.kvpairs, separators=(',', ':'))

    def strip_node(self, node):
        self.kvpairs = self.kvpairs[node]

    def html(self):
        #this is used to facilitate the api explorer feature
        snippet = ""
        for key in self.kvpairs.iterkeys():
            snippet += key + ":"
            snippet += '<input type="text" name="%s" value="%s">' % (
                            key, self.kvpairs[key])
        return snippet
            


class PowerState(ConfluentMessage):

    def __init__(self, node, state):
        self.kvpairs = {
            node: {
                'powerstate': state,
            }
        }

class Attributes(ConfluentMessage):
    def __init__(self, node, kv):
        self.kvpairs = {
            node: kv
        }

class CryptedAttributes(Attributes):
    def __init__(self, node, kv):
        # for now, just keep the dictionary keys and discard crypt value
        for currkey in kv.iterkeys():
            kv[currkey] = '*****ENCRYPTEDVALUE*****'
        self.kvpairs = {
            node: kv
        }
