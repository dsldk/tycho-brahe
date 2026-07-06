root := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

final_dir        := $(root)data/final
final_letters    := $(final_dir)/brahe-t_letters
orig_letters     := $(root)data/raw/brahe-t_letters
out_letters      := $(root)build/brahe-t_letters

letters_xslt     := /home/th/dev/tekstnet-xsl/xsl/letter.xsl
fixtitle_xslt    := $(root)xslt/fix-title-2.xsl
SAXON            := java -jar /usr/local/lib/saxon/saxon-he-11.6.jar

.PHONY: letters build-letters fix-data fix-title-example clean

letters: fix-data build-letters

# ----------------------------
# Step 1: fix raw XML -> final XML
# ----------------------------
raw_xmls        := $(shell find "$(orig_letters)" -type f -name '*.xml' 2>/dev/null)
fixed_xmls      := $(patsubst $(orig_letters)/%.xml,$(final_letters)/%.xml,$(raw_xmls))

fix-data: $(fixed_xmls)

$(final_letters)/%.xml: $(orig_letters)/%.xml $(fixtitle_xslt)
	@mkdir -p $(dir $@)
	$(SAXON) -s:"$<" -xsl:"$(fixtitle_xslt)" -o:"$@"

# ----------------------------
# Step 2: final XML -> HTML
# ----------------------------
final_xmls      := $(shell find "$(final_letters)" -type f -name '*.xml' 2>/dev/null)
html_letters    := $(patsubst $(final_letters)/%.xml,$(out_letters)/%.html,$(final_xmls))

build-letters: $(html_letters)

$(out_letters)/%.html: $(final_letters)/%.xml $(letters_xslt)
	@mkdir -p $(dir $@)
	$(SAXON) -s:"$<" -xsl:"$(letters_xslt)" -o:"$@"

# ----------------------------
# Example
# ----------------------------
fix-title-example: examples/build/brahe-t_15680114001.xml

examples/build/brahe-t_15680114001.xml: examples/data/brahe-t_15680114001.xml $(fixtitle_xslt)
	@mkdir -p $(dir $@)
	$(SAXON) -s:"$<" -xsl:"$(fixtitle_xslt)" -o:"$@"

clean:
	rm -rf "$(final_letters)" "$(out_letters)"

