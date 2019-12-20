
cd C:\Code\AzureDevOpsTask.Tokenizer\Tokenizer

Enable-AzureRMAlias
.\Test-TokenizerLocal.ps1 -Environment dev01 -ContinueOnMissingToken -MaxRetryCount 0 -ReplaceMode User