TF ?= terraform -chdir=envs/dev

.PHONY: init plan apply destroy

init:
	$(TF) init

plan:
	$(TF) plan -out=tfplan

apply:
	if [ -f tfplan ]; then $(TF) apply tfplan; else $(TF) apply; fi

destroy:
	$(TF) destroy
