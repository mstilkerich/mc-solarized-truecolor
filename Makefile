ifndef MC_SYNTAX
ifneq ($(wildcard /usr/local/share/mc/syntax/Syntax),)
MC_SYNTAX=/usr/local/share/mc/syntax/Syntax
else ifneq ($(wildcard /usr/share/mc/syntax/Syntax),)
MC_SYNTAX=/usr/share/mc/syntax/Syntax
else
$(error Specify MC_SYNTAX to point to the location of the midnight commander syntax file)
endif
endif

RELEASE_VERSION ?= $(shell git tag --points-at HEAD)

# Example usage for non-HEAD version: RELEASE_VERSION=v4.1.0 make tarball
.PHONY: tarball
tarball:
	@[ -n "$(RELEASE_VERSION)" ] || { echo "Error: HEAD has no version tag, and no version was set in RELEASE_VERSION"; exit 1; }
	rm -rf build/syntax build/skins "releases/mc-solarized-truecolor-$(RELEASE_VERSION)"
	mkdir -p "releases/mc-solarized-truecolor-$(RELEASE_VERSION)"
	./makeskins.pl --syntaxfile "$(MC_SYNTAX)" --version "$(RELEASE_VERSION)"
	mv build/syntax build/skins "releases/mc-solarized-truecolor-$(RELEASE_VERSION)/"
	cd releases && zip -r "mc-solarized-truecolor-$(RELEASE_VERSION).zip" "mc-solarized-truecolor-$(RELEASE_VERSION)"
	rm -rf "releases/mc-solarized-truecolor-$(RELEASE_VERSION)"
