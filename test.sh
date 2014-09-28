#!/bin/bash -e

CD3='node parse.js d3js.pegjs'
TESTDIR='./tests'
RUNDIR='./testrun'

mkdir -p $RUNDIR
rm -f $RUNDIR/*

function run {
	tests=$(ls $TESTDIR/*.test)

	for test_file in $tests
	do
		echo "=== run $test_file"

		test_name=$(basename $test_file)
		test_out="$RUNDIR/$test_name.out"
		test_exp="$test_file.exp"

		echo 'INPUT'
		cat $test_file | awk '{print "  " $0}'
		echo
		echo 'OUTPUT'
		$CD3 < $test_file | tee $test_out | awk '{print "  " $0}'

		diff $test_out $test_exp || exit 1
	done
}

(run && echo "ALL OK") || (echo "FAIL" && exit 1)
