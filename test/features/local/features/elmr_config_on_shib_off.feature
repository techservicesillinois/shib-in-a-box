Feature: Test that elmr config is enabled
    
    Scenario: Test that elmr config is enabled

        Given allow redirects is set to 'False'  

        # Given a valid SP session
        Given GET url '$(url.base):$(env.PORT)/auth/elmr/config' 
        Then response status code is '200'
        And response sets no cookies 
