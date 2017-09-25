all: make_data make_label make_relabel

make_data:
	(cd vldc_data; make)

make_label:
	(cd vldc_label; make)

make_relabel:
	(cd vldc_relabel; make)

clean: clean_data clean_label clean_relabel

clean_data:
	(cd vldc_data; make clean)

clean_label:
	(cd vldc_label; make clean)

clean_relabel:
	(cd vldc_relabel; make clean)
