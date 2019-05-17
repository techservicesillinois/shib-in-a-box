Feature: Local-only test to ensure that Apache's default page is disabled
    
    Scenario: Local-only test to ensure that Apache's default page is disabled

        Given allow redirects is set to 'False'  

        Given GET url '$(url.base):$(env.PORT)' 
        Then request body does not contain 'Testing 123'
        Then response status code is '403'
