Feature: Log in to elmrsample with an IdP session
    
    Scenario Outline: Log in to elmrsample with an IdP session
 
        Given allow redirects is set to 'False'  

        Given start new session
       
        # We are given a valid IdP session 
        Given aws login cookie 'yoonlees'
        
        # We are redirected to /auth/elmr/session because we don't have an elmr session
        Given GET url '<base>/elmrsample/attributes' 
        Then response status code is '302'
        And response sets cookies with values
            # This cookie is used by elmr to remember the initial user url to return
            # to
            | key                                         | value                  |
            #----------------------------------------------------------------------#
            | __edu.illinois.techservices.elmr.serviceUrl | /elmrsample/attributes |
 
        # We are redirected to the IdP because we don't have a SP session
        Given redirect to '/auth/elmr/session'
        Then response status code is '302'
        And response sets no cookies        

        # IdP returns the SAMLResponse
        Given redirect to url starting with 'https://shibboleth.illinois.edu/idp/profile/SAML2/Redirect/SSO'
        Then response status code is '200'
        And response sets cookies
            | name                                                 | 
            #------------------------------------------------------#
            | shib_idp_session_ss                                  |

        Then POST the SAMLResponse to the SP
        And response status code is '302'
        # At this point, Shib SP will set two cookies with long names  
        # _shibsealed_*, _shibsession_* with same hash appended

        # Now we have a valid SP session so we can access elmr
        Given redirect to '<base>/auth/elmr/session' 
        Then response status code is '302'
        And response sets cookies
            # This cookie is used by elmrsample to look up the elmr session data
            # stored in redis
            | name                                                 | 
            #------------------------------------------------------#
            | __edu.illinois.techservices.elmr.servlets.sessionKey |

        # Now we have a valid elmr session so we can access elmrsample
        Given redirect to '/elmrsample/attributes' 
        Then response status code is '200'
        And response sets cookies
            | name                                                 | 
            #------------------------------------------------------#
            | JSESSIONID                                           |

        Examples: 
            |base                                                   |
            #-------------------------------------------------------#
            |https://multi-service.as-test.techservices.illinois.edu|     
