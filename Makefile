
clean:
	rm -f slug.tgz
	vagrant destroy -f

vm:
	vagrant up
	vagrant provision

image: vm
	docker build -t slug .

slug:
	# docker cp may exit non-zero due to a file permissions bug. Ignore
	ID=$$(docker run -d slug tar cfvz /tmp/slug.tgz -C / --exclude=.git --exclude=.vagrant --exclude=usr/src ./app);\
	docker wait $$ID;\
	docker cp $$ID:/tmp/slug.tgz . || true

release: slug.tgz
	GIT_URL=$$(git config --get remote.heroku.url);\
	APP_NAME=$$(basename $${GIT_URL#*:} .git);\
	RESPONSE=$$(curl -sX POST -H 'Content-Type: application/json' -H 'Accept: application/vnd.heroku+json; version=3' -d "{\"process_types\":{\"web\":\"bin/web\"}}" -n https://api.heroku.com/apps/$$APP_NAME/slugs);\
	SLUG_ID=$$(echo "$$RESPONSE" | grep '"id":' | cut -d'"' -f4);\
	SLUG_URL=$$(echo "$$RESPONSE" | grep '"url":' | cut -d'"' -f4);\
	curl -X PUT	-H "Content-Type:" --data-binary @slug.tgz --progress-bar -o /dev/null $$SLUG_URL;\
	curl -X POST -H "Accept: application/vnd.heroku+json; version=3" -H "Content-Type: application/json" -d "{\"slug\":\"$$SLUG_ID\"}" -n https://api.heroku.com/apps/$$APP_NAME/releases;