# Makefile
root := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

final := $(root)data/final
#orig  := $(root)brahe-t_letters
orig  := $(root)data/raw

fixtitle_xslt := $(root)xslt/fix-title-2.xsl
SAXON := java -jar /usr/local/lib/saxon/saxon-he-11.6.jar

.PHONY: fix-data fix-title-example

# ----------------------------------------
# Find files RELATIVE to $(orig)
# ----------------------------------------
files := $(shell cd "$(orig)" && find . -type f -name '*.xml')

fixed_targets1 := $(patsubst ./%.xml,$(final)/%.xml,$(files))

fix-data: $(fixed_targets1)

# ----------------------------------------
# Pattern rule
# ----------------------------------------
$(final)/%.xml: $(orig)/%.xml $(fixtitle_xslt)
	@mkdir -p $(dir $@)
	$(SAXON) -s:"$<" -xsl:"$(fixtitle_xslt)" -o:"$@"

# ----------------------------------------
# Example
# ----------------------------------------
fix-title-example: examples/build/brahe-t_15680114001.xml

examples/build/brahe-t_15680114001.xml: examples/data/brahe-t_15680114001.xml $(fixtitle_xslt)
	@mkdir -p $(dir $@)
	$(SAXON) -s:"$<" -xsl:"$(fixtitle_xslt)" -o:"$@"

#root := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

#final := $(root)data/final
#orig  := $(root)brahe_letters

## stylesheet
#fixtitle_xslt := $(root)xslt/fix-title-2.xsl
#SAXON := java -jar /usr/local/lib/saxon/saxon-he-11.6.jar

#.PHONY: fix-data fix-title-example

##---- Recipe to fix data to align with other letters editions
#files := $(shell find "$(orig)" -type f -name '*.xml' 2>/dev/null)
#fixed_targets1 := $(patsubst $(orig)/%.xml,$(final)/%.xml,$(files))

#fix-data: $(fixed_targets1)

## Pattern rule for one file
#$(final)/%.xml: $(orig)/%.xml $(fixtitle_xslt)
#	@mkdir -p $(dir $@)
#	$(SAXON) -s:"$<" -xsl:"$(fixtitle_xslt)" -o:"$@"


#fix-title-example: examples/build/brahe-t_15680114001.xml

#examples/build/brahe-t_15680114001.xml: examples/data/brahe-t_15680114001.xml $(fixtitle_xslt)
#	@mkdir -p $(dir $@)
#	$(SAXON) -s:"$<" -xsl:"$(fixtitle_xslt)" -o:"$@"
