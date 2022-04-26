ROOT_DIR := $(CURDIR)
TEST_DIR := $(ROOT_DIR)/test_code

GIT_SYNC_VOLUME_NAME := test_code
GIT_SYNC_REPO := git@gitlab.com:infra-data/opendata/api-service-library.git
GIT_SYNC_BRANCH := feature/captcha
GIT_CONTAINER_NAME := git-sync
GIT_SYNC_WAIT := 10

TEST_IMAGE_NAME := test_image:test
TEST_CONTAINER_NAME := test_container

gitsync:
	docker run --name $(GIT_CONTAINER_NAME) -d \
		-e GIT_SYNC_REPO=$(GIT_SYNC_REPO) \
		-e GIT_SYNC_DEST=/git \
		-e GIT_SYNC_BRANCH=$(GIT_SYNC_BRANCH) \
		-e GIT_SYNC_REV=FETCH_HEAD \
		-e GIT_SYNC_WAIT=$(GIT_SYNC_WAIT) \
		-e GIT_SYNC_SSH=1 \
		-e GIT_SSH_KEY_FILE=/root/.ssh/id_rsa \
		-v $(ROOT_DIR)/ssh_cert/:/root/.ssh/ \
		-v $(TEST_DIR)/:/git \
		openweb/git-sync
	sleep $(GIT_SYNC_WAIT)

build:
	docker build -t $(TEST_IMAGE_NAME) -f $(TEST_DIR)/Dockerfile $(TEST_DIR)

test:
	docker run --rm -it \
	--name $(TEST_CONTAINER_NAME) \
	--entrypoint "" \
	$(TEST_IMAGE_NAME) bash -c "pip install pytest && cd /BaseApi/api && pytest"

dev:
	echo "Sync done"

clean:
	docker rm -f $(GIT_CONTAINER_NAME) $(TEST_CONTAINER_NAME)
	docker rmi $(TEST_IMAGE_NAME)
	rm -rf $(TEST_DIR)/* $(TEST_DIR)/.git
