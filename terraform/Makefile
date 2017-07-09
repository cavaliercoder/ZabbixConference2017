SOURCES = $(wildcard *.tf)

all: terraform.tfplan

fmt:
	terraform fmt $(PWD)

terraform.tfplan: $(SOURCES)
	terraform get
	terraform plan -out terraform.tfplan || rm -f terraform.tfplan

install: terraform.tfplan
	terraform apply terraform.tfplan
	$(MAKE) clean

clean:
	rm -vf terraform.tfplan

.PHONY: all fmt install clean
