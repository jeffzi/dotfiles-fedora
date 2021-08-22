#!/bin/bash -eua
# https://superuser.com/questions/377186/how-do-i-start-chrome-using-a-specified-user-profile
profile_name=$1; shift
local_state=~/.config/google-chrome/Local\ State
profile_key=`< "$local_state" jq -r '
        .profile.info_cache | to_entries | .[] |
        select(.value.name == env.profile_name) | .key'`
[ -n "$profile_key" ]
google-chrome --profile-directory="$profile_key"
