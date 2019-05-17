Feature: Test that all cgi-bin scripts are enabled

    Background: Get an elmr session

include(`./include/valid_cookie_set.m4')

    Scenario: Test that list redis page is enabled and working

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
