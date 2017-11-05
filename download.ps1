
# Adapted from https://github.com/honzakuzel1989/examples/blob/master/PS1/download-event.ps1

$global:lastpercentage = -1
$global:are = New-Object System.Threading.AutoResetEvent $false

# TODO: make url and maybe all params same as for Invoke-WebRequest
$url = "http://ipv4.download.thinkbroadband.com/5MB.zip"

# TODO: parameterize, default to the last path part of url (i.e. probably the filename)
$output = "$PSScriptRoot\5meg.test"

$start_time = Get-Date

$wc = New-Object System.Net.WebClient

Register-ObjectEvent -InputObject $wc -EventName DownloadProgressChanged -Action {
    $percentage = $event.sourceEventArgs.ProgressPercentage
    $eargs = $EventArgs
    if($global:lastpercentage -lt $percentage)
    {
        $global:lastpercentage = $percentage

        Write-Progress -Activity "Download in progress" -Status "$percentage% Complete" -PercentComplete $percentage
        #Write-Host -NoNewline "`r$percentage% $($eargs.TotalBytesToReceive)"
    }
} > $null


Register-ObjectEvent -InputObject $wc -EventName DownloadFileCompleted -Action {
    $global:are.Set()
    Write-Host
} > $null

$wc.DownloadFileAsync($url, $output)

while(!$global:are.WaitOne(500)) {}

Write-Host "Time taken: $((Get-Date).Subtract($start_time).Seconds) second(s)"
