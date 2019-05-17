Feature: Test that all cgi-bin scripts are enabled

    Background: Get an elmr session

        Given allow redirects is set to 'False'
        Given start new session

        # Given a valid SP session
        # Given no elmr session
        Given session cookie '$(elmr.serviceUrl)' with value '/any/path'
            | attribute      | value               |
            #--------------------------------------#
            | Domain         | $(url.domain)       |
            | Path           | /                   |
            | Secure         | false               |
            | HttpOnly       | false               |
        
        Given GET url '$(url.base):$(env.PORT)/auth/elmr/session'
        Then response status code is '302'
        And response is a redirect to url '$(url.base):$(env.PORT)/any/path'
        And response sets cookies with values
            | name                                                 |
            #------------------------------------------------------#
            | $(elmr.sessionKey) |


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
