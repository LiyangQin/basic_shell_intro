#!/usr/bin/env bash
if [ $# != 2 ] ; then
echo "Usage: batch_work.sh worklistfile bizdate"
exit 1
fi

isdigit=`awk 'BEGIN { if (match(ARGV[1],"^[0-9]+$") != 0) print "true"; else print "false" }' $2`
if [[ $isdigit == "false" ]]; then
   echo "Input bizdate is not numeric variable. Usage: batch_work.sh worklistfile bizdate"
exit 1
fi

echo "begin<============================================================================>" >> batch_work.log

cat $1 | while read work
do
	if [ ${work} = "rm_risk_limit_result_to_oracle" ] ; then
		echo "process $work biz_date = $2 idx_batch = 2 begin"
		startTime_s=`date +%s`
		java -jar /home/sys_risk/timing_job_schedule/rmp-0.0.1.jar $2 >> batch_work.log 2>&1
		endTime_s=`date +%s`
		sumTime=$[ $endTime_s - $startTime_s ]
		if [ $? -eq 0 ] ; then
			echo "time_pass = $sumTime seconds result = OK"
			echo "process $work biz_date = $2 time_pass = $sumTime seconds result = OK" >> batch_work.log
		else
			echo "time_pass = $sumTime seconds result = ERROR"
			echo "process $work biz_date = $2 time_pass = $sumTime seconds result = ERROR" >> batch_work.log
		fi
	elif [ ${work:0:25} = "MART_RM_COMMON_INDEX_DATA" ] ; then
		idx_batch=0${work:26:1}
		startTime_s=`date +%s`
		echo "process $work biz_date = $2 idx_batch = ${idx_batch} begin" 
		/usr/bin/python3 /home/sys_risk/rmp_job_schedule/SQLprepare.py $2 $idx_batch >> batch_work.log 2>&1
		endTime_s=`date +%s`
		sumTime=$[ $endTime_s - $startTime_s ]
                if [ $? -eq 0 ] ; then
                        echo "time_pass = $sumTime seconds result = OK"
                        echo "process $work idx_batch = ${idx_batch} biz_date = $2 time_pass = $sumTime seconds result = OK" >> batch_work.log
                else
                        echo "time_pass = $sumTime seconds result = ERROR" 
                        echo "process $work idx_batch = ${idx_batch} biz_date = $2 time_pass = $sumTime seconds result = ERROR" >> batch_work.log
                fi
	else
		echo "process $work biz_date = $2 begin"
		startTime_s=`date +%s`
    		/usr/bin/python3 /etl/bigdata_jobs/dpl/run_ndays_job.py $work $2 $2 1 >> batch_work.log 2>&1
		endTime_s=`date +%s`
		sumTime=$[ $endTime_s - $startTime_s ]
    		if [ $? -eq 0 ] ; then
        	echo "time_pass = $sumTime seconds result = OK"
        	echo "process $work biz_date = $2 time_pass = $sumTime seconds result = OK" >> batch_work.log
    		else
        	echo "time_pass = $sumTime seconds result = ERROR"
        	echo "process $work biz_date = $2 time_pass = $sumTime seconds result = ERROR" >> batch_work.log
    		fi
	fi
done

echo "end<==============================================================================>" >> batch_work.log 
