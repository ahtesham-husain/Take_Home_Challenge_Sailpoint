# Set the repoOwner, reponame and token details
$repoOwner = "ahtesham-husain"
$repoName = "ab-gh-repo"
$githubToken = Get-Content -Path "D:\Token.txt"
#$githubToken = Read-Host -Prompt "Enter your token" -AsSecureString



# Set the date range for last week
$startDate = (Get-Date).AddDays(-7).ToString("yyyy-MM-ddTHH:mm:ssZ")
$endDate = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")

# Get the pull requests from the GitHub API
$pullRequestsUrl = "https://api.github.com/repos/$repoOwner/$repoName/pulls?state=all&sort=created&direction=desc&since=$startDate&until=$endDate"
$headers = @{ "Authorization" = "Bearer $githubToken" }
$pullRequests = Invoke-RestMethod -Uri $pullRequestsUrl -Headers $headers

$pullRequests | select url,id,state,title | FT

# Convert into Count for opened, closed, and in progress pull requests
$openedCount = ($pullRequests | Where-Object { $_.state -eq "open" }) | Measure-Object | select Count
$closedCount = ($pullRequests | Where-Object { $_.state -eq "closed" }) | Measure-Object | select Count
$inProgressCount = ($pullRequests | Where-Object { $_.state -eq "open" -and $_.merged_at -eq $null })| Measure-Object | select Count


Write-Host "In the last week:"-ForegroundColor Green

Write-Host "The total Number Of Open Pull Requests are" -ForegroundColor Green
$openedCount.Count

Write-Host "The total Number Of Closed Pull Requests are" -ForegroundColor Green
$closedCount.Count

Write-Host "The total Number Of In-Progress Pull Requests are" -ForegroundColor Green
$inProgressCount.Count

# For e-mail summary
$emailSubject = "GitHub pull request summary for $repoOwner/$repoName"
$emailBody = @"
In the last week, there were:

- $openedCount opened pull requests
- $closedCount closed pull requests
- $inProgressCount pull requests in progress

View the pull requests here: https://github.com/$repoOwner/$repoName/pulls
"@

# To send e-mail
$smtpServer = "smtp.example.com"
$from = "email1@example.com"
$to = "manager@example.com"
Send-MailMessage -SmtpServer $smtpServer -From $from -To $to -Subject $emailSubject -Body $emailBody