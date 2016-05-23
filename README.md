Github Make Release
======================

[![Build Status](https://travis-ci.org/warmans/github-make-release.svg?branch=master)](https://travis-ci.org/warmans/github-make-release)

Makefile include to simplify github release automation.

### Variables

You must override some variables in your makefile. The minimum required vars
can be seem in the example makefile below. Detailed descriptions are
available in the `github.mk` comments.

### Targets

Targets with a `_` prefix are not indended for direct use. The only "public" target
is `release`. For more information on these targets see the comments in the
`github.mk` file.

### Example Makefile

```
GH_REPO_OWNER = "warmans"
GH_REPO_NAME = "test"
GH_API_TOKEN = "mysecretkey"

RELEASE_VERSION = "0.0.5"

RELEASE_ARTIFACT_DIR = "/path/to/some/artifacts"

include github.mk
```
