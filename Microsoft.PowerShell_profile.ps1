$_pmake_cores_found = $false

<#
.Description
make with -j set to available cores
#>
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
	}
	else
	{
		$path = args[0]
		$link_type = "/s"
	}
	$paths = Resolve-Path -Path $path
	foreach($p in $paths)
	{
		mklink (Split-Path $p -Leaf) $p.ToString() $link_type
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