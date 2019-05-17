Feature: Test that elmr config is enabled and shib protected
    
    Scenario: Test that elmr config is enabled and shib protected

        Given allow redirects is set to 'False'  

        # Given an invalid SP session
        Given GET url '$(url.base):$(env.PORT)/auth/elmr/config' 
        Then response status code is '302'
        And response is a redirect to url starting with 'https://shibboleth.illinois.edu/idp/profile/SAML2/Redirect/SSO'
        And response sets no cookies 
