#! /bin/bash

tag="${1:-latest}"
clones="${2:-PACTA_analysis create_interactive_report StressTestingModelDev pacta-data}"
url="git@github.com:2DegreesInvesting/"

for repo in ${clones}
do
    remote="${url}${repo}.git"
    git clone -b master ${remote} --depth 1
    echo
done

for repo in ${clones}
do
    echo "${repo} HEAD sha:"
    git -C "${repo}" rev-parse HEAD
    echo
done

echo
echo

for repo in ${clones}
do
    git -C "${repo}" tag -a "${tag}" -m "Release pacta ${tag}" HEAD
    echo "${repo}"
    echo "$(git -C ${repo} log --pretty='%h %d <%an> (%cr)' | head -n 1)"
    echo
done

echo
echo

docker rmi --force $(docker images -q '2dii_pacta' | uniq)

echo
echo

docker build --tag 2dii_pacta:"${tag}" --tag 2dii_pacta:latest .

echo
echo

for repo in ${clones}
do
    rm -rf "${repo}"
done

unzip pacta_web_template.zip

echo
echo

git clone -b master "${url}"user_results.git --depth 1
echo "user_results HEAD sha:"

echo
echo

git -C user_results rev-parse HEAD

echo
echo

needless_files=".git .gitignore .DS_Store README.md user_results.Rproj"
for file in ${needless_files}
do
  rm -rf user_results/"${file}"
done

cp -R user_results/ pacta_web/user_results/4/
rm -rf user_results

docker save 2dii_pacta | gzip > pacta_web/2dii_pacta.tar.gz

zip -r pacta_web.zip pacta_web -x ".DS_Store" -x "__MACOSX"

rm -rf pacta_web

echo
echo "Done"
exit 0
