Feature: Elmr tests for MOCK_SHIB is true

    Scenario: Elmr test with no serviceUrl cookie set
        Given allow redirects is set to 'False'
        Given start new session

        # This is a bad request and we expect 400 status code
        Given GET url '$(url.base):$(env.PORT)/auth/elmr/session'
        Then response status code is '400'

    Scenario: Elmr test with valid serviceUrl cookie set

include(`./include/valid_cookie_set.m4')

        Given save cookie '$(elmr.sessionKey)'
        
        Given GET url '$(url.base):$(env.PORT)/auth/elmr/session'
        Then response status code is '302'
        And response is a redirect to url '$(url.base):$(env.PORT)/any/path'
        And response sets cookies with values
            | name                                                 |
            #------------------------------------------------------#
            | $(elmr.sessionKey) |

        And cookie '$(elmr.sessionKey)' equals saved cookie
