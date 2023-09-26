#!/bin/bash
# A script to "prewarm" simulators to get around Migration Delays

simulator_udids=( `xcrun simctl list devices --json | jq '.devices[] | .[] | .udid'` )
for udid in "${simulator_udids[@]}"
do
	# Remove start/end quotes because we're doing this in Bash
	temp="${udid%\"}"
	udid="${temp#\"}"
	echo "Ensuring that the Simulator is off ..."
	xcrun simctl shutdown $udid
	echo "Booting the Simulator ..."
	xcrun simctl bootstatus $udid -b
	echo "Migration complete! Now shutting down the Simulator ..."
	xcrun simctl shutdown $udid
done

echo "Process complete!"