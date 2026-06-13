@echo off
call git stash save
call git pull 
call git stash drop