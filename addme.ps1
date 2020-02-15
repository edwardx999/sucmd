param (
	[Parameter(Position=0)][String]$Path = ".",
	[Parameter(Position=1)][String]$Target = "User"
)

Function PathSplit([string]$path)
{
	$len = $path.Length
	$ret = New-Object System.Collections.ArrayList
	if($len -eq 0)
	{
		return ret
	}
	$in_quotes = $False
	$start = 0
	for($i = 0; $i -lt $len; $i += 1)
	{
		$char = $path[$i]
		if($in_quotes)
		{
			if($char -eq [char]'"')
			{
				$in_quotes = $False
				if($start -lt $i)
				{
					$ret += $path.Substring($start, $i - $start)
				}
				$next = $i + 1
				if($next -lt $len)
				{
					if($path[$next] -ne [char]';')
					{
						throw "Invalid characters after quoted path"
					}
					$start = $i + 2
				}
				else
				{
					$start = $len
					break
				}
			}
		}
		else
		{
			if($char -eq [char]'"')
			{
				if($start -eq $i)
				{
					$in_quotes = $True
					$start = $i + 1
				}
				else
				{
					throw "Invalid characters before quoted path"
				}
			}
			if($char -eq [char]';')
			{
				if($start -lt $i)
				{
					$ret += $path.Substring($start, $i - $start)
				}
				$start = $i + 1
			}
		}
	}
	if($in_quotes)
	{
		throw "Path has unclosed quotes"
	}
	if($start -lt $len)
	{
		$ret += $path.Substring($start, $len - $start)
	}
	return $ret
}

try
{
	$current_path = [Environment]::GetEnvironmentVariables($Target).Path
	$current_dir = (Resolve-Path -LiteralPath $Path).ToString()
	$paths = PathSplit($current_path)
	foreach($path in $paths)
	{
		if($path -eq $current_dir)
		{
			exit
		}
	}
	if($current_dir.Contains(";"))
	{
		$current_dir = "`"${current_dir}`""
	}
	if($paths.Count -eq 0)
	{
		$new_path = $current_dir
	}
	else
	{
		$new_path =  "${current_path};${current_dir}"
	}
	[Environment]::SetEnvironmentVariable("Path", $new_path, $Target)
}
catch
{
	throw
}

<#
.Synopsis
Script to add paths to Path environment variable
.Description
Adds a path to the Path environment variable of the specified target. By default, adds current directory to User Path variable. 
#>