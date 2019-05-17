+elmr means http://hostname/auth/elmr/config is expected to be accessiable
-elmr means http://hostname/auth/elmr/config is expected to be inaccessiable
+dbg means http://hostname/auth/cgi-bin/* is expected to be accessiable
-dbg means http://hostname/auth/cgi-bin/* is expected to be inaccessiable

dev = +elmr +dbg
prod = -elmr -dbg
