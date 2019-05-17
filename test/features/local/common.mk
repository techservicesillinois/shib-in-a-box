.PHONY: all test down clean

# +ELMR means http://hostname/auth/elmr/config is expected to be accessiable
# -ELMR means http://hostname/auth/elmr/config is expected to be inaccessiable
# +DBG means http://hostname/auth/cgi-bin/* is expected to be accessiable
# -DBG means http://hostname/auth/cgi-bin/* is expected to be inaccessiable

TOP_LEVEL := environment.py steps docker-compose.yml .env
COMMON := local.feature shibd.feature $(TOP_LEVEL)

-ELMR := elmr_config_off.feature
-DBG := debug_off.feature

ifdef MOCK_SHIB # shib_off
    +ELMR := elmr_config_on_shib_off.feature
    +DBG  := elmrsample_shib_off_dbg_on.feature debug_on_shib_off_1.feature debug_on_shib_off_2.feature
    -DBG  := elmrsample_shib_off_dbg_off.feature $(-DBG)
    COMMON := elmr_shib_off.feature $(COMMON)
else # shib_on
    +ELMR := elmr_config_on_shib_on.feature
    +DBG  := debug_on_shib_on.feature
    COMMON := elmrsample_shib_on.feature $(COMMON)
endif
