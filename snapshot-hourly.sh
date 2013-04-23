#/bin/sh
CMD="hourly"
for i in monthly weekly daily hourly; do
    [ -n "`echo $@ | grep $i`" ] && CMD=$i
done
echo "Command: ${CMD}"

exec rsnapshot -c /home/radja/.rsnapshot2.conf "${CMD}"
