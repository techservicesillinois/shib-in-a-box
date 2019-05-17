Feature: Test that all cgi-bin scripts are enabled

    Background: 
    
        Given allow redirects is set to 'False'  
        # Given a valid SP session

    Scenario: Test that environment page is enabled

        # TODO: Add from sdg.test.behave.core import Cleaner to the core
        # Also, add port to the config
        Given GET url '$(url.base):$(env.PORT)/auth/cgi-bin/environment' 
        Then response status code is '200'

    Scenario: Test that list redis page is enabled

        Given GET url '$(url.base):$(env.PORT)/auth/cgi-bin/list'
        Then response status code is '200'
        
    Scenario: Test that kill redis page is enabled

        Given GET url '$(url.base):$(env.PORT)/auth/cgi-bin/kill'
        Then response status code is '200'
