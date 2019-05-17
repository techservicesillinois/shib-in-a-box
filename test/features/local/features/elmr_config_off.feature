Feature: Test that elmr config is disabled
    
    Scenario: Test that elmr config is disabled

        Given allow redirects is set to 'False'  

        Given GET url '$(url.base):$(env.PORT)/auth/elmr/config' 
        Then response status code is '403'
        And response sets no cookies 
