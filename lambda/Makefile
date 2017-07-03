PACKAGES := $(patsubst %.py,%.zip,$(wildcard *.py))
ZABBOPS_SOURCES := $(wildcard zabbops/*.py)
ZABBIX_SOURCES := $(wildcard pyzabbix/*.py)

all: $(PACKAGES)

%.zip: %.py $(ZABBOPS_SOURCES) $(ZABBIX_SOURCES)
	zip -v -9 $@ \
		$< \
		$(ZABBOPS_SOURCES) \
		$(ZABBIX_SOURCES)

check:
	python -m unittest tests

clean:
	rm -v -f $(PACKAGES)

get-deps:
	pip install --target=$(PWD) --upgrade \
		zabbops

.PHONY: all check clean get-deps
