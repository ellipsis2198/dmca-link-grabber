#
# This is horrendous so if you try to contribute you are a saint but if you don't try you're still okay in book
# Enjoy, Github Copilot
Add-Type -AssemblyName System.Windows.Forms
$username = ""
$userAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/106.0.0.0 Safari/537.36"
$debug = 0
$MAX_PAGES = 30
$linkCounter = 0

if ($username -eq "") { 
$username = Read-Host "Enter the model's username"
}

$fileHosts = @{}

$sites = @(
 #shared backend 2 - fboom users
 @{"uri"="gaywebcamblog.com";"subpath"="/performer/$username";"pagination"="/?page=%";"minLength"=46;"startingPage"=1;"externalHost"=1;"externalFormat"="/out.php?url=";"requiredText"="$username"}, #shared backend with gayrecs, tsvideos, tsrecs, tscam - we'll only get external host URLs one time per backend because it's slow
 @{"uri"="gayrecs.com";"subpath"="/model/$username";"pagination"="/?page=%";"minLength"=46;"startingPage"=1;"externalHost"=0;"externalFormat"="/out.php?url=";"requiredText"="$username"}, #does use external host, but it's identical to gaywebcamblog
 @{"uri"="tsrecs.com";"subpath"="/model/$username";"pagination"="/?page=%";"minLength"=46;"startingPage"=1;"externalHost"=0;"externalFormat"="/out.php?url=";"requiredText"="$username"}, #does use external host, but it's identical to gaywebcamblog
 @{"uri"="tscam.net";"subpath"="/performer/$username";"pagination"="/?page=%";"minLength"=46;"startingPage"=1;"externalHost"=0;"externalFormat"="/out.php?url=";"requiredText"="$username"}, #does use external host, but it's identical to gaywebcamblog
 @{"uri"="tsvideos.org";"subpath"="/model/$username";"pagination"="/?page=%";"minLength"=46;"startingPage"=1;"externalHost"=0;"externalFormat"="/out.php?url=";"requiredText"=""}, #does use external host, but it's identical to gaywebcamblog
 #shared backend 1  - various "clubs"
 @{"uri"="savemycam.com";"subpath"="/$username";"pagination"="?page=%";"minLength"=36;"startingPage"=1;"externalHost"=0;"externalFormat"="";"requiredText"="$username"}, 
 @{"uri"="mychaturcam.com";"subpath"="/$username";"pagination"="?page=%";"minLength"=36;"startingPage"=1;"externalHost"=0;"externalFormat"="";"requiredText"="$username"}, 
 @{"uri"="cbcamsclub.com";"subpath"="/$username";"pagination"="?page=%";"minLength"=36;"startingPage"=1;"externalHost"=0;"externalFormat"="";"requiredText"="$username"}, 
 @{"uri"="freecinemaclub.com";"subpath"="/$username";"pagination"="?page=%";"minLength"=36;"startingPage"=1;"externalHost"=0;"externalFormat"="";"requiredText"="$username"}, 
 @{"uri"="webcamrecs.com";"subpath"="/$username";"pagination"="?page=%";"minLength"=36;"startingPage"=1;"externalHost"=0;"externalFormat"="";"requiredText"="$username"}, 
 #misc
 @{"uri"="camstube.me";"subpath"="/tag/$username";"pagination"="/%";"minLength"=46;"startingPage"=0;"externalHost"=0;"externalFormat"="";"requiredText"="video/$username"},
 @{"uri"="tstube.net";"subpath"="/model/$username";"pagination"="/?page=%";"minLength"=46;"startingPage"=1;"externalHost"=0;"externalFormat"="";"requiredText"=""}, 
 @{"uri"="webcamrips.to";"subpath"="/tag/$username";"pagination"="/?page=%";"minLength"=20;"startingPage"=1;"externalHost"=0;"externalFormat"="";"requiredText"="$username"}, 
 @{"uri"="recurbate.com";"subpath"="/performer/$username";"pagination"="/page/%";"minLength"=33;"startingPage"=1;"externalHost"=0;"externalFormat"="";"requiredText"="play.php?video="}
 #@{"uri"="www.camrips.net";"subpath"="/models/$username";"pagination"="/page/%";"minLength"=52;"requiredText"=""},
 #@{"uri"="www.webcamrips.com";"subpath"="/models/$username";"pagination"="/page/%";"minLength"=52;"requiredText"=""}
)


function getLinks($uri, $subpath="", $pagination="", $minLength=52, $startingPage=1, $requiredText="", $externalHost=0, $externalFormat="", $maxpages=$MAX_PAGES, $includeDMCA=1, $sesh="") {
  $count = $startingPage
  $urlList = [System.Collections.ArrayList]::new()
  while ($count -ne -1) {
    $builtUri = $uri + $subpath
    if ($debug) { Write-Host "On page $count" }
    if ($pagination -ne "" -And $count -gt -1) {
      if ($debug) { Write-Host "Pagination enabled" }
      $builtUri = $builtUri + $pagination.Replace("%",$count)
    }
    if ($debug) { Write-Host "Sending request to $builtUri" }
    $request = try { Invoke-WebRequest -Uri $builtUri -UserAgent $userAgent -WebSession $sesh -UseBasicParsing
    } catch [System.Net.WebException] {
      if ($debug) { Write-Host $($_ | Out-String) }
      $count = -1
      if ($debug) { Write-Host "Generic request exception. Skipping to next site." }
      continue
    }
    if ($request.StatusCode -ne 200) {
      $count = -1
      if ($debug) { Write-Host "Non-successful code returned from webserver. Skipping to next site." }
      continue
    }
    if ($debug) { Write-Host "Successful request to $builtUri" }
    if ($debug) { Write-Host "Links: $($request.Links.href)" }
    $urls = $request.Links.Href | Get-Unique
    if ($debug) { Write-Host "urls: $urls" }
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
      if ($debug) { Write-Host "current url: $workingUrl" }
      if ($includeDMCA -And $workingUrl.Contains("dmca")) { $urlList.Add($workingUrl) > $null }
      if ($workingUrl.Length -ge $MinLength) {
        if ($requiredText -eq "" -Or $workingUrl.Contains($requiredText)) {
            if ($debug) { Write-Host "accepted url: $workingUrl" }
            $urlList.Add($workingUrl) > $null
        }
      }
    }
    if ($count -eq $maxpages -Or $pagination -eq "") {
      if ($debug) { Write-Host "Reached $maxpages pages or pagination not enabled. Continuing." }
      $count =-1
      continue
    }
    $count++ 
  }
  Start-Sleep -Milliseconds (380..2800 | Get-Random)
  if ($externalHost) {
    $extUrlList = [System.Collections.ArrayList]::new()
    $baseUrl = ""
    if ($debug) { Write-Host "Getting filehost links for DMCA of offending file" }
    ForEach ($url in $urlList) {
        $result = getLinks -uri $url -requiredText $externalFormat -maxpages 1 -includeDMCA 0 -sesh $sesh
        if ($result -isnot [String]) { continue }
        if ($debug) { Write-Host "Found matching URL: [$result]" }
        $b64str = $result.Substring($($result.IndexOf($externalFormat) + $externalFormat.Length))
        $decodedUrl = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($b64str))
        $decodedUrl = $decodedUrl.Substring(0,$($decodedUrl.IndexOf("?site=")))
        if ($debug) { Write-Host "Decoded URL: [$decodedUrl]" }
        $baseUrl = $decodedUrl | Select-String -Pattern "https:\/\/([\w\d]+)\." | ForEach-Object {$_.Matches.Groups[1].value}
        if ($debug) { Write-Host "External host base name: $baseUrl" }
        $extUrlList.Add($decodedUrl) > $null
    }
    if ($debug) { Write-Host "External host URLs: [$extUrlList]" }
    if (!$fileHosts.ContainsKey($baseUrl)) {$fileHosts[$baseUrl] = [System.Collections.ArrayList]::new()}
    $extUrlList | Sort-Object -unique | ForEach-Object{$fileHosts[$baseUrl].Add($_)}
  }
  if ($urlList.Count -eq 0) {return -1}
  return ($urlList | Sort-Object -unique)
}

ForEach ($site in $sites) {
  Invoke-WebRequest -Uri $site.item("uri") -UserAgent $userAgent -SessionVariable session -UseBasicParsing
  $result = getLinks -uri $site.item("uri") -subpath $site.item("subpath") -pagination $site.item("pagination") -minLength $site.item("minLength") -requiredText $site.item("requiredText") -startingPage $site.item("startingPage") -externalHost $site.item("externalHost") -externalFormat $site.item("externalFormat") -sesh $session
  if ($result -eq -1) {continue}
  Write-Host ($result -join "`r`n")
  Write-Host ("Links found for $($site.item('uri')): $($result.Count)")
  $linkCounter += $result.Count
  Start-Sleep -Milliseconds (2000..3800 | Get-Random)
  $SaveFileBrowser = New-Object System.Windows.Forms.SaveFileDialog -Property @{ 
    InitialDirectory = [Environment]::GetFolderPath('Desktop') 
    FileName = "$($username)_$($site.item('uri'))_$(Get-Date -UFormat '%Y%m%d').txt"
    Filter = 'txt files (*.txt)|*.txt|All files (*.*)|*.*'
    Title = "Choose where to save the output for $($site.item('uri'))"
  }
  $null = $SaveFileBrowser.ShowDialog()
  $output = $SaveFileBrowser.FileName
  ($result -join "`r`n") > $output
}
ForEach ($filehost in $fileHosts.Keys) {
   $data = $fileHosts[$filehost] | Sort-Object -Unique
   $linkCounter += $data.Count
   $SaveFileBrowser = New-Object System.Windows.Forms.SaveFileDialog -Property @{ 
    InitialDirectory = [Environment]::GetFolderPath('Desktop') 
    FileName = "$($username)_$($filehost)_$(Get-Date -UFormat '%Y%m%d').txt"
    Filter = 'txt files (*.txt)|*.txt|All files (*.*)|*.*'
    Title = "Choose where to save the output for $($filehost)"
  }
  $null = $SaveFileBrowser.ShowDialog()
  $output = $SaveFileBrowser.FileName
  ($data -join "`r`n") > $output
}
Write-Host "Total # of offending links found: $linkCounter"