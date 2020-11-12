#!/bin/bash
# Change Tomcat ID
# Written by Anthony Moulen
# Last Updated: 7 June 2017
# Purpose: Allow for the application UID and GID to be changed
# so that it can match an ID that lives outside the Docker Container.
# this way mounted volumes will be aligned with permissions on the underlying
# operating system.
# TODO: Fix script such that checks for all proposed changes are tested
#       before any change is committed.

# Tracker Variables
PROCESSED_CHANGE=0
SCRIPTNAME=$(basename $0)
# Username and Group Name to be modified. In future will pull this from
# an external file to allow for flexibility in other deployment models.
USERNAME="appuser"
GROUPNAME="appuser"

# Usage Function
function usage() {
  cat << USAGEDOC
Usage: $SCRIPTNAME [-u NewUserID] [-g NewGroupID]
This command will modify the user ID from its current value to a new
set of values for either GID or UID or both.  This command must be run
with root permission.

optional arguments:
  -u  Provide a new user ID for the tomcat ID
  -g  Provide a new group ID for the tomcat ID
  -h  Return this usage statement.

Without an argument this usage statement is returned.  Note due to order of
operations, a change to the UID may complete even if a GID change also passed
in will fail.  Keep this in mind.

Example:
  $SCRIPTNAME -u 15001
  The $USERNAME ID will change from its current UID to the UID 15001.  All files
  that were previously owned by the $USERNAME ID will become Owned by this new ID.
USAGEDOC
}

# Print usage message if no arguments are passed.
if [ $# -eq 0 ]
then
  usage
  exit 0
fi

# Process arguments passed to script.
while getopts ":u:g:h" tcOpt; do
  case $tcOpt in
    # Modify the UID of the application ID.
    u)
      NEW_USERID=$OPTARG
      # Ensure that a numeric UID is passed.
      if ! [ "$NEW_USERID" -eq "$NEW_USERID" ]; then
        echo "Invalid User ID passed: $NEW_USERID, must be a number"
        exit 1
      fi
      ;;
    # Modify the GID of the application.
    g)
      NEW_GROUPID=$OPTARG
      # Ensure that a numeric GID is passed.
      if ! [ "$NEW_GROUPID" -eq "$NEW_GROUPID" ] ; then
        echo "Invalid Group ID passed: $NEW_GROUPID, must be a number"
        exit 1
      fi
      ;;
    # Provide standard usage details.
    h)
      usage
      exit 0;
      ;;
    # Inform user that an invalid parameter has been passed and provide usage details.
    \?)
      echo "Invalid paramter option: $OPTARG" >&2
      usage
      exit 1
      ;;
    # Inform user that an axpected argument is missing.
    :)
      echo "Option -$OPTARG requires an argument." >&2
      usage
      exit 1
      ;;
  esac
done

# If an invalid argument is not passed, or help message not requested
# along with an argument, process any changes necessary.

# Commit the modification of the UID to the system.
if [ $NEW_USERID -ne 0 ]
then
  # Check for an Existing UID matching the new UID.
  EXISTING_UID=`getent passwd $NEW_USERID`
  # Get the current UID for the application ID.
  PREVIOUS_UID=`getent passwd $USERNAME | cut -d ':' -f 3`

  # If the replacement ID is the same as the existng ID, raise an error.
  if [ $PREVIOUS_UID -eq $NEW_USERID ]
  then
    echo "Can't change ID match current ID"
    usage
    exit 1;
  fi

  # If the replacement ID is already assigned to another ID, raise an error.
  if [[ ! -z $EXISTING_UID ]]; then
    OWNER_UID=`echo $EXISTING_UID | cut -d ':' -f 1`
    echo "That ID is already assigned to: $OWNER_UID"
    exit 1;
  fi

  # Inform user of activity about to take place.
  echo "Changing $USERNAME ID from $PREVIOUS_UID to $NEW_USERID"
  usermod -u $NEW_USERID $USERNAME;
  CONFIRM_UID_CHANGE=`getent passwd $USERNAME | cut -d ':' -f 3`

  # If something happened where the ID did not get changed raise an error.
  if [ $NEW_USERID -ne $CONFIRM_UID_CHANGE ]
  then
    echo "Error processing ID change request."
    exit 1;
  fi

  # Modify files owned by the user to match the new UID.
  find / -user $PREVIOUS_UID -not -path /proc -exec chown -h $USERNAME {} \;

  # Confirm change has been completed.
  echo "$USERNAME user ID modified from $PREVIOUS_UID to $NEW_USERID"
  # Adjust the processing flag to confirm that changes were processed.
  PROCESSED_CHANGE=1
fi

# Commit modifications of the GID to the system.
if [ $NEW_GROUPID -ne 0 ]
then
  # Check if an existing GID matches our new GID
  EXISTING_GID=`getent group $NEW_GROUPID`
  # Check if we are attempt to modify the ID to the ID it already has.
  PREVIOUS_GID=`getent group $GROUPNAME | cut -d ':' -f 3`

  # Inform user if the old and new GID are the same and exit.
  if [ $PREVIOUS_GID -eq $NEW_GROUPID ]
  then
    echo "Can't change group ID to match the current group ID."
    usage
    exit 1;
  fi

  # Inform user if the new GID matches an existing GID and exit.
  if [[ ! -z $EXISTING_GID ]]; then
    OWNER_GID=`echo EXISTING_GID | cut -d ':' -f 1`
    echo "That GID is already assigned to the group: $OWNER_GID"
    exit 1;
  fi

  # Inform user of the activity about to take place.
  echo "Changing $GROUPNAME ID from $PREVIOUS_GID to $NEW_GROUPID"
  # modify the group ID of the user.
  groupmod -g $NEW_GROUPID $GROUPNAME
  CONFIRM_GUID_CHANGE=`getent group $GROUPNAME | cut -d ':' -f 3`

  # If something happened that caused the change not to take place raise an error.
  if [ $NEW_GROUPID -ne $CONFIRM_GUID_CHANGE ]
  then
    echo "Error processing GID change request"
    exit 1;
  fi

  # Find and modify files owned by the old GID nad change them to the new GID.
  find / -group $PREVIOUS_GID -not -path /proc -exec chgrp -h $GROUPNAME {} \;

  # Inform user that change has been completed.
  echo "$GROUPNAME group ID modified from $PREVIOUS_GID to $NEW_GROUPID"
  # Mark processed flag to indicate some change was successfully completed.
  PROCESSED_CHANGE=1
fi

# Raise error if no change was actually Processed.  This should not be reachable.
if [ $PROCESSED_CHANGE -eq 0 ]
then
  echo "No valid parameters passed to $SCRIPTNAME"
  usage
  exit 1;
fi