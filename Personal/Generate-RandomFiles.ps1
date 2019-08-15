# Provide Folder name and create
$Folder=’C:\Demo’

New-Item -ItemType Directory -Path $Folder

# Create a series of 10 files
for ($x=0;$x -lt 10; $x++)

{
# Let’s create a completely random filename
$filename=”$($Folder)\$((Get-Random 100000).tostring()).txt”

# Now we’ll create the file with some content
Add-Content -Value ‘Just a simple demo file’ -Path $filename

}