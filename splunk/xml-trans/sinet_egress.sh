./1-1.sh | grep -v ingress > parameter-list-egress
head -n 5 parameter-list-egress
./gen_streamstats_chart_all_egress.sh parameter-list-egress
head -n 5 streamstats_template_egress.xml

