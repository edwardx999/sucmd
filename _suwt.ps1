$dir = (Get-Location).Path
$cd_com = 'cd """' + $dir + '"""; Start-Process -NoNewWindow wt; exit' 
Start-Process powershell -ArgumentList "-NoExit","-Command",$cd_com -Verb RunAs