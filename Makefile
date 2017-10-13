IMAGE = virsorter

image:
	docker build -t $(IMAGE) .

it:
	docker run --rm -v /usr/local/imicrobe/virsorter-data:/data -w /work --entrypoint bash $(IMAGE)

lichen:
	docker run --rm -v /usr/local/imicrobe/virsorter-data:/data -v /usr/local/imicrobe/data/lichen:/work -w /work $(IMAGE) -i /work/fasta -o /work/virsorter-out -d 3

delong:
	docker run --rm -v /usr/local/imicrobe/virsorter-data:/data -v ~/work/delong/:/work -w /work $(IMAGE) -i /work/fasta -o /work/virsorter-out

local-install: 
	docker run -it --rm -v $(shell pwd)/local:/local -v $(shell pwd):/work -w /work --entrypoint bash $(IMAGE)

cpan:
	cpanm --local-lib-contained /local --installdeps .
