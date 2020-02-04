param (
	[Parameter(Position=0)][String]$Path = ".",
	[Parameter(Position=1)][String]$Target = "User"
)
try
{
	$current_path = [Environment]::GetEnvironmentVariables($Target).Path
	$current_dir = Resolve-Path -LiteralPath $Path
	$current_dir = "${current_dir}"
	$paths = $current_path.Split(";") # Not proper parsing but good enough
	$included = $false
	foreach($path in $paths)
	{
		if($path -eq $current_dir)
		{
			$included = $true
			break
		}
	}
	if(-not $included)
	{
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