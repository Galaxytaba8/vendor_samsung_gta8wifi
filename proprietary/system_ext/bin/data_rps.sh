#!/system/bin/sh

LOG_TAG="data_rps.sh"
rfc=4096
cc=4
cpumask=f;
function mlog()
{
	echo "$@"
	log -p d -t "$LOG_TAG" "$@"
}

function exe_log()
{
	mlog "$@";
	eval $@;
}

function rps_on()
{
	##Enable RPS (Receive Packet Steering)
	((rsfe=$cc*$rfc));
	echo "$rsfe";
	exe_log "echo $rsfe > /proc/sys/net/core/rps_sock_flow_entries"
	retVal=$(cat /proc/sys/net/core/rps_sock_flow_entries)
	mlog "the flow entries value is $retVal"
	for fileRps in $(ls /sys/class/net/seth_lte*/queues/rx-*/rps_cpus)
		do
			exe_log "echo $cpumask > $fileRps";
			retVal=$(cat $fileRps)
			mlog "the value of $fileRps is $retVal"
		done
	for fileRfc in $(ls /sys/class/net/seth_lte*/queues/rx-*/rps_flow_cnt)
		do
			exe_log "echo $rfc > $fileRfc";
			retVal=$(cat $fileRfc)
			mlog "the value of $fileRfc is $retVal"
		done
}

function sfp_on()
{
	exe_log "echo 1 > /proc/net/sfp/enable"
	retVal=$(cat /proc/net/sfp/enable)
	mlog "the sfp value is $retVal"
}

function sfp_off()
{
	exe_log "echo 0 > /proc/net/sfp/enable"
	retVal=$(cat /proc/net/sfp/enable)
	mlog "the sfp value is $retVal"
}

function rps_off()
{
	exe_log "echo 0 > /proc/sys/net/core/rps_sock_flow_entries"
	retVal=$(cat /proc/sys/net/core/rps_sock_flow_entries)
	mlog "the sock flow entries value is $retVal"
	for fileRps in $(ls /sys/class/net/seth_lte*/queues/rx-*/rps_cpus)
		do
			exe_log "echo 0 > $fileRps";
			retVal=$(cat $fileRps)
			mlog "the value of $fileRps is $retVal"
		done
	for fileRfc in $(ls /sys/class/net/seth_lte*/queues/rx-*/rps_flow_cnt)
		do
			exe_log "echo 0 > $fileRfc";
			retVal=$(cat $fileRfc)
			mlog "the value of $fileRfc is $retVal"
		done
}

function rps_roc()
{
        exit 0;
        cpumask=ff;
        cc=8;
        netdev="sipa_eth";
        ##Enable RPS (Receive Packet Steering)
        chipType=$(getprop ro.product.board)
        if [ "$1" = "1" ]; then
                cpumask=0f;
        fi
        ((rsfe=$cc*$rfc));
        echo "$rsfe";
        exe_log "echo $rsfe > /proc/sys/net/core/rps_sock_flow_entries"
        retVal=$(cat /proc/sys/net/core/rps_sock_flow_entries)
        mlog "the flow entries value is $retVal"
        for fileRps in $(ls /sys/class/net/$netdev*/queues/rx-*/rps_cpus)
                do
                        exe_log "echo $cpumask > $fileRps";
                        retVal=$(cat $fileRps)
                        mlog "the value of $fileRps is $retVal"
                done
        for fileRfc in $(ls /sys/class/net/$netdev*/queues/rx-*/rps_flow_cnt)
                do
                        exe_log "echo $rfc > $fileRfc";
                        retVal=$(cat $fileRfc)
                        mlog "the value of $fileRfc is $retVal"
                done

        if [ -e "/proc/sys/net/core/rps_force_map" ]; then
                exe_log "echo 1 >/proc/sys/net/core/rps_force_map";
                retVal=$(cat "/proc/sys/net/core/rps_force_map")
                mlog "the value of rps_force_map is $retVal"
        fi
}

if [ "$1" = "on" ]; then
	rps_on;
elif [ "$1" = "off" ]; then
	rps_off;
elif [ "$1" = "sfp_on" ]; then
	sfp_on;
elif [ "$1" = "sfp_off" ]; then
	sfp_off;
elif [ "$1" = "roc_m" ]; then
        rps_roc 1;
elif [ "$1" = "roc_h" ]; then
        rps_roc 2;
fi
