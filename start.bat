@echo off
:: ===========================================
:: Update all packages to latest versions
:: and rebuild the project - bun v1.3.1+
:: ===========================================

echo Checking for outdated packages...
bun outdated

echo Updating dependencies to latest versions...
bun update

echo Installing/updating all dependencies...
bun install

echo Building project...
bun run dev