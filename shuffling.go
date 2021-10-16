package main

import (
	"fmt"
	"math/rand"
	"os"
	"strconv"
	"time"
)

const chainlinkRandomNumber = "RandomNumberGoesHere"

//max int64  -> random number from chainlink will be cut to 18 digits
//9223372036854775807 -> this is max int64 in go, as max value for 'seed'
func main() {
	fmt.Printf("running script at @ unix nano %d\n", time.Now().UnixNano())

	//chainlinkRandomNumber is too big, get the first 18 digits
	seedStr := chainlinkRandomNumber[0:18]
	seed, err := strconv.ParseInt(seedStr, 10, 64)
	if err != nil {
		panic(err)
	}

	rand.Seed(seed)

	var nftIDs []int
	for i := 1; i <= 9999; i++ {
		nftIDs = append(nftIDs, i)
	}

	rand.Shuffle(len(nftIDs), func(i, j int) {
		nftIDs[i], nftIDs[j] = nftIDs[j], nftIDs[i]
	})

	printToFile("shuffled.txt", nftIDs)
	fmt.Println(nftIDs)
}

func printToFile(filePath string, values []int) {
	f, err := os.Create(filePath)
	if err != nil {
		panic(err)
	}
	defer f.Close()
	for _, value := range values {
		fmt.Fprintln(f, value) // print values to f, one per line
	}
}
