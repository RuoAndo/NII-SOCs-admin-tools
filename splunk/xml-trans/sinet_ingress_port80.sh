./1-1.sh | grep -v egress > parameter-list-ingress-port80
head -n 5 parameter-list-ingress-port80
./gen_streamstats_chart_all_ingress_port80.sh parameter-list-ingress-port80
head -n 5 streamstats_template_ingress_port80.xml

