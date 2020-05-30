./1-1.sh | grep -v egress > parameter-list-ingress
head -n 5 parameter-list-ingress
./gen_streamstats_chart_all_ingress.sh parameter-list-ingress
head -n 5 streamstats_template_ingress.xml

