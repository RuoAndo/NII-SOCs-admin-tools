XML file (dashboard) generagteor

<pre>
if [ $# != 5 ]; then
        echo "usage: ./trans.sh [XML file name] [ingress file path] [egress file path] [XML file title]"
	exit 1
fi
</pre>

NNNNN: dashboard name
IIIII: file path of ingoing
EEEEE: file path of outgoing
HHHHH: host name

<pre>
# ./1-1-aws.sh | grep -v egress > parameter-list-aws
# ./gen_streamstats_chart_all_ingress_aws.sh parameter-list-aws
</pre>