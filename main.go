package main

import (
	"encoding/json"
	"fmt"
	"github.com/disintegration/imaging"
	"image/jpeg"
	"io"
	"io/ioutil"
	"log"
	"os"
	"strings"
)

type metadata struct {
	Description string `json:"description"`
	ExternalUrl string `json:"external_url"`
	Image       string `json:"image"`
	Name        string `json:"name"`
	Attributes  []struct {
		TraitType string `json:"trait_type"`
		Value     string `json:"value"`
	} `json:"attributes"`
}

func main() {
	fmt.Println("Image & Metadata Randomizer...........")

	//rand array from file!
	_rArray, err := ioutil.ReadFile("randomArray.txt")
	if err != nil {
		log.Fatal(err)
	}
	rArrayFull := string(_rArray)
	randomArray := strings.Split(rArrayFull, ",")

	for originalValue, randomValue := range randomArray {
		//1. modify and create the metadata
		modifyAndCreateMetadata(originalValue+1, randomValue)

		//2. copy the image
		copyImage(originalValue+1, randomValue)

	}
}

func modifyAndCreateMetadata(initial int, randomed string) {

	//read the original metadata
	nftOriginalFile, err := ioutil.ReadFile("original_metadata/" + fmt.Sprintf("%d", initial)) //+".json"
	if err != nil {
		panic(err)
	}
	var mtd metadata
	_ = json.Unmarshal(nftOriginalFile, &mtd)

	//modify the name
	newName := "Metasaur #" + randomed

	mtd.Name = newName
	mtd.Image = "ipfs://xxxxxxxxxxxx/" + randomed + ".png"

	fileB, _ := json.MarshalIndent(mtd, "", " ")
	_ = ioutil.WriteFile("random_metadata/"+randomed+".json", fileB, 0644)

}

func copyImage(from int, to string) {
	err := copyFile("original_images/"+fmt.Sprintf("%d.png", from), "random_images/"+to+".png")
	if err != nil {
		log.Fatal(err)
	}
}

func copyFile(src, dst string) error {
	in, err := os.Open(src)
	if err != nil {
		return err
	}
	defer in.Close()

	out, err := os.Create(dst)
	if err != nil {
		return err
	}
	defer out.Close()

	_, err = io.Copy(out, in)
	if err != nil {
		return err
	}
	return out.Close()
}

//	//make a jpeg conversion
//	err = convertToJPEG("images_random/"+fmt.Sprintf("%d.png", rNumber),
//		"images_random/"+fmt.Sprintf("%d.jpeg", rNumber))
//	if err != nil {
//		panic(err)
//	}
func convertToJPEG(src, dst string) error {
	img, err := imaging.Open(src)
	if err != nil {
		return err
	}
	file, err := os.Create(dst)
	if err != nil {
		return err
	}
	if err := jpeg.Encode(file, img, &jpeg.Options{Quality: 95}); err != nil {
		return err
	}
	if err := file.Close(); err != nil {
		return err
	}
	return nil
}
