#as of april 2022
# too lazy to script this, for future reference this is how it went
wget https://cloud-dot-devsite-v2-prod.appspot.com/iam/docs/permissions-reference_4703c3277a8309890e18dcee31df892f7fc447aa8db1b99b09583428c56cf2a6.frame
grep "<td id=" permissions-reference_4703c3277a8309890e18dcee31df892f7fc447aa8db1b99b09583428c56cf2a6.frame| awk -F"\"" '{print $2}' > permissions.txt

# do some cyberchef cleanup to make it into proper json w/ replace()
# then do this to make the 5000+ json files
split -l 1 --additional-suffix=.json permissions_all_json.txt