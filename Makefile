image:
	docker build -t virsorter .

delong:
	docker run --rm -v /usr/local/imicrobe/virsorter-data:/data -v ~/work/delong/:/work -w /work virsorter -i /work/fasta -o /work/virsorter-out

local-clean:
	rm -rf ~/work/delong/out/*

local: local-clean
	PATH=$(shell pwd)/bin:$(PATH) ./run-virsorter.sh -i ~/work/delong/fasta -o ~/work/delong/out -l /usr/local/imicrobe/virsorter-data
