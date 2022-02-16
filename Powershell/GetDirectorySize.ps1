#Constants
$Path   = "E:\USUARIOS"
$Result = "C:\Temp\result_2022_FirefoxSize.txt"
$count = 0

#GetData
$items = Get-ChildItem -Directory $Path 

#GoLoop
ForEach ($item in $items) {
   #CurrentExecution
   $perc = [math]::Round(($count/$items.Count)*100)
   Write-Progress -Activity "Show in Progress" -Status "$count directories checkedd:" -PercentComplete $perc
   Write-Host "Current $($item.FullName)"

   #MeasureDirectory
   $currentDirectory = "$($item.FullName)\Firefox"
   If(Test-Path $currentDirectory){
      "$currentDirectory;{0} MB" -f [math]::Round(((Get-ChildItem $currentDirectory -Recurse | Measure-Object -Property Length -Sum -ErrorAction Stop).Sum / 1MB)) >> $Result
   }Else{
      Write-Host "Error"
   }

   $count = $count +1
}


