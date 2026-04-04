run:
	cd apps/esp32_drybox && npm run build
	cd apps/login && npm run build
	./mako -c mako-test.conf
