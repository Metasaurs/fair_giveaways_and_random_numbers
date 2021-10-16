cd /home/me/workspace_backend/hash_and_randomizer/original_images
find . -type f -exec sha256sum {} \; > ../sha256_of_images.txt
echo "=========== hashes written to ../sha256_of_images.txt =========== "