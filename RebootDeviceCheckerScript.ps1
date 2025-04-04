#This PowerShell script checks if any user is logged into the computer, including users with disconnected sessions.
#
#If a user is logged in (whether active or disconnected), the script outputs a message saying "A user is logged in. Restart will be skipped." and stops further execution by throwing an error (throw).
#If no user is logged in, the script outputs "No users logged in. Restarting the computer..." and proceeds to forcefully restart the computer using Restart-Computer -Force.

$loggedInUsers = quser | Select-String -Pattern "^\s*\S+"

if ($loggedInUsers) {
    # Extracting details for each logged-in user
    foreach ($user in $loggedInUsers) {
        $userDetails = $user.ToString().Split(" ", [StringSplitOptions]::RemoveEmptyEntries)

        $username = $userDetails[0]
        $sessionState = $userDetails[3]
        $logonTime = $userDetails[5] + " " + $userDetails[6]  # Concatenate date and time
        $idleTime = if ($userDetails[4] -eq "none") { "none" } else { "$($userDetails[4]) minutes" }

    }
	Write-Output "Loggon user: $username, Session State: $sessionState, Sessin Logon Time: $logonTime, Session Idle time: $idleTime"
    throw "A user $username is logged in. Restart will be skipped."
} else {
    Write-Output "No users logged in. Restarting the computer..."
    Restart-Computer -Force
}
