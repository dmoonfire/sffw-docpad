RSYNC = rsync -aCL
RSYNC_TEXT = $(RSYNC) --filter=". src/rsync-text.txt"

COLLECT = build/src/documents/

all: clean generate

install: install-docpad

clean:
	rm -rf build

#
# Uploading
#

-include Upload.make

#
# Collection
#

collect:
# Create the directories for collecting stories
	rm -rf $(COLLECT)
	mkdir -p $(COLLECT)

# Copy the stories into the working directory and then remove the
# non-public files from the collection.
	$(RSYNC_TEXT) lib/sffw/ $(COLLECT)
	find $(COLLECT) -name "*.txt" -o -name "*.markdown" | xargs grep -L "Availability: Public" | xargs rm -f
	find $(COLLECT) -name "index.xml" | xargs grep -L 'schema="Availability"' | xargs rm -f
	find $(COLLECT) -name "index.xml" | xargs grep -L '<subjectterm>Public</subjectterm>' | xargs rm -f

# Convert the Creole files into Markdown.
	bin/creole2markdown --delete $(COLLECT)

#
# Generation
#

generate: collect
# Create the directories we'll be working with.
	mkdir -p build/src/documents
	mkdir -p build/src/files/js
	mkdir -p build/src/files/css

# Copy the DocPad elements and theme over.
	$(RSYNC) lib/twitter-bootstrap/img/ build/src/files/img/
	$(RSYNC) lib/twitter-bootstrap/less/ build/less/
	$(RSYNC) lib/twitter-bootstrap/js/ build/src/files/js/
	$(RSYNC) node_modules/ build/node_modules/
	$(RSYNC) src/ build/src/
	$(RSYNC) src/less/ build/less/
	mv build/src/docpad.coffee build/

# Create the CSS elements.
	lessc -x build/less/bootstrap.less build/src/files/css/bootstrap.css
	lessc -x build/less/responsive.less build/src/files/css/bootstrap-responsive.css

# Copy the base site files into the building directory.
	$(RSYNC) $(COLLECT)/ build/src/documents/

# Convert index files into Markdown.
	bin/index2markdown --delete build/src/documents/

# Add in the page for those pages that don't have it.
	for f in $$(find build/src/documents -name "*.markdown" | xargs grep -L 'layout: '); do \
		cat $$f \
			| sed '2 i layout: page' \
			> tmp; \
		mv tmp $$f; \
	done
	for f in $$(find build/src/documents -name "*.markdown" | xargs grep -L 'AllowIncome: '); do \
		cat $$f \
			| sed '2 i AllowIncome: true' \
			> tmp; \
		mv tmp $$f; \
	done

# Rename .markdown files into .html.md.
	for f in $$(find build/src/documents -name "*.markdown"); do \
		cat $$f \
		| bin/normalize-markdown-yaml \
		| bin/apply-typography \
		> $$(dirname $$f)/$$(basename $$f .markdown).html.md; \
		rm $$f; \
	done

# Move all the non-index.html.md files into directories.
	for f in $$(find build/src/documents -name "*.html.md" -and -not -name "index.html.md"); do \
		mkdir -p $$(dirname $$f)/$$(basename $$f .html.md); \
		mv $$f $$(dirname $$f)/$$(basename $$f .html.md)/index.html.md; \
	done

# Create the taxonomies and collections.
	bin/create-collections build/src/documents

# Set up the breadcrumbs.
	bin/create-breadcrumbs build/src/documents

# Generate the website.
	(cd build/ && docpad generate)

install-docpad:
	sudo apt-get install nodejs nodejs-legacy npm libyaml-perl libtext-typography-perl
	sudo npm install -g docpad@6.30
	cd src && npm install --save docpad-plugin-eco docpad-plugin-marked docpad-plugin-less docpad-plugin-sitemap docpad-plugin-partials
