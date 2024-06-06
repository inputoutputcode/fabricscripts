$rgName = Get-AzResourceGroup 

Foreach($name in $rgName)
{
    Write-Host $name.ResourceGroupName
    if ($name.ResourceGroupName.startsWith("chrpap")) #-and !$name.ResourceGroupName.startsWith("chrpap310505"))
    {
        Remove-AzResourceGroup -Name $name.ResourceGroupName -Verbose -Force    
    }
}