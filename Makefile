export TAG ?= $(USER)
export ORG ?= techservicesillinois
export SHIB_IN_A_BOX_TAG := $(TAG)

IMAGES := shibd-cron shibd-config shibd httpd
PUSH := $(addsuffix .push, $(IMAGES))
PULL := $(addsuffix .pull, $(IMAGES))

SRC_DIRS := alb builder base common shibd-config cron shibd httpd
CLEAN := $(addsuffix .clean,$(SRC_DIRS))

.PHONY: all login push pull test clean $(SRC_DIRS)

MAKEFLAGS='-j 4'

all: $(SRC_DIRS) .drone.yml.sig

up: all
	docker-compose up -d

reload: down all
	docker-compose up -d

down:
	docker-compose down

ps:
	docker-compose ps

base: builder
shibd-config: base
common: base
shibd: common
httpd: common

$(SRC_DIRS):
	make -C $@

.drone.yml.sig: .drone.yml
	drone sign techservicesillinois/shib-in-a-box
	git add $^ $@

builder.clean: base.clean
base.clean: common.clean shibd-config.clean
common.clean: shibd.clean httpd.clean

clean: $(CLEAN)
	-rm -f cookie.txt

%.clean:
	make clean -C $*

login:
	docker login

push: $(PUSH)

httpd.push: shibd-config.push
shibd.push: httpd.push

%.push:
	docker push $(ORG)/$*:$(TAG)
	@touch $@

pull: $(PULL)

httpd.pull: shibd-config.pull
shibd.pull: httpd.pull

%.pull:
	docker pull $(ORG)/$*:$(TAG)

RED='\033[0;31m'
NC='\033[0m' # No Color

CLIENT_IP="1.2.3.4"
CURL=curl -sS -o /dev/null
REDIRECT_CURL=$(CURL) -b cookie.txt -c cookie.txt -w "%{http_code} %{redirect_url}"
HTTP_CODE_CURL=$(CURL) -w "%{http_code}"
COOKIE_CURL=$(REDIRECT_CURL) -c cookie.txt

ELMR_SESSION=http://127.0.0.1/auth/elmr/session
ELMR_LOGOUT=http://127.0.0.1/auth/elmr/session?mode=logout
SHIB_LOGOUT=http://127.0.0.1/auth/Shibboleth.sso/Logout

APP_ATTRIB=http://127.0.0.1/elmrsample/attributes
APP_LOGOUT=http://127.0.0.1/elmrsample/logout

# Internal Server Error
500=grep -q 500

# Forbidden
403=grep -q 403

# Bad Request
400=grep -q 400

# Redirect
302=grep -q 302

# OK
204=grep -q 204
200=grep -q 200

test:
	# Expect no content at /
	$(HTTP_CODE_CURL) http://127.0.0.1 | $(403)
	$(HTTP_CODE_CURL) http://localhost/cgi-bin/environment | $(403)
	# Make sure no welcome page is returned!
	! curl -sS http://127.0.0.1 | grep 'Testing 123'
	#
	# Check Shibboleth Metadata is correct
	$(HTTP_CODE_CURL) http://127.0.0.1/auth/Shibboleth.sso/Metadata | $(200)
	$(HTTP_CODE_CURL) http://127.0.0.1/Shibboleth.sso/Metadata | $(403)
	curl -sS http://127.0.0.1/auth/Shibboleth.sso/Metadata | diff -q - Metadata.auth
	$(HTTP_CODE_CURL) http://localhost/auth/shibboleth-sp/main.css | $(200)
	#
	# Check elmrsample works
	@-rm -f cookie.txt
	$(REDIRECT_CURL) $(APP_ATTRIB)   | grep -q "302 $(ELMR_SESSION)"
	$(REDIRECT_CURL) $(ELMR_SESSION) | grep -q "302 $(APP_ATTRIB)"
	$(REDIRECT_CURL) $(APP_ATTRIB)   | $(200)
	# test logout
	$(REDIRECT_CURL) $(APP_LOGOUT)   | grep -q "302 $(ELMR_LOGOUT)"
	$(REDIRECT_CURL) $(ELMR_LOGOUT)  | grep -q "302 $(SHIB_LOGOUT)"
	$(REDIRECT_CURL) $(SHIB_LOGOUT)  | $(200)
	# Let's make sure we really are logged out!
	$(REDIRECT_CURL) $(APP_ATTRIB)   | grep -q "302 $(ELMR_SESSION)"
	# TODO - This seems like a bug. Should we be able to logout twice?
	$(REDIRECT_CURL) $(APP_LOGOUT)   | grep -q "302 $(ELMR_LOGOUT)"  # Should this be a 400 or 401?
	#
	# Tests with no cookies
	@-rm -f cookie.txt
	$(HTTP_CODE_CURL) $(ELMR_SESSION) | $(400)
	$(HTTP_CODE_CURL) $(ELMR_LOGOUT)  | $(302)
	$(HTTP_CODE_CURL) $(APP_LOGOUT)   | $(302)
	# Test that the client's IP is logged not the LB's!
	# Note the client IP is hardcoded in the ALB as 1.2.3.4
	docker-compose logs httpd   | grep -q $(CLIENT_IP)
	docker-compose logs elmr    | grep -q $(CLIENT_IP) || sleep 1 ; echo "Let's try again!"
	docker-compose logs elmr    | grep -q $(CLIENT_IP) || sleep 2 ; echo "Let's try again!"
	docker-compose logs elmr    | grep -q $(CLIENT_IP) || sleep 4 ; echo "Let's try again!"
	docker-compose logs elmr    | grep -q $(CLIENT_IP)
	docker-compose logs service | grep -q $(CLIENT_IP)
	# Ensure httpd redirects when X-Forwarded-Proto is set to http
	# We must connect directly to the httpd container by passing the ALB
	$(REDIRECT_CURL) -H "X-Forwarded-Proto: http" -H "X-Forwarded-For: 1.2.3.4" -H "X-Forwarded-Port: 443" 127.0.0.1:8080 | grep -q "301 https://127.0.0.1:8080/"
	curl -s http://localhost/auth/cgi-bin/environment | grep -q 'HTTP_X_FORWARDED_PROTO="https"' || echo "$(RED)ENABLE_DEBUG_PAGES is not set$(NC)\a"
	curl -s http://127.0.0.1/auth/elmr/config | grep -q 'elmr - Apache Configuration' || echo "$(RED)ENABLE_ELMR_CONFIG is not set$(NC)\a"
	#
	# Test redirects - Do we want to test this? Should config be disabled by
	# default?
	# $(REDIRECT_CURL) http://127.0.0.1/elmrsample/config | $(302)
	# $(REDIRECT_CURL) http://127.0.0.1/auth/elmr/config | $(302)
	$(HTTP_CODE_CURL) http://127.0.0.1/auth/elmr/config | $(200)
	$(HTTP_CODE_CURL) http://localhost:8080/auth/elmr/status | $(204)
