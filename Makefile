ARCH ?= universal
VERSION ?= 1.2.5

.PHONY: build test package icon clean

build:
	./scripts/build.sh --arch $(ARCH) --version $(VERSION)

test:
	./scripts/test-core.sh

package:
	./scripts/package.sh --arch $(ARCH) --version $(VERSION)

icon:
	./scripts/generate-icon.sh

clean:
	swift package clean
	rm -rf build dist

