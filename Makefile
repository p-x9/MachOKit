.PHONY: xcframework
xcframework:
	bash scripts/xcframework.sh

.PHONY: docc
docc:
	bash scripts/docc.sh

.PHONY: docc-preview
docc-preview:
	bash scripts/docc-preview.sh
