# /bin/bash
authToken=$(cat .token)
username=$(cat .username)

wget https://api.github.com/orgs/bigtyre/repos --header "Authorization: token $authToken" -O repositories.json
urls=$(cat repositories.json | pcregrep -o1 'clone_url": "(.*)"' | sort)

mkdir -p git-backups
mkdir -p git-repos

cd git-repos

for url in $urls
  do
    echo Url is $url
    if [[ $url =~ ([A-Za-z_\-]+).git ]]
    then
      repo=${BASH_REMATCH[0]}
      filename=${BASH_REMATCH[1]}
      bundleName=$filename.bundle

      replacement="s/https:\/\//https:\/\/${username}:${authToken}@/"

      gitUrl=$(echo $url | sed $replacement)

      if [[ $filename == 'Sentinel' ]]
      then
        break
      fi

      echo Repo is $repo
      echo Filename is $filename
      echo Bundle is $bundleName
      echo Cloning into $repo
      git clone --mirror $gitUrl $repo
      cd $repo
      echo Creating git bundle
      git bundle create $bundleName --all

      echo Copying file to git-backups folder
      echo yes | cp -rlf $bundleName ../../git-backups/$bundleName

      cd ..
      pwd
    else
      echo "Could not find repo name"
    fi
    echo
  done

cd ..
pwd
rm -rf git-repos
