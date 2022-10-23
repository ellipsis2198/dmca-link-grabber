Add-Type -AssemblyName System.Windows.Forms
$username = ""
$userAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/106.0.0.0 Safari/537.36"
$debug = 0
$maxpages = 30


if ($username -eq "") { 
$username = Read-Host "Enter the model's username"
}

$sites = @(
 @{"uri"="https://tsrecs.com";"subpath"="/model/$username";"pagination"="/?page=%";"minLength"=52;"requireUser"=1;"requiredText"="$username"}, 
 @{"uri"="https://tstube.net";"subpath"="/model/$username";"pagination"="/?page=%";"minLength"=52;"requireUser"=1;"requiredText"=""}, 
 @{"uri"="https://tsvideos.org";"subpath"="/model/$username";"pagination"="/?page=%";"minLength"=52;"requireUser"=1;"requiredText"=""}, 
 @{"uri"="https://recurbate.com";"subpath"="/performer/$username";"pagination"="/page/%";"minLength"=42;"requireUser"=0;"requiredText"="video="}
 #@{"uri"="https://www.camrips.net";"subpath"="/models/$username";"pagination"="/page/%";"minLength"=52;"requireUser"=1;"requiredText"=""},
 #@{"uri"="https://www.webcamrips.com";"subpath"="/models/$username";"pagination"="/page/%";"minLength"=52;"requireUser"=1;"requiredText"=""}
)


function getLinks($uri, $subpath="", $pagination="", $minLength=52, $requireUser=1, $requiredText="", $sesh="") {
  $count = 1
  $urlList = [System.Collections.ArrayList]::new()
  while ($count -ne -1) {
    $builtUri = $uri + $subpath
    if ($debug) { Write-Host "On page $count" }
    if ($pagination -ne "" -And $count -gt 1) {
      $builtUri = $builtUri + $pagination.Replace("%",$count)
    }
    $request = try { Invoke-WebRequest -Uri $builtUri -UserAgent $userAgent -WebSession $sesh -UseBasicParsing
    } catch [System.Net.WebException] {
      $count = -1
      continue
    }
    if ($request.StatusCode -ne 200) {
      $count = -1
      continue
    }
    if ($debug) { Write-Host "Successful request to $builtUri" }
    $urls = $request.Links.Href | Get-Unique
    if ($debug) { Write-Host "$urls" }
    if (!($urls.Where({ $_.Contains("$username")}, 'First'))) {
      if ($debug) { Write-Host "Page does not contain $username" }
      $count = -1
      continue
    }
    ForEach ($url in $urls) {
      if ($url[0] -eq '/') {
        $workingUrl = $uri+$url
      }
      else {
        $workingUrl = $url
      }
      if ($workingUrl.Length -ge $MinLength) {
        if ($requiredText -eq "" -OR $workingUrl.Contains($requiredText)) {
            $urlList.Add($workingUrl) > $null
        }
      }
    }
    if ($count -eq $maxpages) {
      $count =-1
      continue
    }
    $count++ 
  }
  Start-Sleep -Milliseconds (380..2800 | Get-Random)
  return ($urlList | Sort-Object -unique)
}

ForEach ($site in $sites) {
  Invoke-WebRequest -Uri $site.item("uri") -UserAgent $userAgent -SessionVariable session -UseBasicParsing
  $result = getLinks -uri $site.item("uri") -subpath $site.item("subpath") -pagination $site.item("pagination") -minLength $site.item("minLength") -requireUser $site.item("requireUser") -requiredText $site.item("requiredText") -sesh $session
  Write-Host ($result -join "`r`n")
  Start-Sleep -Milliseconds (2000..3800 | Get-Random)
  $SaveFileBrowser = New-Object System.Windows.Forms.SaveFileDialog -Property @{ 
    InitialDirectory = [Environment]::GetFolderPath('Desktop') 
    Filter = 'txt files (*.txt)|*.txt|All files (*.*)|*.*'
    Title = "Choose where to save the output for $($site.item('uri'))"
  }
  $null = $SaveFileBrowser.ShowDialog()
  $output = $SaveFileBrowser.FileName
  ($result -join "`r`n") > $output
}
