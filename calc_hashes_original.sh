cd /PATH_TO_FOLDER_WITH_ORIGINAL_IMAGES
find . -type f -exec sha256sum {} \; > ../sha256_of_images.txt
echo "=========== hashes written to ../sha256_of_images.txt =========== "
