#!/usr/bin/env python

# This program is designed to send a single email to me once a day if it doesn't see a commit
# in the last 24 hours to gist_a_day.

from gistapi import Gist, Gists
import gmail
import pprint

config = {
    'sender' : 'davidelmets4peace@gmail.com',
    'senderpw' : 'yuslohaw',
    'recipient' : 'themanchicken@gmail.com',
    'subject' : 'Don\'t forget to create a gist!',
    'gistuser' : 'manchicken',
    'api_token' : '069598e0300ee0445b48'
  }
  
gistfetch = Gists.fetch_by_user(config['gistuser'])
pprint.pprint(gistfetch)
