TIMEFORMAT=%R
benchmarkFolder="tests/benchmark"
benchmark=$1
param=$2
location="$benchmarkFolder/$benchmark.*"

files=`ls -1 $location`

py="Python"
lgm="Logramm"
rb="Ruby"
pl="Perl"
php="PHP"

for filepath in $files
do
(
filename=$(basename "$filepath")
extension="${filename##*.}"
case $extension in
lgm) lang="Logramm\t\t"
;;
py)  lang="Python\t\t"
;;
pl)  lang="Perl\t\t"
;;
rb)  lang="Ruby\t\t"
;;
php) lang="PHP\t\t"
;;
esac
output=$( { time $filepath $param; } 2>&1)
echo -e $lang ${output}s
#lang=eval $extension
#echo $lang = $output s
)
done