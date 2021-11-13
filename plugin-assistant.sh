#!/bin/bash

cd $HOME

#vars
read -p 'Path to create new directory in: ' parentPath
read -p 'Enter plugin id: ' pluginID
read -p 'Enter plugin name: ' pluginName
read -p 'Enter plugin description: ' pluginDesc

echo "✅ Variables set"

pluginStartVersion='0.0.1'
gitProfile=`git config user.name`
pluginAuthor=$gitProfile
authorURL="github.com/$gitProfile"

# Create new folder
cd "$parentPath"
mkdir $pluginID && cd $pluginID

echo "✅ Folder created"

# Initialise git repo
git init

# Create new repo on github based on Obsidian's sample plugin
gh repo create $pluginID -y -d "${pluginDesc}" --public -p "https://github.com/SkepticMystic/plugin-template"
git pull origin master

echo "✅ Repo created"

# Rename the default branch to main
git checkout -b main origin/master --no-track
git push -u origin main
git remote set-head origin main

# Set default branch
gh api -XPATCH repos/${gitProfile}/${pluginID} -f default_branch=main >/dev/null

# Delete 'master' remotely
git push origin --delete master

echo "✅ Default set to main"

# Find and replace in manifest.json
findStrings=( "obsidian-sample-plugin" "Sample Plugin" "1.0.1" "This is a sample plugin for Obsidian." "\"author\": \"Obsidian\"" "\"obsidian.md\"")
replaceStrings=( $pluginID "$pluginName" $pluginStartVersion "$pluginDesc" "\"author\": \"$pluginAuthor\"" "\"$authorURL\"")

for (( n=0; n<${#findStrings[@]}; n++ ))
do
    sed -i "" "s/${findStrings[$n]}/${replaceStrings[$n]}/" manifest.json
done

echo "✅ Changed manifest.json"

# Copy manifest.json to manifest-beta for BRAT
touch manifest-beta.json
cat manifest.json > manifest-beta.json

echo "✅ Changed manifest-beta.json"

# Find and replace in package.json
findStrings=( "obsidian-sample-plugin" "This is a sample plugin for Obsidian.")
replaceStrings=( $pluginID $pluginDesc )

for (( n=0; n<${#findStrings[@]}; n++ ))
do
    sed -i "" "s%${findStrings[$n]}%${replaceStrings[$n]}%" package.json
done

echo "✅ Changed package.json"

# Commit all changes!
cd ../..
git add .
git commit -m "🎉 init"
git push origin main

# Open in browser to verify
gh repo view --web

# Open in VSCode
code .