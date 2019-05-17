Feature: Test that all cgi-bin scripts are disabled
   
    Background:
        # Given a valid SP session
        Given allow redirects is set to 'False'  
 
    Scenario: Test that environment page is disabled

        Given GET url '$(url.base):$(env.PORT)/auth/cgi-bin/environment' 
        Then response status code is '403'

    Scenario: Test that redis page is disabled

        Given GET url '$(url.base):$(env.PORT)/auth/cgi-bin/list'
        Then response status code is '403'
