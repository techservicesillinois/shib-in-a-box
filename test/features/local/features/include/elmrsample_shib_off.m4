ifdef(`DEBUG',`Feature: Elmrsample test', `Feature: Elmrsample test for MOCK_SHIB is true and ENABLE_DEBUG_PAGES is false')

    Scenario: Elmrsample test
        Given allow redirects is set to 'False'
        Given start new session

        # Given a valid SP session
        # Given no elmr session
        Given GET url '$(url.base):$(env.PORT)/elmrsample/attributes'
        Then response status code is '302'
        And response sets cookies with values
            # This cookie is used by elmr to remember the initial user url to return
            # to
            | key                                         | value                  |
            #----------------------------------------------------------------------#
            | __edu.illinois.techservices.elmr.serviceUrl | /elmrsample/attributes |
        #
        # https://tools.ietf.org/html/rfc7234
        # https://tools.ietf.org/html/rfc6265#section-4.1.2
        # https://tools.ietf.org/html/rfc6265#section-8

        And the cookie '__edu.illinois.techservices.elmr.serviceUrl' with domain '$(url.domain)' and path '/' has the following attributes 
            | attribute      | value               |
            #--------------------------------------#
            | Secure         | false               |
            | HttpOnly       | false               |
        
# FIXME: https://github.com/techservicesillinois/elmrsample/issues/6
#        And response sets headers
#            | header         | value               |
#            #--------------------------------------#
#            | Cache-Control  | no-cache            |
#            |                | no-store            |

        # We are redirected to /auth/elmr/session because we don't have an elmr session
        Given redirect to '$(url.base):$(env.PORT)/auth/elmr/session'
        Then response status code is '302'
        And response sets cookies with values
            | name                                                 |
            #------------------------------------------------------#
            | __edu.illinois.techservices.elmr.servlets.sessionKey |

# FIXME: https://github.com/techservicesillinois/elmr/issues/8
#        And the cookie '__edu.illinois.techservices.elmr.servlets.sessionKey' with domain '$(url.domain)' and path '/' has the following attributes 
#            | attribute      | value               |
#            #--------------------------------------#
#            | Secure         | true                |
#            | HttpOnly       | true                |

# FIXME: https://github.com/techservicesillinois/elmr/issues/9
#        And response sets headers
#            | header         | value               |
#            #--------------------------------------#
#            | Cache-Control  | no-cache            |
#            |                | no-store            |

        # Now we have a valid elmr session so we can access elmrsample
        # Given a valid elmr session
        Given redirect to '$(url.base):$(env.PORT)/elmrsample/attributes'
        Then response status code is '200'
        And response sets cookies
            | name                                                 |
            #------------------------------------------------------#
            | JSESSIONID                                           |

# TODO: Figure out what value we are expecting
#        And the cookie 'JSESSIONID' with domain '$(url.domain)' and path '/elmrsample' has the following attributes 
#            | attribute      | value               |
#            #--------------------------------------#
#            | Secure         | true                |
#            | HttpOnly       | true                |

# TODO: Figure out what value we are expecting
#        And response sets headers
#            | header         | value               |
#            #--------------------------------------#
#            | Cache-Control  | no-cache            |
#            |                | no-store            |

ifdef(`DEBUG', 
        # Check that Redis data was stored
        Given GET url '$(url.base):$(env.PORT)/auth/cgi-bin/list'
        Then response status code is '200'
        Then json body contains 
            | key                     | value                  |
            #--------------------------------------------------#
            | displayName             | $(saml.displayName)    |
            | eppn                    | $(saml.eppn)           |
        
        Given GET url '$(url.base):$(env.PORT)/auth/cgi-bin/kill'
        Then response status code is '200'
        Then json body contains 
            | key                     | value                  |
            #--------------------------------------------------#
            | success                 | killed the key         |

        # Check if Redis session is deleted
        Given GET url '$(url.base):$(env.PORT)/auth/cgi-bin/list'
        Then response status code is '200'
        Then json body contains 
            | key    | value                                      |
            #-----------------------------------------------------#
            | error  | Redis key not found:$(saml.shib-session-id)|
)
