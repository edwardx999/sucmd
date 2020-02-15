$_pmake_cores_found = $false 
Function pmake
{
	if ($global:_pmake_cores_found -eq $false)
	{
		try
		{
			$global:_pmake_cores_found = (Get-WmiObject -class Win32_ComputerSystem).numberoflogicalprocessors
			if(($global:_pmake_cores_found -eq $null) -or ($global:_pmake_cores_found -lt 1))
			{
				$global:_pmake_cores_found = 1
			}
		}
		catch
		{
			$global:_pmake_cores_found = 1
		}
	}
	make -j $global:_pmake_cores_found
}

Function mkcd($path)
{
	$null = New-Item $path -ItemType Directory -ea 0
	cd $path
}

Function mklink
{
	$cmd = "mklink `""+ ($args -join "`" `"") + "`""
	cmd /c $cmd
}