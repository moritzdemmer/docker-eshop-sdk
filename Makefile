USERID = `id -u`
USERNAME = `id -un`
GROUPID = `id -g`
GROUPNAME = `id -gn`

default: help

help:
	@echo "\n\
	    \e[1;1;33mSome Help needed?\e[0m\n\n\
	    \e[1;1;32mmake setup\e[0m - Prefills the .env file with sync required parameters \n\
	        and prepares all modifiable custom files from dist. Run this \n\
	        once before everything!\n\n\
	    \e[1;1;32mmake addbasicservices\e[0m - Adds php, apache and mysql services \n\
	    \e[1;1;32mmake file=... addservice\e[0m - Prepend file contents to current docker-compose.yml file\n\n\
	    \e[1;1;32mmake up\e[0m - Start all configured containers (have you run setup command already?)!\n\
	    \e[1;1;32mmake down\e[0m - Stop all configured containers\n\n\
	    \e[1;1;32mmake example\e[0m - Setup basic services + Runs example recipe\n\n\
	    \e[1;1;32mmake php\e[0m - Connect to php container shell\n\
	    \e[1;1;32mmake node\e[0m - Connect to node container shell\n\
	"

setup:
	@cat .env.dist | \
		sed "s/<userId>/$(USERID)/;\
		     s/<userName>/$(USERNAME)/;\
		     s/<groupId>/$(GROUPID)/;\
		     s/<groupName>/$(GROUPNAME)/"\
		> .env
	@cp -n containers/httpd/project.conf.dist containers/httpd/project.conf
	@cp -n containers/php/custom.ini.dist containers/php/custom.ini
	@cp -n docker-compose.yml.dist docker-compose.yml
	@echo "Setup done! Add basic services with \e[1;1;32mmake addbasicservices\e[0m and start everything \e[1;1;32mmake up\e[0m"

example:
	@make addbasicservices
	@./recipes/default/example/run.sh

up:
	docker compose up --build -d
	sudo bash update_hosts.sh

down:
	docker compose down --remove-orphans

php:
	docker compose exec php bash

generate-docs:
	docker compose run sphinx sphinx-build /home/$(USERNAME)/docs /home/$(USERNAME)/docs/build

node:
	docker compose run --rm node bash

mysql:
	docker compose exec db bash -c 'mysql -u$$MYSQL_USER -p$$MYSQL_PASSWORD -h$$MYSQL_HOST $$MYSQL_DATABASE'

addservice_noswitch:
	@cat services/$(service).yml >> docker-compose.yml
	@echo "\n" >> docker-compose.yml
	@echo "Service file $(service) contents added\n";

addservice:
	@mv services/unused_services/$(service).yml services/$(service).yml
	@make service=$(service) addservice_noswitch

addbasicservices:
	@make service=apache addservice
	@make service=php addservice
	@make service=db addservice
	@make service=mailhog addservice
	@make service=adminer addservice
	@echo "php, apache and mysql related services added\n";

addsphinxservice:
	@echo "\nDOC_PATH=$(docpath)" >> .env
	@make service=sphinx addservice

addallservices:
	@for service_file in services/*.yml; do \
		service=$$(basename $$service_file .yml); \
		make service=$$service addservice_noswitch; \
	done
	@echo "All services from the services folder have been added.\n";

cleanup:
	@make down
	@rm -rf source
	@rm .env docker-compose.yml
	@rm containers/httpd/project.conf
	@rm containers/php/custom.ini
	@rm -rf data/mysql/*
	@rm -rf data/composer/cache