Feature: Test that all cgi-bin scripts are enabled and shib protected
    
    Background: Given an invalid SP session 

        Given allow redirects is set to 'False'  
 

    Scenario: Test that environment page is enabled and shib protected

        Given GET url '$(url.base):$(env.PORT)/auth/cgi-bin/environment' 
        Then response status code is '302'
        And response is a redirect to url starting with 'https://shibboleth.illinois.edu/idp/profile/SAML2/Redirect/SSO'

    Scenario: Test that redis list page is enabled and shib protected

        Given GET url '$(url.base):$(env.PORT)/auth/cgi-bin/list' 
        Then response status code is '302'
        And response is a redirect to url starting with 'https://shibboleth.illinois.edu/idp/profile/SAML2/Redirect/SSO'

    Scenario: Test that redis kill page is enabled and shib protected

        Given GET url '$(url.base):$(env.PORT)/auth/cgi-bin/kill'
        Then response status code is '302'
        And response is a redirect to url starting with 'https://shibboleth.illinois.edu/idp/profile/SAML2/Redirect/SSO'
