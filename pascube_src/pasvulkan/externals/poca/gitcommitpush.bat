@echo off
set /p commit_message="Enter commit message (or leave blank for default): "
if "%commit_message%"=="" (
    set commit_message=More work
)
git commit -am "%commit_message%"
git push
rem --set-upstream origin master
