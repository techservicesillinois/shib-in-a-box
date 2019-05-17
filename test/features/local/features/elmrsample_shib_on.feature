Feature: Ensure that Elmrsample is behind shib 
    
    Senario: Ensure that Elmrsample is behind shib 

        Given allow redirects is set to 'False'  

        Given GET url '$(url.base):$(env.PORT)/elmrsample/attributes' 
        Then response status code is '302'
        And response is a redirect to url starting with 'https://shibboleth.illinois.edu/idp/profile/SAML2/Redirect/SSO'
        And response sets no cookies 
