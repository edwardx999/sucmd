$_pmake_cores_found = $false

Function pmake
{
	if ($global:_pmake_cores_found -eq $false)
	{
		try
		{
			$global:_pmake_cores_found = (Get-WmiObject -class Win32_ComputerSystem).numberoflogicalprocessors
			if((-not $global:_pmake_cores_found -is [UInt32]) -or ($global:_pmake_cores_found -lt 1))
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
	$cmd = "mklink"
	foreach($arg in $args)
	{
		if($arg.Contains(" "))
		{
			$cmd += " `"${arg}`""
		}
		else
		{
			$cmd += " ${arg}"
		}
	}
	cmd /c $cmd
}

Function CommandLocation($command)
{
	return Split-Path -LiteralPath (Get-Command $command).Source
}