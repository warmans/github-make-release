# Version must be set somewhere
RELEASE_VERSION ?= "0.0.0"
RELEASE_DRAFT ?= "false"
RELEASE_TARGET_COMMITISH ?= "master"
RELEASE_PRE ?= "false"
RELEASE_ARTIFACT_DIR ?= ""
RELEASE_ARTIFACT_REGEX ?= ".*"

# Github Configuration
GH_API_TOKEN ?= ""
GH_REPO_OWNER ?= ""
GH_REPO_NAME ?= ""

# templates
_TPL_RELEASE ?= '{"tag_name":"%s", "target_commitish":"%s", "name":"Release %s", "body":"Release of version %s", "draft":%s, "prerelease":%s}'

# private constants
_PAYLOAD_RELEASE = `printf $(_TPL_RELEASE) $(RELEASE_VERSION) $(RELEASE_TARGET_COMMITISH) $(RELEASE_VERSION) $(RELEASE_VERSION) $(RELEASE_DRAFT) $(RELEASE_PRE)`
_RELEASE_INFO = ".release-info.json"

.PHONY: _validate
_validate:
	@if [ -z $(RELEASE_VERSION) ]; then echo "RELEASE_VERSION must be set"; exit 1; fi;
	@if [ -z $(GH_API_TOKEN) ]; then echo "GH_API_TOKEN must contain a valid github API access token"; exit 1; fi;
	@if [ -z $(GH_REPO_OWNER) ]; then echo "GH_REPO_OWNER must contain the github repo owner's username"; exit 1; fi;
	@if [ -z $(GH_REPO_NAME) ]; then echo "GH_REPO_NAME must contain the github repo name"; exit 1; fi;

.PHONY: _release
_release:
	@echo "releasing version $(RELEASE_VERSION)..."
	@curl --data "$(_PAYLOAD_RELEASE)" https://api.github.com/repos/$(GH_REPO_OWNER)/$(GH_REPO_NAME)/releases?access_token=$(GH_API_TOKEN) | tee $(_RELEASE_INFO)

.PHONY: _artifacts
_artifacts:
	@if [ ! -z $(RELEASE_ARTIFACT_DIR) ]; then \
		if [ ! -f $(_RELEASE_INFO) ]; then echo "missing release info. Unable to publish artifacts without a release ID"; exit 1; fi; \
		echo "uploading artifacts..."; \
		for ARTIFACT in `find  $(RELEASE_ARTIFACT_DIR) -maxdepth 1 -regex $(RELEASE_ARTIFACT_REGEX) -type f -printf '%p\n'`; \
			do echo `basename $${ARTIFACT}`; \
			curl -H "Authorization: token $(GH_API_TOKEN)" -H "Content-Type: `file --mime-type $${ARTIFACT}`" \
			 --data-binary @$${ARTIFACT} \
			 "https://uploads.github.com/repos/$(GH_REPO_OWNER)/$(GH_REPO_NAME)/releases/`grep '^  "id":' $(_RELEASE_INFO) | tr -cd '[[:digit:]]'`/assets?name=`basename $${ARTIFACT}`"; \
		done; \
	fi;

.PHONY: _cleanup
_cleanup:
	rm -f $(_RELEASE_INFO)

.PHONY: release
release: _validate _release _artifacts _cleanup
