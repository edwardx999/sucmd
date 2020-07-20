$_pmake_cores_found = $false

<#
.Description
make with -j set to available cores
#>
Function pmake
{
	if ($global:_pmake_cores_found -eq $false)
	{
		Function fix_core_value
		{
			if((-not $global:_pmake_cores_found -is [UInt32]) -or ($global:_pmake_cores_found -lt 1))
			{
				$global:_pmake_cores_found = 1
			}
		}
		try
		{
			$global:_pmake_cores_found = (Get-WmiObject -class Win32_ComputerSystem).numberoflogicalprocessors
			fix_core_value
		}
		catch
		{
			try
			{
				$global:_pmake_cores_found = (Get-CimInstance Win32_ComputerSystem).NumberOfLogicalProcessors
				fix_core_value
			}
			catch
			{
				$global:_pmake_cores_found = 1
			}
		}
	}
	make -j $global:_pmake_cores_found
}



<#
.Description
mkdir and cd into that path
#>
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

<#
.Description
Make a "copy" of (a) file(s) into the current directory, given a filename (pattern) and optional link type.
.Example
linkcopy ../OtherFiles/*.mp4 /h
#>
Function linkcopy
{
	if($args.Count -gt 2)
	{
		throw "Too many arguments"
	}
	elseif($args.Count -lt 1)
	{
		throw "Too few arguments"
	}
	elseif($args.Count -eq 2)
	{
		if($args[0].StartsWith("/"))
		{
			$link_type = $args[0]
			$path = $args[1]
		}
		elseif ($args[1].StartsWith("/"))
		{
			$link_type = $args[1]
			$path = $args[0]
		}
		else
		{
			throw "Invalid Arguments"
		}
		$paths = Resolve-Path -Path $path
		foreach($p in $paths)
		{
			mklink (Split-Path $p -Leaf) $p.ToString() $link_type
		}
	}
	else
	{
		$path = $args[0]
		$paths = Resolve-Path -Path $path
		foreach($p in $paths)
		{
			mklink (Split-Path $p -Leaf) $p.ToString()
		}
	}
}

Function CommandLocation($command)
{
	return Split-Path -LiteralPath (Get-Command $command).Source
}

Function SleepComputer
{
	[System.Windows.Forms.Application]::SetSuspendState([System.Windows.Forms.PowerState]::Suspend, $false, $false)
}

<#
.Description
List directories in 
#>
Function lsdirs
{
	Get-ChildItem $args[0] -Directory
}

Function swapname($a, $b)
{
	$old_error_preference = $ErrorActionPreference
	$ErrorActionPreference = "Stop"
	try
	{
		$a = ([string](Resolve-Path -LiteralPath $a)).TrimEnd('\')
		$b = ([string](Resolve-Path -LiteralPath $b)).TrimEnd('\')
		if($a -eq $b)
		{
			throw "Paths must be different"
		}
		do
		{
			$temp_name = [string]$a + ([string](Get-Random -Maximum 1000000000)).PadLeft(9,"0")
		} while((Test-Path -Path $temp_name))
		if ((Test-Path -Path $a -PathType Leaf) -and (Test-Path $b -PathType Leaf))
		{
			[void](New-Item -ItemType HardLink -Path $temp_name -Value $a)
			try
			{
				Move-Item -Path $b -Destination $a -Force
			}
			catch
			{
				Remove-Item -Path $temp_name
				throw
			}
			try
			{
				Move-Item -Path $temp_name -Destination $b -Force
			}
			catch
			{
				Move-Item -Path $a -Destination $b -Force
				Move-Item -Path $temp_name -Destination $a -Force
				throw
			}
		}
		elseif((Test-Path -Path $a -PathType Container) -and (Test-Path $b -PathType Container))
		{
			Move-Item -Path $a -Destination $temp_name -Force
			try
			{
				Move-Item -Path $b -Destination $a -Force
			}
			catch
			{
				Move-Item -Path $temp_name -Destination $a -Force
				throw
			}
			try 
			{
				Move-Item -Path $temp_name -Destination $b -Force
			}
			catch
			{
				Move-Item -Path $a -Destination $b  -Force
				Move-Item -Path $temp_name -Destination $a  -Force
				throw
			}
		}
	}
	finally
	{
		$ErrorActionPreference = $old_error_preference
	}
}