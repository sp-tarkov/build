## Validate that the tag exists in each project repository, or fail silent.

Param(
    [Parameter(Mandatory = $true)]
    [string] $RELEASE_TAG
)

Write-Output " » TODO: Checking for existence of tag: $RELEASE_TAG"