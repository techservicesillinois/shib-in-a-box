To set the log level to debug
```
$ behave -D log_level=DEBUG --no-capture aws.feature
```

To disable docker-compose up and down use: 
```
$ behave -D DISABLE_DOCKER_UP DISABLE_DOCKER_DOWN aws.feature
```

Need to change to the directory where your local Behave is installed 
and run the following command
Tested with behave 1.2.6
```
$ cd /usr/local/lib/python3.6/site-packages/behave/
$ patch -p1 < ~/Source/shib-in-a-box/test/behave.patch
$ rm -r __pycache__
```

This will end up being done by make but to generate feature files from .m4
```
$ m4 elmrsample_shib_off_dbg_on.m4 > elmrsample_shib_off_dbg_on.feature
```

To set up the Behave test environment, first build shib-in-a-box in /shib-in-a-box
```
$ make
```

The install two modules that Behave steps are denpending on. 
```
$ pip3 install boto3
$ pip3 install sdg-test-behave-core --extra-index-url https://pip-test.techservices.illinois.edu/index/test
$ pip3 install sdg-test-behave-web --extra-index-url https://pip-test.techservices.illinois.edu/index/test
```

Install the m4 templating utility:
```
apt-get install m4
```


In /shib-in-a-box/test/features/local, run the following commands 
to run alll feature files under local
```
$ make clean
$ make
$ make down
$ make test
```
