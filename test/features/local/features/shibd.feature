Feature: Test that shibd is accessible and functioning
    
    Scenario: Test that shibd is accessible and functioning

        # Check Shibboleth Metadata is accessible
        Given GET url '$(url.base):$(env.PORT)/auth/Shibboleth.sso/Metadata' 
        Then response status code is '200'

        # Check Shib SP CSS is accessible
        Given GET url '$(url.base):$(env.PORT)/auth/shibboleth-sp/main.css' 
        Then response status code is '200'
