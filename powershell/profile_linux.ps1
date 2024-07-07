# force utf8 output encoding
$OutputEncoding = [console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding

# disable azure to speed up prompt
$env:AZ_ENABLED=$false

oh-my-posh init pwsh --config /home/vscode/themes/powerlevel10k_rainbow.omp.json | Invoke-Expression

# Import-Module PSReadLine
Import-Module PSReadLine
Set-PSReadLineOption -EditMode Emacs -PredictionViewStyle ListView
Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineKeyHandler -Function AcceptSuggestion -Key 'Ctrl+Spacebar'
